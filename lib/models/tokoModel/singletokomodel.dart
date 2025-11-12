class SingleDataToko {
  String? merchantid;
  String? name;
  String? address;
  String? kode_province;
  String? province;
  String? kode_regencies;
  String? regencies;
  String? kode_district;
  String? district;
  String? kode_village;
  String? village;
  String? logomerchant_url;
  String? qris_image;
  String? fifapayid;
  String? tipeusaha;
  String? zipcode;
  String? created_at;

  SingleDataToko({
    required this.merchantid,
    required this.name,
    required this.address,
    required this.kode_province,
    required this.province,
    required this.kode_regencies,
    required this.regencies,
    required this.kode_district,
    required this.district,
    required this.kode_village,
    required this.village,
    required this.zipcode,
    required this.logomerchant_url,
    required this.qris_image,
    required this.tipeusaha,
    required this.created_at,
  });

  SingleDataToko.fromJson(Map<String, dynamic> json) {
    merchantid = json['merchantid'];
    name = json['name'];
    address = json['address'];
    kode_province = json['kode_province'];
    province = json['nama_province'];
    kode_regencies = json['kode_regencies'];
    regencies = json['nama_regencies'];
    kode_district = json['kode_district'];
    district = json['nama_district'];
    kode_village = json['kode_village'];
    village = json['nama_village'];
    zipcode = json['zipcode'];
    logomerchant_url = json['logomerchant_url'];
    qris_image = json['qris_image'];
    tipeusaha = json['tipeusaha'];
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchantid'] = this.merchantid;
    data['name'] = this.name;
    data['address'] = this.address;
    data['kode_province'] = this.kode_province;
    data['nama_province'] = this.province;
    data['kode_regencies'] = this.kode_regencies;
    data['nama_regencies'] = this.regencies;
    data['kode_district'] = this.kode_district;
    data['nama_district'] = this.district;
    data['kode_village'] = this.kode_village;
    data['nama_village'] = this.village;
    data['zipcode'] = this.zipcode;
    data['logomerchant_url'] = this.logomerchant_url;
    data['qris_image'] = this.qris_image;
    data['fifapayid'] = this.fifapayid;
    data['tipeusaha'] = this.tipeusaha;
    data['created_at'] = this.created_at;

    return data;
  }
}
