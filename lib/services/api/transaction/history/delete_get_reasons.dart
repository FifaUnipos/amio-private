import 'dart:convert';

import 'package:unipos_app_335/data/model/transaction/history/delete_reasons_response.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:http/http.dart' as http;

class TransactionHistoryDeleteReasonsService {
  Future<TransactionHistoryDeleteReasonsResponse> transactionHistoryDeleteGetReasons(
    String transactionId,
    String token,
    String device
  ) async {
    final response = await http.post(
      Uri.parse(ApiTransactionHistory.getReasons),
      headers: {
        'token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "deviceid": identifier,
        "transactionid": transactionId,
        "typetransaksi": "hapus",

      }),
    );

    if (response.statusCode == 200) {
      return TransactionHistoryDeleteReasonsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load delete reasons reference');
    }
  }
}
