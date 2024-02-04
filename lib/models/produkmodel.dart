class ModelDataProduk {
  String? productid;
  String? name;
  num? price;
  num? price_after;
  num? price_online_shop;
  num? price_online_shop_after;
  int? isActive;
  int? isPPN;
  String? typeproducts;
  String? productImage;
  String? discount_type;
  int? discount;

  ModelDataProduk({
    this.productid,
    this.name,
    this.price,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.productImage,
    required this.discount_type,
    required this.discount,
  });

  ModelDataProduk.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    price = json['price'];
    price_after = json['price_after'];
    price_online_shop = json['price_online_shop'];
    price_online_shop_after = json['price_online_shop_after'];
    isActive = json['isActive'];
    isPPN = json['isPPN'];
    typeproducts = json['typeproducts'];
    productImage = json['product_image'];
    discount_type = json['discount_type'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ModelDataProduk = new Map<String, dynamic>();
    ModelDataProduk['productid'] = this.productid;
    ModelDataProduk['name'] = this.name;
    ModelDataProduk['price'] = this.price;
    ModelDataProduk['price_after'] = this.price_after;
    ModelDataProduk['price_online_shop'] = this.price_online_shop;
    ModelDataProduk['price_online_shop_after'] = this.price_online_shop_after;
    ModelDataProduk['isActive'] = this.isActive;
    ModelDataProduk['isPPN'] = this.isPPN;
    ModelDataProduk['typeproducts'] = this.typeproducts;
    ModelDataProduk['product_image'] = this.productImage;
    ModelDataProduk['discount_type'] = this.discount_type;
    ModelDataProduk['discount'] = this.discount_type;
    return ModelDataProduk;
  }
}

class ModelDataProdukGrup {
  String? productid;
  String? name;
  num? price;
  num? price_after;
  num? price_online_shop;
  num? price_online_shop_after;
  int? isActive;
  int? isPPN;
  String? typeproducts;
  String? productImage;
  String? discount_type;
  String? kodeProduct;
  int? discount;

  ModelDataProdukGrup({
    this.productid,
    this.name,
    this.price,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.productImage,
    this.kodeProduct,
    required this.discount_type,
    required this.discount,
  });

  ModelDataProdukGrup.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    price = json['price'];
    price_after = json['price_after'];
    price_online_shop = json['price_online_shop'];
    price_online_shop_after = json['price_online_shop_after'];
    isActive = json['isActive'];
    isPPN = json['isPPN'];
    typeproducts = json['typeproducts'];
    productImage = json['product_image'];
    discount_type = json['discount_type'];
    discount = json['discount'];
    kodeProduct = json['kodeproduct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ModelDataProduk = new Map<String, dynamic>();
    ModelDataProduk['productid'] = this.productid;
    ModelDataProduk['name'] = this.name;
    ModelDataProduk['price'] = this.price;
    ModelDataProduk['price_after'] = this.price_after;
    ModelDataProduk['price_online_shop'] = this.price_online_shop;
    ModelDataProduk['price_online_shop_after'] = this.price_online_shop_after;
    ModelDataProduk['isActive'] = this.isActive;
    ModelDataProduk['isPPN'] = this.isPPN;
    ModelDataProduk['typeproducts'] = this.typeproducts;
    ModelDataProduk['product_image'] = this.productImage;
    ModelDataProduk['discount_type'] = this.discount_type;
    ModelDataProduk['discount'] = this.discount_type;
    ModelDataProduk['kodeProduct'] = this.kodeProduct;
    return ModelDataProduk;
  }

  // void setEnabled(bool value) {
  //   ppn = value;
  // }

  // bool? isEnabled() {
  //   return isActive;
  // }
}
