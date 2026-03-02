import 'package:unipos_app_335/data/model/transaction/history/view_deleted_history.dart';

class TransactionViewDeletedHistoryResponse {
  final String? rc;
  final TransactionViewDeletedHistoryData? data;

  TransactionViewDeletedHistoryResponse({this.rc, this.data});

  factory TransactionViewDeletedHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionViewDeletedHistoryResponse(
      rc: json['rc']?.toString(),
      data: json['data'] != null
          ? TransactionViewDeletedHistoryData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'rc': rc, if (data != null) 'data': data!.toJson()};
  }
}
