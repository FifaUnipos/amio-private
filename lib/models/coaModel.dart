class PaymentMethod {
  String? idpaymentmethode;
  String? paymentMethod;
  String? accountNumber;
  String? category;

  PaymentMethod({
    this.idpaymentmethode,
    this.paymentMethod,
    this.accountNumber,
    this.category,
  });

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    idpaymentmethode = json['idpaymentmethode'];
    paymentMethod = json['payment_method'];
    accountNumber = json['accountNumber'] ?? '-';
    category = json['category'] ?? '-';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idpaymentmethode'] = this.idpaymentmethode;
    data['payment_method'] = this.paymentMethod;
    data['accountNumber'] = this.accountNumber;
    data['category'] = this.category;
    return data;
  }
}

class PaymentData {
  List<PaymentMethod>? data;

  PaymentData({
    this.data,
  });

  PaymentData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <PaymentMethod>[];
      json['data'].forEach((v) {
        data!.add(PaymentMethod.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = new Map<String, dynamic>();
    if (this.data != null) {
      result['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return result;
  }
}
