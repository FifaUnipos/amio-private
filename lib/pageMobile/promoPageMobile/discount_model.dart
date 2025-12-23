class DiscountModel {
  final String id;
  final String name;
  final int discount;
  final String discountType; // 'price' or 'percentage'
  final bool isActive;
  final String type; // 'per_produk' or 'umum' (or other API values)
  final String date; // Display date string e.g. "Selamanya"
  final String startDate;
  final String endDate;

  DiscountModel({
    required this.id,
    required this.name,
    required this.discount,
    required this.discountType,
    required this.isActive,
    required this.type,
    required this.date,
    required this.startDate,
    required this.endDate,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      discount: int.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      discountType: json['discount_type'] ?? 'price',
      isActive: json['is_active'] == true || json['is_active'].toString().toLowerCase() == 'true',
      type: json['type'] ?? 'umum',
      date: json['date'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

class DiscountProductModel {
  final String productId;
  final String name;
  final String productImage;
  final int price;
  final String discountStatus;
  final String discountId;
  bool isSelected; // Helper for UI selection

  DiscountProductModel({
    required this.productId,
    required this.name,
    required this.productImage,
    required this.price,
    this.discountStatus = '',
    this.discountId = '',
    this.isSelected = false,
  });

  factory DiscountProductModel.fromJson(Map<String, dynamic> json) {
    return DiscountProductModel(
      productId: json['productid']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      discountStatus: json['discount_status']?.toString() ?? '',
      discountId: json['discount_id']?.toString() ?? '',
    );
  }
}
