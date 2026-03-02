
class TransactionViewDeletedHistoryData {
  final String? transactionId;
  final String? entryDate;
  final TransactionViewDeletedHistoryReference? references;
  final String? estimate;
  final String? isApprove;

  TransactionViewDeletedHistoryData({
    this.transactionId,
    this.entryDate,
    this.references,
    this.estimate,
    this.isApprove,
  });

  factory TransactionViewDeletedHistoryData.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionViewDeletedHistoryData(
      transactionId: json['transactionid']?.toString(),
      entryDate: json['entrydate']?.toString(),
      references: json['reference'] != null
          ? (json['reference'] is List)
              ? (json['reference'] as List).isNotEmpty
                  ? TransactionViewDeletedHistoryReference.fromJson(
                      (json['reference'] as List).first,
                    )
                  : null
              : TransactionViewDeletedHistoryReference.fromJson(json['reference'])
          : null,
      estimate: json['estimate']?.toString(),
      isApprove: json['isApprove']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionid': transactionId,
      if (references != null)
        'reference': references!.toJson(),
      'entrydate': entryDate,
      'estimate': estimate,
      'isApprove': isApprove,
    };
  }
}

class TransactionViewDeletedHistoryReference{
  final String? reasons;
  final String? detailReason;

  TransactionViewDeletedHistoryReference({this.reasons, this.detailReason});

  factory TransactionViewDeletedHistoryReference.fromJson(Map<String, dynamic> json) {
    return TransactionViewDeletedHistoryReference(
      reasons: json['alasan']?.toString(),
      detailReason: json['detail']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'alasan': reasons, 'detail': detailReason};
  }
}
