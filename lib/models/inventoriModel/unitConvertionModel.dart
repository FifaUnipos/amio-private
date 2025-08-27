class UnitConvertionModel {
  final String id;
  final String name;
  final String? convertionName;
  final String conversionFactor;
  // final String merchantId;
  // final String createdAt;
  // final String? updatedAt;
  // final String? deletedAt;

  UnitConvertionModel({
    required this.id,
    required this.name,
    required this.convertionName,
    required this.conversionFactor,
    // required this.merchantId,
    // required this.createdAt,
    // this.updatedAt,
    // this.deletedAt,
  });

  factory UnitConvertionModel.fromJson(Map<String, dynamic> json) {
    return UnitConvertionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      convertionName: json['conversion_name']?.toString(),
      conversionFactor: json['conversion_factor']?.toString() ?? '0',
      // merchantId: json['merchant_id']?.toString() ?? '',
      // createdAt: json['created_at']?.toString() ?? '',
      // updatedAt: json['updated_at']?.toString(),
      // deletedAt: json['deleted_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'conversion_name': convertionName,
      'conversion_factor': conversionFactor,
      // 'merchant_id': merchantId,
      // 'created_at': createdAt,
      // 'updated_at': updatedAt,
      // 'deleted_at': deletedAt,
    };
  }
}
