class TransactionHistoryDeleteReasonsData {
  final String? transaksiidReference;
  final List<TransactionHistoryDeleteReason>? alasan;

  TransactionHistoryDeleteReasonsData({this.transaksiidReference, this.alasan});

  factory TransactionHistoryDeleteReasonsData.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionHistoryDeleteReasonsData(
      transaksiidReference: json['transaksiid_reference']?.toString(),
      alasan: json['alasan'] != null
          ? List<TransactionHistoryDeleteReason>.from(
              json['alasan'].map(
                (x) => TransactionHistoryDeleteReason.fromJson(x),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaksiid_reference': transaksiidReference,
      if (alasan != null) 'alasan': alasan!.map((x) => x.toJson()).toList(),
    };
  }
}

class TransactionHistoryDeleteReason {
  final String? idkategori;
  final String? namakategori;

  TransactionHistoryDeleteReason({this.idkategori, this.namakategori});

  factory TransactionHistoryDeleteReason.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryDeleteReason(
      idkategori: json['idkategori']?.toString(),
      namakategori: json['namakategori']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'idkategori': idkategori, 'namakategori': namakategori};
  }
}
