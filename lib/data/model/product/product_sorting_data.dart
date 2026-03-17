class ProductSortingData {
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

  ProductSortingData({
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
  ProductSortingData copyWith({
    String? productid,
    String? name,
    num? price,
    num? price_after,
    num? price_online_shop,
    num? price_online_shop_after,
    int? isActive,
    int? isPPN,
    String? typeproducts,
    String? productImage,
    String? discount_type,
    int? discount,
  }) {
    return ProductSortingData(
      productid: productid ?? this.productid,
      name: name ?? this.name,
      price: price ?? this.price,
      price_after: price_after ?? this.price_after,
      price_online_shop: price_online_shop ?? this.price_online_shop,
      price_online_shop_after:
          price_online_shop_after ?? this.price_online_shop_after,
      isActive: isActive ?? this.isActive,
      isPPN: isPPN ?? this.isPPN,
      typeproducts: typeproducts ?? this.typeproducts,
      productImage: productImage ?? this.productImage,
      discount_type: discount_type ?? this.discount_type,
      discount: discount ?? this.discount,
    );
  }

  factory ProductSortingData.fromJson(Map<String, dynamic> json) {
    return ProductSortingData(
      productid: (json['productid']).toString(),
      name: (json['name']).toString(),
      price: (json['price']),
      price_after: (json['price_after']),
      price_online_shop: (json['price_online_shop']),
      price_online_shop_after: (json['price_online_shop_after']),
      isActive: (json['isActive']),
      isPPN: (json['isPPN']),
      typeproducts: (json['typeproducts']).toString(),
      productImage: (json['product_image']).toString(),
      discount_type: (json['discount_type']).toString(),
      discount: (json['discount']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ProductSortingData = new Map<String, dynamic>();
    ProductSortingData['productid'] = this.productid;
    ProductSortingData['name'] = this.name;
    ProductSortingData['price'] = this.price;
    ProductSortingData['price_after'] = this.price_after;
    ProductSortingData['price_online_shop'] = this.price_online_shop;
    ProductSortingData['price_online_shop_after'] =
        this.price_online_shop_after;
    ProductSortingData['isActive'] = this.isActive;
    ProductSortingData['isPPN'] = this.isPPN;
    ProductSortingData['typeproducts'] = this.typeproducts;
    ProductSortingData['product_image'] = this.productImage;
    ProductSortingData['discount_type'] = this.discount_type;
    ProductSortingData['discount'] = this.discount_type;
    return ProductSortingData;
  }
}
