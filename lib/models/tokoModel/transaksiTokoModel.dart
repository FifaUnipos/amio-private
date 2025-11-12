class ProductModel {
  String? id;
  String? productid;
  String? name;
  num? price;
  num? price_after;
  num? price_online_shop;
  num? price_online_shop_after;
  int? isActive;
  int? isPPN;
  String? typeproducts;
  String? product_image;
  String? discount_type;
  int? discount;
  List<VariantCategory> variants;

  ProductModel({
    this.id,
    this.productid,
    this.name,
    this.price,
    this.price_after,
    this.price_online_shop,
    this.price_online_shop_after,
    this.isActive,
    this.isPPN,
    this.typeproducts,
    this.product_image,
    this.discount_type,
    this.discount,
    this.variants = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      productid: json['productid']?.toString(),
      name: json['name'] ?? '',
      price: _toNum(json['price']),
      price_after: _toNum(json['price_after']),
      price_online_shop: _toNum(json['price_online_shop']),
      price_online_shop_after: _toNum(json['price_online_shop_after']),
      isActive: _toInt(json['is_active']),
      isPPN: _toInt(json['is_ppn']),
      typeproducts: json['typeproducts'] ?? '',
      product_image: json['product_image'] ?? '',
      discount_type: json['discount_type'] ?? '',
      discount: _toInt(json['discount']),
      variants:
          (json['variants'] as List?)
              ?.map((v) => VariantCategory.fromJson(v))
              .toList() ??
          [],
    );
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class VariantCategory {
  String? variantCategoryId;
  String? variantCategoryTitle;
  int? variantCategoryMaximum;
  int? variantCategoryIsRequired;
  List<VariantOption> variants;

  VariantCategory({
    this.variantCategoryId,
    this.variantCategoryTitle,
    this.variantCategoryMaximum,
    this.variantCategoryIsRequired,
    this.variants = const [],
  });

  factory VariantCategory.fromJson(Map<String, dynamic> json) {
    return VariantCategory(
      variantCategoryId: json['variant_category_id']?.toString(),
      variantCategoryTitle: json['variant_category_title'] ?? '',
      variantCategoryMaximum: ProductModel._toInt(
        json['variant_category_maximum'],
      ),
      variantCategoryIsRequired: ProductModel._toInt(
        json['variant_category_is_required'],
      ),
      variants:
          (json['variants'] as List?)
              ?.map((v) => VariantOption.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class VariantOption {
  String? variantProductId;
  String? variantProductName;
  num? variantProductPrice;
  num? variantProductPriceOnlineShop;

  VariantOption({
    this.variantProductId,
    this.variantProductName,
    this.variantProductPrice,
    this.variantProductPriceOnlineShop,
  });

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      variantProductId: json['variant_product_id']?.toString(),
      variantProductName: json['variant_product_name'] ?? '',
      variantProductPrice: ProductModel._toNum(json['variant_product_price']),
      variantProductPriceOnlineShop: ProductModel._toNum(
        json['variant_product_price_online_shop'],
      ),
    );
  }
}

class CoinModel {
  String? voucherid;
  String? namavoucher;
  String? merchantid;
  int? point;
  int? harga;
  int? isActive;
  int? isDelete;

  CoinModel({
    this.voucherid,
    this.namavoucher,
    this.merchantid,
    this.point,
    this.harga,
    this.isActive,
    this.isDelete,
  });

  CoinModel.fromJson(Map<String, dynamic> json) {
    voucherid = json['voucherid'];
    namavoucher = json['namavoucher'];
    merchantid = json['merchantid'];
    point = json['point'];
    harga = json['harga'];
    isActive = json['isActive'];
    isDelete = json['isDelete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voucherid'] = this.voucherid;
    data['namavoucher'] = this.namavoucher;
    data['merchantid'] = this.merchantid;
    data['point'] = this.point;
    data['harga'] = this.harga;
    data['isActive'] = this.isActive;
    data['isDelete'] = this.isDelete;
    return data;
  }
}

class DeleteToko {
  List<String>? merchantid;

  DeleteToko({required this.merchantid});

  DeleteToko.fromJson(Map<String, dynamic> json) {
    merchantid = json['merchantid'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchantid'] = this.merchantid;
    return data;
  }
}
