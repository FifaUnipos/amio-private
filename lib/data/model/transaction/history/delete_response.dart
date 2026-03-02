class TransactionHistoryDeleteResponse {
  final String? rc;
  final String? message;
  final List<dynamic>? data;

  TransactionHistoryDeleteResponse({
    this.rc,
    this.message,
    this.data,
  });

  factory TransactionHistoryDeleteResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryDeleteResponse(
      rc: json['rc']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] != null ? List<dynamic>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rc': rc,
      'message': message,
      if (data != null) 'data': data,
    };
  }
}
