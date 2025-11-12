class RekonModel {
  String? rekonid;
  String? bulanTahun;
  String? hari;
  int? statusBD;
  int? statusTS;
  int? statusS;
  List<DetailRekon>? detail;
  bool expanded = false;

  RekonModel({
    this.rekonid,
    this.bulanTahun,
    this.hari,
    this.statusBD,
    this.statusTS,
    this.statusS,
    this.detail,
    this.expanded = false,
  });

  void refresh() {
    expanded = false;
    expanded = !expanded;
    // print(expanded);
  }

  RekonModel.fromJson(Map<String, dynamic> json) {
    rekonid = json['rekonid'];
    bulanTahun = json['bulanTahun'];
    hari = json['hari'];
    statusBD = json['statusBD'];
    statusTS = json['statusTS'];
    statusS = json['statusS'];
    if (json['detail'] != null) {
      detail = <DetailRekon>[];
      json['detail'].forEach((v) {
        detail?.add(new DetailRekon.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rekonid'] = this.rekonid;
    data['bulanTahun'] = this.bulanTahun;
    data['hari'] = this.hari;
    data['statusBD'] = this.statusBD;
    data['statusTS'] = this.statusTS;
    data['statusS'] = this.statusS;
    if (this.detail != null) {
      data['detail'] = this.detail?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DetailRekon {
  String? rekonid;
  String? paymentMethod;
  String? namePayment;
  int? value;
  String? status;
  String? deskripsi;
  String? kodeReference;

  DetailRekon(
      {this.rekonid,
      this.paymentMethod,
      this.namePayment,
      this.value,
      this.status,
      this.deskripsi,
      this.kodeReference});

  DetailRekon.fromJson(Map<String, dynamic> json) {
    rekonid = json['rekonid'];
    paymentMethod = json['payment_method'];
    namePayment = json['name_payment'];
    value = json['value'];
    status = json['status'];
    deskripsi = json['deskripsi'];
    kodeReference = json['kode_reference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rekonid'] = this.rekonid;
    data['payment_method'] = this.paymentMethod;
    data['name_payment'] = this.namePayment;
    data['value'] = this.value;
    data['status'] = this.status;
    data['deskripsi'] = this.deskripsi;
    data['kode_reference'] = this.kodeReference;
    return data;
  }
}
