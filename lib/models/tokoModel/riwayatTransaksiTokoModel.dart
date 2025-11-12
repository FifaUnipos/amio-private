class TokoDataRiwayatModel {
  String? transactionid;
  String? customer;
  String? merchantid;
  num? amount;
  String? entrydate;
  String? isPaid;
  String? isColor;
  String? pic;
  num? isBackdate;
  String? paymentName;
  String? reason;
  String? status;
  num? antrian;

  TokoDataRiwayatModel({
    this.transactionid,
    this.merchantid,
    this.amount,
    this.entrydate,
    this.isPaid,
    this.isColor,
    this.pic,
    this.isBackdate,
    this.paymentName,
    this.reason,
    this.status,
    this.antrian,
  });

  TokoDataRiwayatModel.fromJson(Map<String, dynamic> json) {
    transactionid = json['transactionid'];
    customer = json['customer'];
    merchantid = json['merchantid'];
    amount = json['amount'];
    entrydate = json['entrydate'];
    isPaid = json['isPaid'];
    isColor = json['status_color'];
    pic = json['pic'];
    isBackdate = json['isBackdate'];
    paymentName = json['payment_name'];
    reason = json['reason'];
    status = json['status_transactions'];
    antrian = json['antrian'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionid'] = this.transactionid;
    data['customer'] = this.customer;
    data['merchantid'] = this.merchantid;
    data['amount'] = this.amount;
    data['entrydate'] = this.entrydate;
    data['isPaid'] = this.isPaid;
    data['status_color'] = this.isColor;
    data['pic'] = this.pic;
    data['isBackdate'] = this.isBackdate;
    data['payment_name'] = this.paymentName;
    data['reason'] = this.reason;
    data['status_transactions'] = this.status;
    data['antrian'] = this.antrian;
    return data;
  }
}
