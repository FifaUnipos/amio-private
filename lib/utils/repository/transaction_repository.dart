import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/config/app_endpoints.dart';
import 'package:unipos_app_335/utils/database_helper.dart';
import 'package:unipos_app_335/utils/connection_checker.dart';
import 'package:unipos_app_335/models/transactionModel.dart';
import 'package:unipos_app_335/utils/logger.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectionChecker _connectionChecker = ConnectionChecker();

  Future<void> syncPendingTransactions({
    required String token,
    required String merchantId,
  }) async {
    // 0. Sync Offline Transactions (Create & Delete)
    final offlineTx = await _dbHelper.getOfflineTransactions();
    if (offlineTx.isNotEmpty) {
      AppLogger.d("Sync", "Starting sync for ${offlineTx.length} pending transactions...");
      for (var tx in offlineTx) {
        try {
          AppLogger.d("Sync", "Syncing offline bill ID: ${tx['id']} (Deleted: ${tx['is_deleted']})");
          
          final response = await http.post(
            Uri.parse(ApiEndpoints.createTransaksiUrl),
            headers: {
              'token': token,
              'DEVICE-ID': identifier ?? '',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "merchant_id": merchantId,
              "transaction_id": null,
              "member_id": tx['member_id'],
              "discount_id": tx['discount_id'],
              "is_partial_payment": false,
              "payments": [],
              "detail": tx['details'],
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['rc'] == '00') {
              final String serverId = data['data']['transactionid']?.toString() ?? "";
              AppLogger.d("Sync", "Successfully created offline bill: ${tx['id']} -> Server ID: $serverId");
              
              if (tx['is_deleted'] == 1 && serverId.isNotEmpty) {
                // SEQUENTIAL SYNC: If it was deleted offline, delete it on server now!
                AppLogger.d("Sync", "Bill ${tx['id']} was deleted offline. Syncing deletion for server ID $serverId...");
                
                final queue = await _dbHelper.getSyncQueue();
                final deleteAction = queue.firstWhere(
                  (q) => q['transaction_id'] == "OFFLINE-${tx['id']}" && q['action'] == 'DELETE_BILL',
                  orElse: () => {},
                );

                if (deleteAction.isNotEmpty) {
                  final payload = jsonDecode(deleteAction['payload']);
                  final delSuccess = await _deleteBillOnServer(
                    token: token,
                    transactionId: serverId,
                    reasonId: payload['reasonId'],
                    notes: payload['notes'],
                  );
                  if (delSuccess) {
                    await _dbHelper.deleteFromSyncQueue(deleteAction['id']);
                  } else {
                    AppLogger.d("Sync", "Failed to sync sequential deletion for $serverId. Will retry via sync_queue.");
                  }
                }
              }
              await _dbHelper.deleteOfflineTransaction(tx['id']);
            } else {
              AppLogger.d("Sync", "Failed to create bill ${tx['id']}: ${data['rc']} - ${data['message']}");
            }
          } else {
            AppLogger.d("Sync", "Server error creating bill ${tx['id']}: ${response.statusCode} - ${response.body}");
          }
        } catch (e) {
          AppLogger.d("Sync", "Exception syncing transaction ${tx['id']}: $e");
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // 1. Sync Queue (Deletions for online bills)
    final queue = await _dbHelper.getSyncQueue();
    for (var item in queue) {
      if (item['action'] == 'DELETE_BILL') {
        final txId = item['transaction_id'];
        if (txId.startsWith("OFFLINE-")) continue; // Handled above

        final payload = jsonDecode(item['payload']);
        final success = await _deleteBillOnServer(
          token: token,
          transactionId: txId,
          reasonId: payload['reasonId'],
          notes: payload['notes'],
        );
        if (success) {
          await _dbHelper.deleteFromSyncQueue(item['id']);
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    AppLogger.d("Sync", "Sync process completed.");
  }

  Future<bool> _deleteBillOnServer({
    required String token,
    required String transactionId,
    required String reasonId,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.deleteTagihanUrl),
        headers: {
          'token': token,
          'DEVICE-ID': identifier ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "deviceid": identifier ?? '',
          "transactionid": transactionId,
          "idkategori": reasonId,
          "detail_alasan": notes,
        }),
      );

      AppLogger.d("Sync", "Delete Response for $transactionId: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00') return true;
        AppLogger.d("Sync", "Failed to delete bill $transactionId on server: ${data['rc']} - ${data['message']}");
      } else {
        AppLogger.d("Sync", "Server error deleting bill $transactionId: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      AppLogger.e("Sync", "Error deleting bill on server: $e");
    }
    return false;
  }

  Future<List<TransactionHistoryModel>> getHistory({
    required String token,
    required String merchantId,
    String orderBy = "upDownCreate",
    Function(List<TransactionHistoryModel>)? onSyncUpdate,
  }) async {
    // 0. Trigger Sync
    syncPendingTransactions(token: token, merchantId: merchantId);

    // 1. Get from Cache
    final cachedData = await _dbHelper.getTransactionCache(
      'history',
      merchantId,
    );
    List<TransactionHistoryModel> localList = [];
    if (cachedData != null) {
      localList = cachedData
          .map((e) => TransactionHistoryModel.fromJson(e))
          .toList();
    }

    // 2. Background Sync
    _syncTransactions(
      type: 'history',
      token: token,
      merchantId: merchantId,
      condition: "",
      orderBy: orderBy,
      onSyncUpdate: onSyncUpdate,
    );

    return localList;
  }

  Future<List<TransactionHistoryModel>> getBills({
    required String token,
    required String merchantId,
    String orderBy = "upDownCreate",
    Function(List<TransactionHistoryModel>)? onSyncUpdate,
  }) async {
    // 1. Get from Cache
    final cachedData = await _dbHelper.getTransactionCache('bill', merchantId);
    List<TransactionHistoryModel> localList = [];
    if (cachedData != null) {
      localList = cachedData
          .map((e) => TransactionHistoryModel.fromJson(e))
          .toList();
    }

    // 3. Mark Offline Deletions for Online Bills
    final queue = await _dbHelper.getSyncQueue();
    final deletedIds = queue
        .where((q) => q['action'] == 'DELETE_BILL')
        .map((q) => q['transaction_id'].toString())
        .toSet();

    for (var bill in localList) {
      if (deletedIds.contains(bill.transactionId)) {
        // This online bill is pending deletion offline
        bill.isPaid = '2'; // Canceled
        bill.statusTransactions = 'Dibatalkan';
        bill.statusColor = '2';
      }
    }

    // 4. Combine Offline & Cached Online
    final List<TransactionHistoryModel> offlineList = await _getOfflineAsHistoryModels();
    final combinedList = [...offlineList, ...localList];

    // 3. Background Sync
    _syncTransactions(
      type: 'bill',
      token: token,
      merchantId: merchantId,
      condition: "0",
      orderBy: orderBy,
      onSyncUpdate: onSyncUpdate,
    );

    return combinedList;
  }

  Future<bool> saveBill({
    required String token,
    required String merchantId,
    required Map<String, dynamic> transaction,
    required List<Map<String, dynamic>> details,
  }) async {
    bool isOnline = await _connectionChecker.checkInternet();

    if (isOnline) {
      try {
        final response = await http.post(
          Uri.parse(ApiEndpoints.createTransaksiUrl),
          headers: {
            'token': token,
            'DEVICE-ID': identifier ?? '',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "merchant_id": merchantId,
            "transaction_id": null,
            "member_id": transaction['member_id'],
            "discount_id": transaction['discount_id'],
            "is_partial_payment": false,
            "payments": [],
            "detail": details,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['rc'] == '00') {
            AppLogger.d(
              "Tagihan",
              "Bill saved online successfully: ${data['message']}",
            );
            return true;
          }
        }
      } catch (e) {
        print("Error saving bill online: $e");
      }
    }

    // If offline or online fails, save locally
    AppLogger.d("Tagihan", "Saving bill offline...");
    await _dbHelper.saveOfflineTransaction(transaction, details);
    return true; // Return true because it's "saved" (locally)
  }

  Future<void> _syncTransactions({
    required String type,
    required String token,
    required String merchantId,
    required String condition,
    required String orderBy,
    Function(List<TransactionHistoryModel>)? onSyncUpdate,
  }) async {
    bool isOnline = await _connectionChecker.checkInternet();
    if (!isOnline) return;

    // Trigger sync for bills
    if (type == 'bill') {
      await syncPendingTransactions(token: token, merchantId: merchantId);
    }

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.getTransaksiRiwayatUrl),
        headers: {
          'token': token,
          'DEVICE-ID': identifier ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "condition": condition,
          "order_by": orderBy,
          "merchant_id": merchantId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          final List<dynamic> rawList = data['data'];

          // Save to Cache
          await _dbHelper.saveTransactionCache(type, merchantId, rawList);

          if (onSyncUpdate != null) {
            List<TransactionHistoryModel> updatedList = rawList
                .map((e) => TransactionHistoryModel.fromJson(e))
                .toList();
            
            if (type == 'bill') {
              final offlineList = await _getOfflineAsHistoryModels();
              updatedList = [...offlineList, ...updatedList];
            }
            
            onSyncUpdate(updatedList);
          }
        }
      }
    } catch (e) {
      print("Error syncing transactions ($type): $e");
    }
  }

  Future<TransactionDetailModel?> getTransactionDetail({
    required String token,
    required String merchantId,
    required String transactionId,
  }) async {
    // 1. Check if it's an offline transaction
    if (transactionId.startsWith("OFFLINE-")) {
      final idStr = transactionId.replaceFirst("OFFLINE-", "");
      final id = int.tryParse(idStr);
      if (id != null) {
        final offlineTx = await _dbHelper.getOfflineTransactions();
        final found = offlineTx.firstWhere(
          (element) => element['id'] == id,
          orElse: () => {},
        );
        if (found.isNotEmpty) {
          final bool isDeleted = found['is_deleted'] == 1;
          // Map to Detail Model format
          Map<String, dynamic> detailData = {
            "transactionid": transactionId,
            "customer": found['member_id'],
            "amount": found['value'],
            "status_transactions": isDeleted ? "Dibatalkan" : "Menunggu Sinkronisasi",
            "isPaid": isDeleted ? '2' : (found['status'] == 'OFFLINE' ? '3' : '1'),
            "statusColor": isDeleted ? '2' : '3',
            "detail":
                found['details'], // These are from offline_transaction_details
            "entry_date": DateTime.fromMillisecondsSinceEpoch(
              found['timestamp'],
            ).toString(),
          };
          return TransactionDetailModel.fromJson(detailData);
        }
      }
      return null;
    }

    // 2. Try local cache first
    final cached = await _dbHelper.getTransactionDetail(transactionId);
    if (cached != null) {
      final queue = await _dbHelper.getSyncQueue();
      final isPendingDelete = queue.any(
        (q) => q['action'] == 'DELETE_BILL' && q['transaction_id'] == transactionId
      );

      final detail = TransactionDetailModel.fromJson(cached);
      if (isPendingDelete) {
        detail.isPaid = '2';
        detail.statusTransactions = 'Dibatalkan';
      }

      // Background update
      _syncTransactionDetail(token, merchantId, transactionId);
      return detail;
    }

    // 3. If not in cache, fetch and wait
    final result = await _syncTransactionDetail(token, merchantId, transactionId);
    if (result != null) return result;

    // 4. Fallback: If still null, try to find in Bill List Cache to show basic info
    final billCache = await _dbHelper.getTransactionCache('bill', merchantId);
    if (billCache != null) {
      final found = billCache.firstWhere(
        (e) => (e['transaction_id']?.toString() ?? e['transactionid']?.toString()) == transactionId,
        orElse: () => null,
      );
      if (found != null) {
        final queue = await _dbHelper.getSyncQueue();
        final isPendingDelete = queue.any(
          (q) => q['action'] == 'DELETE_BILL' && q['transaction_id'] == transactionId
        );

        final basicDetail = TransactionDetailModel.fromJson(found);
        if (isPendingDelete) {
          basicDetail.isPaid = '2';
          basicDetail.statusTransactions = 'Dibatalkan';
        }
        return basicDetail;
      }
    }

    return null;
  }

  Future<TransactionDetailModel?> _syncTransactionDetail(
    String token,
    String merchantId,
    String transactionId,
  ) async {
    bool isOnline = await _connectionChecker.checkInternet();
    if (!isOnline) return null;

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.getTransaksiSingleRiwayatUrl),
        headers: {
          'token': token,
          'DEVICE-ID': identifier ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "transaction_id": transactionId,
          "merchant_id": merchantId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rc'] == '00' && data['data'] != null) {
          final detailData = data['data'];
          await _dbHelper.saveTransactionDetail(transactionId, detailData);
          return TransactionDetailModel.fromJson(detailData);
        }
      }
    } catch (e) {
      print("Error syncing transaction detail: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getCancelReasons({
    required String token,
    required String transactionId,
  }) async {
    bool isOnline = await _connectionChecker.checkInternet();
    if (isOnline) {
      try {
        final response = await http.post(
          Uri.parse(ApiEndpoints.headerTagihanUrl),
          headers: {
            'token': token,
            'DEVICE-ID': identifier ?? '',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "deviceid": identifier ?? '',
            "transactionid": transactionId,
            "typetransaksi": "hapus",
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['rc'] == '00' && data['data'] != null) {
            final reasons = (data['data']['alasan'] as List?) ?? [];
            final results = reasons.map((e) => Map<String, dynamic>.from(e)).toList();
            // Cache these reasons
            await _dbHelper.saveDeletionReasons(results);
            return results;
          }
        }
      } catch (e) {
        AppLogger.e("Repository", "Error fetching cancel reasons: $e");
      }
    }

    // Attempt to get from cache first
    final cachedReasons = await _dbHelper.getDeletionReasons();
    if (cachedReasons.isNotEmpty) {
      return cachedReasons;
    }

    // Fallback or offline static reasons
    return [
      {"idkategori": "230805011", "namakategori": "Permintaan Pembeli"},
      {"idkategori": "230805013", "namakategori": "Kesalahan Kasir"},
      {"idkategori": "230805014", "namakategori": "Keterlambatan Pesanan"},
      {"idkategori": "230805015", "namakategori": "Pembayaran Tidak Berhasil"},
      {"idkategori": "230805016", "namakategori": "Produk Tidak Tersedia"},
      {"idkategori": "230805017", "namakategori": "Kondisi Darurat"},
    ];
  }

  Future<bool> deleteBill({
    required String token,
    required String transactionId,
    required String reasonId,
    required String notes,
  }) async {
    bool isOnline = await _connectionChecker.checkInternet();

    if (isOnline && !transactionId.startsWith("OFFLINE-")) {
      final success = await _deleteBillOnServer(
        token: token,
        transactionId: transactionId,
        reasonId: reasonId,
        notes: notes,
      );
      if (success) return true;
    }

    // Handle Offline or failure
    AppLogger.d("Repository", "Queuing bill deletion for $transactionId...");
    if (transactionId.startsWith("OFFLINE-")) {
      final idStr = transactionId.replaceFirst("OFFLINE-", "");
      final id = int.tryParse(idStr);
      if (id != null) {
        await _dbHelper.markOfflineTransactionDeleted(id);
      }
    }

    await _dbHelper.addToSyncQueue('DELETE_BILL', transactionId, {
      'reasonId': reasonId,
      'notes': notes,
    });
    
    return true; // We consider it "done" locally
  }

  Future<List<TransactionHistoryModel>> _getOfflineAsHistoryModels() async {
    final offlineTx = await _dbHelper.getOfflineTransactions();
    return offlineTx.map((ot) {
      final isDeleted = ot['is_deleted'] == 1;
      return TransactionHistoryModel(
        transactionId: "OFFLINE-${ot['id']}",
        customer: ot['member_id'] ?? 'OFFLINE',
        amount: (ot['value'] as num?)?.toDouble() ?? 0.0,
        entryDate: DateTime.fromMillisecondsSinceEpoch(
          ot['timestamp'],
        ).toString().split('.').first,
        isPaid: isDeleted ? '2' : '3', // 2 for Canceled, 3 for Success/Pending
        statusTransactions: isDeleted ? 'Dibatalkan' : 'Menunggu Sinkronisasi',
        statusColor: isDeleted ? '2' : '3',
      );
    }).toList();
  }
}
