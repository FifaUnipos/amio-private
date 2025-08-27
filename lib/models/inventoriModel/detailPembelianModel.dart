class DetailItem {
  final String groupId;
  final String itemId;
  final String nameItem;
  final String unitId;
  final String unitName;
  final String unit_conversion_id;
  final String unit_conversion_name;
  final String conversion_factor;
  final String unitAbbreviation;
  final String qty;
  final String qtyAfterActivity;
  final String price;
  final String activityType;
  final String date;

  DetailItem({
    required this.groupId,
    required this.itemId,
    required this.nameItem,
    required this.unitId,
    required this.unitName,
    required this.unit_conversion_id,
    required this.unit_conversion_name,
    required this.conversion_factor,
    required this.unitAbbreviation,
    required this.qty,
    required this.qtyAfterActivity,
    required this.price,
    required this.activityType,
    required this.date,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      groupId: json['group_id'],
      itemId: json['item_id'],
      nameItem: json['name_item'],
      unitId: json['unit_id'],
      unitName: json['unit_name'],
      unit_conversion_id: json['unit_conversion_id'].toString(),
      unit_conversion_name: json['unit_conversion_name'] != null
          ? json['unit_conversion_name'].toString()
          : json['unit_name'].toString(),
      conversion_factor: json['conversion_factor'].toString(),
      unitAbbreviation: json['unit_abbreviation'].toString(),
      qty: json['qty'],
      qtyAfterActivity: json['qty_after_activity'],
      price: json['price'],
      activityType: json['activity_type'],
      date: json['date'],
    );
  }

  // Tambahkan metode toJson() untuk mengonversi DetailItem menjadi Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'item_id': itemId,
      'name_item': nameItem,
      'unit_id': unitId,
      'unit_name': unitName,
      'unit_conversion_id': unit_conversion_id,
      'unit_conversion_name': unit_conversion_name,
      'conversion_factor': conversion_factor,
      'unit_abbreviation': unitAbbreviation,
      'qty': qty,
      'qty_after_activity': qtyAfterActivity,
      'price': price,
      'activity_type': activityType,
      'date': date,
    };
  }
}
