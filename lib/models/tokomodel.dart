class ModelDataToko {
  String? merchantid;
  String? name;
  String? address;
  String? province;
  String? zipcode;
  String? district;
  String? village;
  String? regencies;
  String? logomerchant_url;

  ModelDataToko({
    required this.merchantid,
    required this.name,
    required this.address,
    required this.province,
    required this.zipcode,
    required this.district,
    required this.village,
    required this.regencies,
    required this.logomerchant_url,
  });

  ModelDataToko.fromJson(Map<String, dynamic> json) {
    merchantid = json['merchantid'];
    name = json['name'];
    address = json['address'];
    province = json['province'];
    zipcode = json['zipcode'];
    district = json['district'];
    village = json['village'];
    regencies = json['regencies'];
    logomerchant_url = json['logomerchant_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchantid'] = this.merchantid;
    data['name'] = this.name;
    data['address'] = this.address;
    data['province'] = this.province;
    data['zipcode'] = this.zipcode;
    data['district'] = this.district;
    data['village'] = this.village;
    data['regencies'] = this.regencies;
    data['logomerchant_url'] = this.logomerchant_url;
    return data;
  }
}

class DeleteToko {
  List<String>? merchantid;

  DeleteToko({required this.merchantid});

  DeleteToko.fromJson(Map<String, dynamic> json) {
    merchantid = json['merchantid'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchantid'] = this.merchantid;
    return data;
  }
}
