class PendapatanLainModel {
  String? peruntukanPPM;
  String? jenis;
  String? tanggal;
  String? deskripsi;
  int? jumlah;
  String? merchantid;
  String? pPMID;

  PendapatanLainModel(
      {this.peruntukanPPM,
      this.jenis,
      this.tanggal,
      this.deskripsi,
      this.jumlah,
      this.merchantid,
      this.pPMID});

  PendapatanLainModel.fromJson(Map<String, dynamic> json) {
    peruntukanPPM = json['peruntukan_PPM'];
    jenis = json['jenis'];
    tanggal = json['tanggal'];
    deskripsi = json['deskripsi'];
    jumlah = json['jumlah'];
    merchantid = json['merchantid'];
    pPMID = json['PPM_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['peruntukan_PPM'] = this.peruntukanPPM;
    data['jenis'] = this.jenis;
    data['tanggal'] = this.tanggal;
    data['deskripsi'] = this.deskripsi;
    data['jumlah'] = this.jumlah;
    data['merchantid'] = this.merchantid;
    data['PPM_ID'] = this.pPMID;
    return data;
  }
}

class PengeluaranLainModel {
  String? peruntukanPPM;
  String? jenis;
  String? tanggal;
  String? deskripsi;
  int? jumlah;
  String? merchantid;
  String? pPMID;

  PengeluaranLainModel(
      {this.peruntukanPPM,
      this.jenis,
      this.tanggal,
      this.deskripsi,
      this.jumlah,
      this.merchantid,
      this.pPMID});

  PengeluaranLainModel.fromJson(Map<String, dynamic> json) {
    peruntukanPPM = json['peruntukan_PPM'];
    jenis = json['jenis'];
    tanggal = json['tanggal'];
    deskripsi = json['deskripsi'];
    jumlah = json['jumlah'];
    merchantid = json['merchantid'];
    pPMID = json['PPM_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['peruntukan_PPM'] = this.peruntukanPPM;
    data['jenis'] = this.jenis;
    data['tanggal'] = this.tanggal;
    data['deskripsi'] = this.deskripsi;
    data['jumlah'] = this.jumlah;
    data['merchantid'] = this.merchantid;
    data['PPM_ID'] = this.pPMID;
    return data;
  }
}
