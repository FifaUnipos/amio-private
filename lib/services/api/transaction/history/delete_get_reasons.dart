import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:unipos_app_335/data/model/transaction/history/delete_reasons.dart';
import 'package:unipos_app_335/data/model/transaction/history/delete_reasons_response.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/config/apimethod.dart';
import 'package:unipos_app_335/utils/database_helper.dart';
import 'package:unipos_app_335/utils/connection_checker.dart';
import 'package:unipos_app_335/utils/logger.dart';

class TransactionHistoryDeleteReasonsService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectionChecker _connectionChecker = ConnectionChecker();

  Future<TransactionHistoryDeleteReasonsResponse>
      transactionHistoryDeleteGetReasons(
    String transactionId,
    String token,
    String device,
  ) async {
    bool isOnline = await _connectionChecker.checkInternet();
    bool isOfflineId = transactionId.startsWith("OFFLINE-");

    if (isOnline && !isOfflineId) {
      try {
        final response = await http.post(
          Uri.parse(ApiTransactionHistory.getReasons),
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
          final decoded = jsonDecode(response.body);
          final result = TransactionHistoryDeleteReasonsResponse.fromJson(decoded);
          
          if (result.rc == '00' && result.data?.alasan != null) {
            // Cache these reasons
            final List<Map<String, dynamic>> rawList = (decoded['data']['alasan'] as List)
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            await _dbHelper.saveDeletionReasons(rawList);
          }
          return result;
        }
      } catch (e) {
        AppLogger.e("DeleteReasons", "Error fetching reasons: $e");
      }
    }

    // Offline / Error Fallback: Try Cache
    AppLogger.d("DeleteReasons", "Attempting to load reasons from cache...");
    final cached = await _dbHelper.getDeletionReasons();
    if (cached.isNotEmpty) {
      return TransactionHistoryDeleteReasonsResponse(
        rc: "00",
        message: "Loaded from cache",
        data: TransactionHistoryDeleteReasonsData(
          alasan: cached.map((e) => TransactionHistoryDeleteReason(
            idkategori: e['idkategori']?.toString(),
            namakategori: e['namakategori']?.toString(),
          )).toList(),
        ),
      );
    }

    // Hard Fallback
    return TransactionHistoryDeleteReasonsResponse(
      rc: "00",
      message: "Static fallback",
      data: TransactionHistoryDeleteReasonsData(
        alasan: [
          TransactionHistoryDeleteReason(idkategori: "230805011", namakategori: "Permintaan Pembeli"),
          TransactionHistoryDeleteReason(idkategori: "230805013", namakategori: "Kesalahan Kasir"),
          TransactionHistoryDeleteReason(idkategori: "230805014", namakategori: "Keterlambatan Pesanan"),
          TransactionHistoryDeleteReason(idkategori: "230805015", namakategori: "Pembayaran Tidak Berhasil"),
          TransactionHistoryDeleteReason(idkategori: "230805016", namakategori: "Produk Tidak Tersedia"),
          TransactionHistoryDeleteReason(idkategori: "230805017", namakategori: "Kondisi Darurat"),
        ],
      ),
    );
  }
}
