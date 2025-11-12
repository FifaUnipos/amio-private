class TipeUsahaModel {
  final String id;
  final String nama;

  TipeUsahaModel({required this.id, required this.nama});

  factory TipeUsahaModel.fromJson(Map<String, dynamic> json) {
    return TipeUsahaModel(
      id: json['tipeusaha_id'].toString(),
      nama: json['nama_tipe'] ?? '',
    );
  }
}

class WilayahModel {
  final String id;
  final String name;

  WilayahModel({required this.id, required this.name});

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    return WilayahModel(id: json['ID'].toString(), name: json['NAME'] ?? '');
  }
}
