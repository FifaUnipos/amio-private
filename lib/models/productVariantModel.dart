class ProductVariantCategory {
  final String id;
  final String title;
  final int maximumSelected;
  final int isActive;
  final int isRequired;
  final String productId;
  final String name;
  final List<ProductVariant> productVariants;

  ProductVariantCategory({
    required this.id,
    required this.title,
    required this.maximumSelected,
    required this.isActive,
    required this.isRequired,
    required this.productId,
    required this.name,
    required this.productVariants,
  });

  factory ProductVariantCategory.fromJson(Map<String, dynamic> json) {
    return ProductVariantCategory(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      maximumSelected: json['maximum_selected'] ?? 0,
      isActive: json['is_active'] ?? 0,
      isRequired: json['is_required'] ?? 0,
      productId: json['productid'] ?? '',
      name: json['name'] ?? '',
      productVariants: (json['product_variants'] as List<dynamic>?)
              ?.map((v) => ProductVariant.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class ProductVariant {
  final String id;
  final String name;
  final String price;
  final String priceOnlineShop;
  final int isActive;
  final String variantCategoryId;

  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.priceOnlineShop,
    required this.isActive,
    required this.variantCategoryId,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      priceOnlineShop: json['price_online_shop'] ?? '0',
      isActive: json['is_active'] ?? 0,
      variantCategoryId: json['variant_category_id'] ?? '',
    );
  }
}
