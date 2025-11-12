class ModelDataPromosi {
  String? productid;
  String? name;
  int? price;
  int? point;
  int? isActive;
  int? isPPN;
  String? typeproducts;
  String? productImage;

  ModelDataPromosi({
    this.productid,
    this.name,
    this.price,
    this.point,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.productImage,
  });

  ModelDataPromosi.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    price = json['price'];
    point = json['point'];
    isActive = json['isActive'];
    isPPN = json['isPPN'];
    typeproducts = json['typeproducts'];
    productImage = json['product_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ModelDataProduk = new Map<String, dynamic>();
    ModelDataProduk['productid'] = this.productid;
    ModelDataProduk['name'] = this.name;
    ModelDataProduk['price'] = this.price;
    ModelDataProduk['point'] = this.point;
    ModelDataProduk['isActive'] = this.isActive;
    ModelDataProduk['isPPN'] = this.isPPN;
    ModelDataProduk['typeproducts'] = this.typeproducts;
    ModelDataProduk['product_image'] = this.productImage;
    return ModelDataProduk;
  }
}
