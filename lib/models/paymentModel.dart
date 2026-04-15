class PaymentMethod {
  final String id;
  final String paymentMethod;
  final String accountNumber;
  final String category;

  PaymentMethod({
    required this.id,
    required this.paymentMethod,
    required this.accountNumber,
    required this.category,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: (json['idpaymentmethode'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      accountNumber: (json['accountNumber'] ?? '-').toString(),
      category: (json['category'] ?? '').toString(),
    );
  }
}
