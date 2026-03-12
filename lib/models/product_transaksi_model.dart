import 'package:unipos_app_335/models/produkmodel.dart';

class ProductTransaksi {
  final String id;
  final String name;
  final int price;
  final int onlinePrice;
  final int? priceAfter;
  final double? discount;
  final String? discountType;
  final String category;
  final String? imageUrl;
  final bool? isCustomize;
  final int? isPPN;

  ProductTransaksi({
    required this.id,
    required this.name,
    required this.price,
    required this.onlinePrice,
    this.priceAfter,
    this.discount,
    this.discountType,
    required this.category,
    this.imageUrl,
    this.isCustomize,
    this.isPPN,
  });

  static int _toInt(dynamic v, {int def = 0}) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is bool) return v ? 1 : 0;

    final s = v.toString().trim();
    if (s.isEmpty) return def;

    // Handle decimal strings like "11100.0"
    final d = double.tryParse(s);
    if (d != null) return d.round();

    return def;
  }

  static int? _toNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v == 1;
    final s = v.toString().trim().toLowerCase();
    return s == '1' || s == 'true';
  }

  factory ProductTransaksi.fromJson(Map<String, dynamic> json) {
    // Extensive ID fallbacks
    final idStr = (json['product_id'] ?? 
                  json['productid'] ?? 
                  json['id_product'] ?? 
                  json['id_produk'] ?? 
                  json['idproduk'] ?? 
                  json['id'] ?? 
                  json['idproduct'] ?? 
                  '').toString();

    // Extensive Price fallbacks
    final dynamic rawPrice = json['price'] ?? 
                            json['amount'] ?? 
                            json['price_online_shop'] ??
                            json['total_amount'] ?? 
                            json['total'] ?? 
                            json['harga'] ?? 
                            0;

    return ProductTransaksi(
      id: idStr.isEmpty ? '' : idStr,
      name: json['name'] ?? json['product_name'] ?? json['nama_produk'] ?? json['nama'] ?? 'Unknown',
      price: _toInt(rawPrice),
      onlinePrice: _toInt(json['price_online_shop'] ?? rawPrice),
      priceAfter: _toNullableInt(json['price_after']),
      discount: (json['discount'] as num?)?.toDouble(),
      discountType: json['discount_type'],
      category: json['typeproducts'] ?? json['category'] ?? json['nama_kategori'] ?? '',
      imageUrl: json['product_image'] ?? json['image'] ?? json['thumbnail'],
      isCustomize: _toBool(json['is_customize']),
      isPPN: _toInt(json['isPPN'] ?? json['is_ppn']),
    );
  }
}

class ProductVariant {
  final String id;
  final String name;
  final String price;
  final String isActive;

  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      isActive: json['is_active']?.toString() ?? '0',
    );
  }
}

class ProductVariantCategory {
  final String id;
  final String title;
  final int isRequired;
  final int maximumSelected;
  final List<ProductVariant> productVariants;

  ProductVariantCategory({
    required this.id,
    required this.title,
    required this.isRequired,
    required this.maximumSelected,
    required this.productVariants,
  });

  factory ProductVariantCategory.fromJson(Map<String, dynamic> json) {
    var list = json['product_variants'] as List? ?? [];
    List<ProductVariant> variantList = list
        .map((i) => ProductVariant.fromJson(i))
        .toList();

    return ProductVariantCategory(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? '',
      isRequired: int.tryParse(json['is_required']?.toString() ?? '0') ?? 0,
      maximumSelected: int.tryParse(json['maximum_selected']?.toString() ?? '0') ?? 0,
      productVariants: variantList,
    );
  }
}
