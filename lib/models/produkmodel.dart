class ModelDataProduk {
  String? productid;
  String? name;
  int? price;
  int? isActive;
  int? isPPN;
  String? typeproducts;
  String? productImage;

  ModelDataProduk({
    this.productid,
    this.name,
    this.price,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.productImage,
  });

  ModelDataProduk.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    price = json['price'];
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
    ModelDataProduk['isActive'] = this.isActive;
    ModelDataProduk['isPPN'] = this.isPPN;
    ModelDataProduk['typeproducts'] = this.typeproducts;
    ModelDataProduk['product_image'] = this.productImage;
    return ModelDataProduk;
  }

  // void setEnabled(bool value) {
  //   ppn = value;
  // }

  // bool? isEnabled() {
  //   return isActive;
  // }

}

class ModelDataProdukGrup {
  String? productid;
  String? name;
  int? price;
  int? isActive;
  int? isPPN;
  // bool? isActive;
  // bool? isPPN;
  String? typeproducts;
  String? kodeProduct;
  String? productImage;

  ModelDataProdukGrup({
    this.productid,
    this.name,
    this.price,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.kodeProduct,
    this.productImage,
  });

  ModelDataProdukGrup.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    price = json['price'];
    isActive = json['isActive'];
    isPPN = json['isPPN'];
    typeproducts = json['typeproducts'];
    kodeProduct = json['kodeproduct'];
    productImage = json['product_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ModelDataProduk = new Map<String, dynamic>();
    ModelDataProduk['productid'] = this.productid;
    ModelDataProduk['name'] = this.name;
    ModelDataProduk['price'] = this.price;
    ModelDataProduk['isActive'] = this.isActive;
    ModelDataProduk['isPPN'] = this.isPPN;
    ModelDataProduk['typeproducts'] = this.typeproducts;
    ModelDataProduk['kodeproduct'] = this.kodeProduct;
    ModelDataProduk['product_image'] = this.productImage;
    return ModelDataProduk;
  }

  // void setEnabled(bool value) {
  //   ppn = value;
  // }

  // bool? isEnabled() {
  //   return isActive;
  // }

}
