class MerchantDetailModel {
  final String merchantId;
  final String name;
  final String address;
  final String zipcode;
  final String namaProvince;
  final String kodeProvince;
  final String namaRegencies;
  final String kodeRegencies;
  final String namaDistrict;
  final String kodeDistrict;
  final String namaVillage;
  final String kodeVillage;
  final String namaTipeUsaha;
  final String tipeUsahaId;
  final String logomerchantUrl;

  MerchantDetailModel({
    required this.merchantId,
    required this.name,
    required this.address,
    required this.zipcode,
    required this.namaProvince,
    required this.kodeProvince,
    required this.namaRegencies,
    required this.kodeRegencies,
    required this.namaDistrict,
    required this.kodeDistrict,
    required this.namaVillage,
    required this.kodeVillage,
    required this.namaTipeUsaha,
    required this.tipeUsahaId,
    required this.logomerchantUrl,
  });

  factory MerchantDetailModel.fromJson(Map<String, dynamic> json) {
    return MerchantDetailModel(
      merchantId: json['merchantid'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      zipcode: json['zipcode'] ?? '',
      namaProvince: json['nama_province'] ?? '',
      kodeProvince: json['kode_province'] ?? '',
      namaRegencies: json['nama_regencies'] ?? '',
      kodeRegencies: json['kode_regencies'] ?? '',
      namaDistrict: json['nama_district'] ?? '',
      kodeDistrict: json['kode_district'] ?? '',
      namaVillage: json['nama_village'] ?? '',
      kodeVillage: json['kode_village'] ?? '',
      namaTipeUsaha: json['nama_tipe_usaha'] ?? '',
      tipeUsahaId: json['tipeusaha'] ?? '',
      logomerchantUrl: json['logomerchant_url'] ?? '',
    );
  }
}
