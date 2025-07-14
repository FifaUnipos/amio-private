class DetailItem {
  final String groupId;
  final String itemId;
  final String nameItem;
  final String unitId;
  final String unitName;
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
      unitAbbreviation: json['unit_abbreviation'],
      qty: json['qty'],
      qtyAfterActivity: json['qty_after_activity'],
      price: json['price'],
      activityType: json['activity_type'],
      date: json['date'],
    );
  }
}
