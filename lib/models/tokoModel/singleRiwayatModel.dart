class RiwayatSingleModel {
  String? transactionid;
  String? merchantid;
  int? amount;
  String? description;
  String? entrydate;
  int? discount;
  int? totalBeforeDscTax;
  int? ppn;
  String? raw;
  String? isPaid;
  String? paymentMethod;
  String? customer;
  String? pic;
  int? isBackdate;
  String? paymentReference;
  String? reason;
  int? antrian;
  List<DetailSingle>? detail;

  RiwayatSingleModel(
      {this.transactionid,
      this.merchantid,
      this.amount,
      this.description,
      this.entrydate,
      this.discount,
      this.totalBeforeDscTax,
      this.ppn,
      this.raw,
      this.isPaid,
      this.paymentMethod,
      this.customer,
      this.pic,
      this.isBackdate,
      this.paymentReference,
      this.reason,
      this.antrian,
      this.detail});

  factory RiwayatSingleModel.fromJson(Map<String, dynamic> json) {
    return RiwayatSingleModel(
      transactionid: json['transactionid'],
      merchantid: json['merchantid'],
      amount: json['amount'],
      description: json['description'],
      entrydate: json['entrydate'],
      discount: json['discount'],
      totalBeforeDscTax: json['total_before_dsc_tax'],
      ppn: json['ppn'],
      raw: json['raw'],
      isPaid: json['isPaid'],
      paymentMethod: json['payment_method'],
      customer: json['customer'],
      pic: json['pic'],
      isBackdate: json['isBackdate'],
      paymentReference: json['payment_reference'],
      reason: json['reason'],
      antrian: json['antrian'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionid'] = this.transactionid;
    data['merchantid'] = this.merchantid;
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['entrydate'] = this.entrydate;
    data['discount'] = this.discount;
    data['total_before_dsc_tax'] = this.totalBeforeDscTax;
    data['ppn'] = this.ppn;
    data['raw'] = this.raw;
    data['isPaid'] = this.isPaid;
    data['payment_method'] = this.paymentMethod;
    data['customer'] = this.customer;
    data['pic'] = this.pic;
    data['isBackdate'] = this.isBackdate;
    data['payment_reference'] = this.paymentReference;
    data['reason'] = this.reason;
    data['antrian'] = this.antrian;
    if (this.detail != null) {
      data['detail'] = this.detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DetailSingle {
  String? productid;
  String? name;
  String? shortname;
  String? typeproducts;
  String? jenisproduct;
  String? isActive;
  int? isPPN;
  String? productImage;
  int? quantity;
  int? amount;
  String? description;

  DetailSingle(
      {this.productid,
      this.name,
      this.shortname,
      this.typeproducts,
      this.jenisproduct,
      this.isActive,
      this.isPPN,
      this.productImage,
      this.quantity,
      this.amount,
      this.description});

  DetailSingle.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    shortname = json['shortname'];
    typeproducts = json['typeproducts'];
    jenisproduct = json['jenisproduct'];
    isActive = json['isActive'];
    isPPN = json['isPPN'];
    productImage = json['product_image'];
    quantity = json['quantity'];
    amount = json['amount'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productid'] = this.productid;
    data['name'] = this.name;
    data['shortname'] = this.shortname;
    data['typeproducts'] = this.typeproducts;
    data['jenisproduct'] = this.jenisproduct;
    data['isActive'] = this.isActive;
    data['isPPN'] = this.isPPN;
    data['product_image'] = this.productImage;
    data['quantity'] = this.quantity;
    data['amount'] = this.amount;
    data['description'] = this.description;
    return data;
  }
}
