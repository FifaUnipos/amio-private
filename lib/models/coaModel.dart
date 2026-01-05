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

class CoaModel {
  String? idpaymentmethode;
  String? paymentMethod;
  String? paymentMethodReferenceId;
  String? accountNumber;
  String? category;
  PaymentReferenceModel? paymentReference;

  CoaModel({
    this.idpaymentmethode,
    this.paymentMethod,
    this.paymentMethodReferenceId,
    this.accountNumber,
    this.category,
    this.paymentReference,
  });

  CoaModel.fromJson(Map<String, dynamic> json) {
    idpaymentmethode = json['idpaymentmethode'];
    paymentMethod = json['payment_method'];
    paymentMethodReferenceId = json['payment_method_reference_id'];
    accountNumber = json['accountNumber'];
    category = json['category'];
    paymentReference = json['payment_reference'] != null
        ? PaymentReferenceModel.fromJson(json['payment_reference'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idpaymentmethode'] = idpaymentmethode;
    data['payment_method'] = paymentMethod;
    data['payment_method_reference_id'] = paymentMethodReferenceId;
    data['accountNumber'] = accountNumber;
    data['category'] = category;
    if (paymentReference != null) {
      data['payment_reference'] = paymentReference!.toJson();
    }
    return data;
  }
}

class PaymentReferenceModel {
  String? paymentReferenceId;
  String? paymentReferenceName;
  String? paymntReferenceImage;

  PaymentReferenceModel({
    this.paymentReferenceId,
    this.paymentReferenceName,
    this.paymntReferenceImage,
  });

  PaymentReferenceModel.fromJson(Map<String, dynamic> json) {
    paymentReferenceId = json['paymentReferenceId'];
    paymentReferenceName = json['paymentReferenceName'];
    paymntReferenceImage = json['paymntReferenceImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentReferenceId'] = paymentReferenceId;
    data['paymentReferenceName'] = paymentReferenceName;
    data['paymntReferenceImage'] = paymntReferenceImage;
    return data;
  }
}
