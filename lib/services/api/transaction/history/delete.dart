import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/data/model/transaction/history/delete_response.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';

class TransactionHistoryDeleteService {
  Future<TransactionHistoryDeleteResponse> transactionHistoryDelete(
    String transactionId,
    String idKategori,
    String detailAlasan,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse(ApiTransactionHistory.deleteTransaction),
      headers: {
        'token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "deviceid": identifier,
        "detail_alasan": detailAlasan,
        "idkategori": idKategori,
        "transactionid": transactionId,
      }),
    );

    if (response.statusCode == 200) {
      return TransactionHistoryDeleteResponse.fromJson(jsonDecode(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          throw Exception(decoded['message'].toString());
        }
      } catch (e) {
        if (e.toString().contains('Exception:')) rethrow;
      }
      throw Exception('Failed to delete tagihan: ${response.statusCode}');
    }
  }
}
