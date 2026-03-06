class TransactionHistoryModel {
  final String transactionId;
  final String? customer;
  final double amount;
  final String? entryDate;
  String? isPaid;
  String? statusTransactions;
  String? statusColor;

  TransactionHistoryModel({
    required this.transactionId,
    this.customer,
    required this.amount,
    this.entryDate,
    this.isPaid,
    this.statusTransactions,
    this.statusColor,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      transactionId: json['transaction_id']?.toString() ?? json['transactionid']?.toString() ?? '',
      customer: json['customer'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      entryDate: json['entry_date'],
      isPaid: json['isPaid']?.toString(),
      statusTransactions: json['status_transactions'],
      statusColor: json['status_color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'customer': customer,
      'amount': amount,
      'entry_date': entryDate,
      'isPaid': isPaid,
      'status_transactions': statusTransactions,
      'status_color': statusColor,
    };
  }
}

class TransactionDetailModel {
  final String transactionId;
  final Map<String, dynamic> fullData;

  TransactionDetailModel({
    required this.transactionId,
    required this.fullData,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      transactionId: json['transactionid']?.toString() ?? json['transaction_id']?.toString() ?? '',
      fullData: json,
    );
  }

  // Getters for UI
  String? get statusColor => fullData['status_color']?.toString();
  String? get statusTransactions => fullData['status_transactions'];
  String? get customer => fullData['customer'];
  String? get pic => fullData['pic'];
  String? get isPaid => fullData['isPaid']?.toString();

  set isPaid(String? value) => fullData['isPaid'] = value;
  set statusTransactions(String? value) => fullData['status_transactions'] = value;
  set statusColor(String? value) => fullData['status_color'] = value;
  
  double get totalBeforeDscTax => _parseAmount(fullData['total_before_dsc_tax']);
  double get ppn => _parseAmount(fullData['ppn']);
  double get amount => _parseAmount(fullData['amount']);

  String? get paymentName => fullData['payment_name'];
  String? get raw => fullData['raw'];

  double get discount => _parseAmount(fullData['discount']);
  double get moneyPaid => _parseAmount(fullData['money_paid']);
  double get changeMoney => _parseAmount(fullData['change_money']);

  List<TransactionProductItem>? get detailProducts {
    final list = fullData['detail'] as List?;
    if (list == null) return null;
    return list.map((item) => TransactionProductItem.fromJson(item)).toList();
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() => fullData;
}

class TransactionProductItem {
  final String? name;
  final double price;
  final int quantity;
  final String? productImage;
  final String? note;
  final List<dynamic>? variants;

  TransactionProductItem({
    this.name,
    required this.price,
    required this.quantity,
    this.productImage,
    this.note,
    this.variants,
  });

  factory TransactionProductItem.fromJson(Map<String, dynamic> json) {
    return TransactionProductItem(
      name: json['name'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      productImage: json['product_image'],
      note: json['note'],
      variants: json['variants'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'quantity': quantity,
    'product_image': productImage,
    'note': note,
    'variants': variants,
  };
}
