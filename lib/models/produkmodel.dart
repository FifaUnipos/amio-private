int _toInt(dynamic v, {int defaultValue = 0}) {
  if (v == null) return defaultValue;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true') return 1;
    if (s == 'false') return 0;
    return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? defaultValue;
  }
  return defaultValue;
}

num _toNum(dynamic v, {num defaultValue = 0}) {
  if (v == null) return defaultValue;
  if (v is num) return v;
  if (v is String) return num.tryParse(v.trim()) ?? defaultValue;
  return defaultValue;
}

String? _toStr(dynamic v) => v?.toString();

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
    this.price_after,
    this.price_online_shop,
    this.price_online_shop_after,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.productImage,
    required this.discount_type,
    required this.discount,
  });

  ModelDataProduk.fromJson(Map<String, dynamic> json) {
    productid = _toStr(json['productid']);
    name = _toStr(json['name']);
    price = _toNum(json['price']);
    price_after = _toNum(json['price_after']);
    price_online_shop = _toNum(json['price_online_shop']);
    price_online_shop_after = _toNum(json['price_online_shop_after']);
    isActive = _toInt(json['isActive']);
    isPPN = _toInt(json['isPPN']);
    typeproducts = _toStr(json['typeproducts']);
    productImage = _toStr(json['product_image']);
    discount_type = _toStr(json['discount_type']);
    discount = _toInt(json['discount']);
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
  int? discount;
  String? kodeProduct;

  ModelDataProdukGrup({
    this.productid,
    this.name,
    this.price,
    this.price_after,
    this.price_online_shop,
    this.price_online_shop_after,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.productImage,
    required this.discount_type,
    required this.discount,
    this.kodeProduct,
  });

  ModelDataProdukGrup.fromJson(Map<String, dynamic> json) {
    productid = _toStr(json['productid']);
    name = _toStr(json['name']);
    price = _toNum(json['price']);
    price_after = _toNum(json['price_after']);
    price_online_shop = _toNum(json['price_online_shop']);
    price_online_shop_after = _toNum(json['price_online_shop_after']);
    isActive = _toInt(json['isActive']);
    isPPN = _toInt(json['isPPN']);
    typeproducts = _toStr(json['typeproducts']);
    productImage = _toStr(json['product_image']);
    discount_type = _toStr(json['discount_type']);
    discount = _toInt(json['discount']);
    kodeProduct = _toStr(json['kodeproduct']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ModelDataProdukGrup = new Map<String, dynamic>();
    ModelDataProdukGrup['productid'] = this.productid;
    ModelDataProdukGrup['name'] = this.name;
    ModelDataProdukGrup['price'] = this.price;
    ModelDataProdukGrup['price_after'] = this.price_after;
    ModelDataProdukGrup['price_online_shop'] = this.price_online_shop;
    ModelDataProdukGrup['price_online_shop_after'] =
        this.price_online_shop_after;
    ModelDataProdukGrup['isActive'] = this.isActive;
    ModelDataProdukGrup['isPPN'] = this.isPPN;
    ModelDataProdukGrup['typeproducts'] = this.typeproducts;
    ModelDataProdukGrup['product_image'] = this.productImage;
    ModelDataProdukGrup['discount_type'] = this.discount_type;
    ModelDataProdukGrup['discount'] = this.discount;
    ModelDataProdukGrup['kodeproduct'] = this.kodeProduct;
    return ModelDataProdukGrup;
  }
}
