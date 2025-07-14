class ModelDataInventori {
  String? id;
  String? nameItem;
  String? unitId;
  String? merchantId;
  String? qty;
  // num? qty;
  String? lastestActivity;
  String? merchantName;
  String? unitName;
  String? unitAbbreviation;

  ModelDataInventori({
    this.id,
    this.nameItem,
    this.unitId,
    this.merchantId,
    this.qty,
    this.lastestActivity,
    this.merchantName,
    this.unitName,
    this.unitAbbreviation,
  });

  ModelDataInventori.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameItem = json['name_item'];
    unitId = json['unit_id'];
    merchantId = json['merchant_id'];
    qty = json['qty'];
    lastestActivity = json['lastest_activity'];
    merchantName = json['merchant_name'];
    unitName = json['unit_name'];
    unitAbbreviation = json['unit_abbreviation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name_item'] = nameItem;
    data['unit_id'] = unitId;
    data['merchant_id'] = merchantId;
    data['qty'] = qty;
    data['lastest_activity'] = lastestActivity;
    data['merchant_name'] = merchantName;
    data['unit_name'] = unitName;
    data['unit_abbreviation'] = unitAbbreviation;
    return data;
  }
}
