class ProdukMaterialModel {
  final String id;
  final String inventoryMasterId;
  final String quantityNeeded;
  final String unitConversionId;
  final String itemName;
  final String unit;
  final String unitName;
  final String unitAbbreviation;
  final String unitConversionName;
  final String unitConversionFactor;

  ProdukMaterialModel({
    required this.id,
    required this.inventoryMasterId,
    required this.quantityNeeded,
    required this.unitConversionId,
    required this.itemName,
    required this.unit,
    required this.unitName,
    required this.unitAbbreviation,
    required this.unitConversionName,
    required this.unitConversionFactor,
  });

  factory ProdukMaterialModel.fromJson(Map<String, dynamic> json) {
    return ProdukMaterialModel(
      id: json['inventory_master_id'],
      inventoryMasterId: json['inventory_master_id'],
      quantityNeeded: json['quantity_needed'],
      unitConversionId: json['unit_conversion_id'] ?? '',
      itemName: json['item_name'],
      unit: json['unit'],
      unitName: json['unit_name'],
      unitAbbreviation: json['unit_abbreviation'],
      unitConversionName: json['unit_conversion_name'] ?? json['unit_name'],
      unitConversionFactor: json['unit_conversion_factor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_master_id': inventoryMasterId,
      'quantity_needed': quantityNeeded,
      'unit_conversion_id': unitConversionId,
      'item_name': itemName,
      'unit': unit,
      'unit_name': unitName,
      'unit_abbreviation': unitAbbreviation,
      'unit_conversion_name': unitConversionName,
      'unit_conversion_factor': unitConversionFactor,
    };
  }
}
