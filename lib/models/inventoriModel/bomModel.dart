class BOMModel {
  String? id;
  String? title;
  String? productId;
  String? productName;

  BOMModel({
    this.id,
    this.title,
    this.productId,
    this.productName,
  });

  BOMModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    productId = json['product_id'];
    productName = json['product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['product_id'] = productId;
    data['product_name'] = productName;
    return data;
  }
}
