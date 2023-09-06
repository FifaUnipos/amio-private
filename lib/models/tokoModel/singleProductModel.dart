class SingleDataProduct {
  String? productid;
  String? name;
  String? shortname;
  int? price;
  int? isActive;
  int? isPPN;
  String? typeproducts;
  String? kodeproduct;
  String? productImage;
  int? isDelete;

  SingleDataProduct(
      {this.productid,
      this.name,
      this.shortname,
      this.price,
      this.isActive,
      this.isPPN,
      this.typeproducts,
      this.kodeproduct,
      this.productImage,
      this.isDelete});

  SingleDataProduct.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    shortname = json['shortname'];
    price = json['price'];
    isActive = json['isActive'];
    isPPN = json['isPPN'];
    typeproducts = json['typeproducts'];
    kodeproduct = json['kodeproduct'];
    productImage = json['product_image'];
    isDelete = json['isDelete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productid'] = this.productid;
    data['name'] = this.name;
    data['shortname'] = this.shortname;
    data['price'] = this.price;
    data['isActive'] = this.isActive;
    data['isPPN'] = this.isPPN;
    data['typeproducts'] = this.typeproducts;
    data['kodeproduct'] = this.kodeproduct;
    data['product_image'] = this.productImage;
    data['isDelete'] = this.isDelete;
    return data;
  }
}
