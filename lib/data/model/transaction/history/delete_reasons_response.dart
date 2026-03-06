import 'package:unipos_app_335/data/model/transaction/history/delete_reasons.dart';

class TransactionHistoryDeleteReasonsResponse {
  final String? rc;
  final TransactionHistoryDeleteReasonsData? data;
  final String? message;

  TransactionHistoryDeleteReasonsResponse({this.rc, this.data, this.message});

  factory TransactionHistoryDeleteReasonsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionHistoryDeleteReasonsResponse(
      rc: json['rc']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] != null
          ? TransactionHistoryDeleteReasonsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rc': rc,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}
