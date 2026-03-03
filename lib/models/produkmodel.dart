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
    this.price_after,
    this.price_online_shop,
    this.price_online_shop_after,
  });

  ModelDataProduk.fromJson(Map<String, dynamic> json) {
    productid = json['productid']?.toString();
    name = json['name'];
    price = json['price'];
    price_after = json['price_after'];
    price_online_shop = json['price_online_shop'];
    price_online_shop_after = json['price_online_shop_after'];
    isActive = json['isActive'] is int ? json['isActive'] : int.tryParse(json['isActive']?.toString() ?? '1');
    isPPN = json['isPPN'] is int ? json['isPPN'] : int.tryParse(json['isPPN']?.toString() ?? '0');
    typeproducts = json['typeproducts'];
    productImage = json['product_image'] ?? json['productImage'];
    discount_type = json['discount_type'];
    discount = json['discount'] is int ? json['discount'] : int.tryParse(json['discount']?.toString() ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productid'] = this.productid;
    data['name'] = this.name;
    data['price'] = this.price;
    data['price_after'] = this.price_after;
    data['price_online_shop'] = this.price_online_shop;
    data['price_online_shop_after'] = this.price_online_shop_after;
    data['isActive'] = this.isActive;
    data['isPPN'] = this.isPPN;
    data['typeproducts'] = this.typeproducts;
    data['product_image'] = this.productImage;
    data['discount_type'] = this.discount_type;
    data['discount'] = this.discount;
    return data;
  }

  // Define toMap for SQLite compatibility as used in DatabaseHelper
  Map<String, dynamic> toMap() => toJson();
}

// Keeping these for existing references in the codebase
typedef ProductModel = ModelDataProduk;

class ModelDataProdukGrup extends ModelDataProduk {
  String? kodeProduct;

  ModelDataProdukGrup({
    String? productid,
    String? name,
    num? price,
    int? isActive,
    int? isPPN,
    String? typeproducts,
    String? productImage,
    required String discount_type,
    required int discount,
    this.kodeProduct,
  }) : super(
          productid: productid,
          name: name,
          price: price,
          isActive: isActive,
          isPPN: isPPN,
          typeproducts: typeproducts,
          productImage: productImage,
          discount_type: discount_type,
          discount: discount,
        );

  ModelDataProdukGrup.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    kodeProduct = json['kodeproduct'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['kodeproduct'] = kodeProduct;
    return data;
  }

  @override
  Map<String, dynamic> toMap() => toJson();
}
