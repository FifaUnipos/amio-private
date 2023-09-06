class Data {
  String? subTotal;
  String? pPN;
  String? total;
  String? customer;

  Data({this.subTotal, this.pPN, this.total, this.customer});

  Data.fromJson(Map<String, dynamic> json) {
    subTotal = json['subTotal'];
    pPN = json['PPN'];
    total = json['total'];
    customer = json['customer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subTotal'] = this.subTotal;
    data['PPN'] = this.pPN;
    data['total'] = this.total;
    data['customer'] = this.customer;
    return data;
  }
}
