import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:unipos_app_335/data/model/transaction/history/delete_response.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/config/apimethod.dart';
import 'package:unipos_app_335/utils/database_helper.dart';
import 'package:unipos_app_335/utils/connection_checker.dart';
import 'package:unipos_app_335/utils/logger.dart';

class TransactionHistoryDeleteService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectionChecker _connectionChecker = ConnectionChecker();

  Future<TransactionHistoryDeleteResponse> transactionHistoryDelete(
    String transactionId,
    String idKategori,
    String detailAlasan,
    String token,
  ) async {
    bool isOnline = await _connectionChecker.checkInternet();
    bool isOfflineId = transactionId.startsWith("OFFLINE-");

    if (isOnline && !isOfflineId) {
      try {
        final response = await http.post(
          Uri.parse(ApiTransactionHistory.deleteTransaction),
          headers: {
            'token': token,
            'DEVICE-ID': identifier ?? '',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "deviceid": identifier ?? '',
            "detail_alasan": detailAlasan,
            "idkategori": idKategori,
            "transactionid": transactionId,
          }),
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['rc'] == '00') {
             return TransactionHistoryDeleteResponse.fromJson(decoded);
          } else {
             return TransactionHistoryDeleteResponse(
               rc: decoded['rc'],
               message: decoded['message'] ?? 'Gagal membatalkan tagihan',
             );
          }
        } else {
          AppLogger.e("DeleteService", "API Error ${response.statusCode}: ${response.body}");
          return TransactionHistoryDeleteResponse(
            rc: "99",
            message: "Gagal membatalkan tagihan (Error ${response.statusCode})",
          );
        }
      } catch (e) {
        AppLogger.e("DeleteService", "Error deleting online: $e");
        return TransactionHistoryDeleteResponse(
          rc: "99",
          message: "Koneksi terputus atau server bermasalah.",
        );
      }
    }

    // Handle Offline or failure
    AppLogger.d("DeleteService", "Queuing deletion for $transactionId...");
    if (isOfflineId) {
      final idStr = transactionId.replaceFirst("OFFLINE-", "");
      final id = int.tryParse(idStr);
      if (id != null) {
        await _dbHelper.markOfflineTransactionDeleted(id);
      }
    }

    await _dbHelper.addToSyncQueue('DELETE_BILL', transactionId, {
      'reasonId': idKategori,
      'notes': detailAlasan,
    });

    return TransactionHistoryDeleteResponse(
      rc: "00",
      message: "Transaksi berhasil dibatalkan (Mode Offline)",
    );
  }
}
