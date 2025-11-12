class ModelDataDiskon {
  String? id;
  String? name;
  num? discount;
  String? discount_type;
  bool? is_active;
  String? start_date;
  String? end_date;
  String? type;
  String? date;

  ModelDataDiskon({
    this.id,
    this.name,
    this.discount,
    this.discount_type,
    this.is_active,
    this.start_date,
    this.end_date,
    this.type,
    this.date,
  });

  ModelDataDiskon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    discount = json['discount'];
    discount_type = json['discount_type'];
    is_active = json['is_active'];
    start_date = json['start_date'];
    end_date = json['end_date'];
    type = json['type'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ModelDataDiskon = new Map<String, dynamic>();
    ModelDataDiskon['id'] = this.id;
    ModelDataDiskon['name'] = this.name;
    ModelDataDiskon['discount'] = this.discount;
    ModelDataDiskon['discount_type'] = this.discount_type;
    ModelDataDiskon['is_active'] = this.is_active;
    ModelDataDiskon['start_date'] = this.start_date;
    ModelDataDiskon['end_date'] = this.end_date;
    ModelDataDiskon['type'] = this.type;
    ModelDataDiskon['date'] = this.date;
    return ModelDataDiskon;
  }
}
