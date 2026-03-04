import 'dart:convert';

import 'package:unipos_app_335/data/model/transaction/history/view_deleted_history_response.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/config/apimethod.dart';
import 'package:http/http.dart' as http;

class TransactionViewDeletedHistoryService {
  Future<TransactionViewDeletedHistoryResponse> transactionViewDeletedHistory(
    String token,
    String transactionId,
    String merchantId,
  ) async {
    final response = await http.post(
      Uri.parse(ApiTransactionHistory.viewDeletedHistory),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "deviceid": identifier,
        "transactionid": transactionId,
        "merchandid": merchantId,
      }),
    );

    if (response.statusCode == 200) {
      return TransactionViewDeletedHistoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load transaction deleted history');
    }
  }
}
