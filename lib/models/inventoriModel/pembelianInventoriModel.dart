class PembelianModel {
  String? groupId;
  String? title;
  String? activityDate;
  double? totalPrice;

  PembelianModel({
    this.groupId,
    this.title,
    this.activityDate,
    this.totalPrice,
  });

  PembelianModel.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id'];
    title = json['title'];
    activityDate = json['activity_date'];
    totalPrice = double.tryParse(json['total_price'] ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_id'] = groupId;
    data['title'] = title;
    data['activity_date'] = activityDate;
    data['total_price'] = totalPrice;
    return data;
  }
}
