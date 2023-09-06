class PelangganModelData {
  String? merchantid;
  String? memberid;
  String? namaMember;
  String? alamatMember;
  String? phonenumber;
  String? email;
  String? twitterAccount;
  String? instagramAccount;
  String? facebookAccount;
  int? saldo;

  PelangganModelData(
      {this.merchantid,
      this.memberid,
      this.namaMember,
      this.alamatMember,
      this.phonenumber,
      this.email,
      this.twitterAccount,
      this.instagramAccount,
      this.facebookAccount,
      this.saldo});

  PelangganModelData.fromJson(Map<String, dynamic> json) {
    merchantid = json['merchantid'];
    memberid = json['memberid'];
    namaMember = json['nama_member'];
    alamatMember = json['alamat_member'];
    phonenumber = json['phonenumber'];
    email = json['email'];
    twitterAccount = json['twitter_account'];
    instagramAccount = json['instagram_account'];
    facebookAccount = json['facebook_account'];
    saldo = json['saldo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchantid'] = this.merchantid;
    data['memberid'] = this.memberid;
    data['nama_member'] = this.namaMember;
    data['alamat_member'] = this.alamatMember;
    data['phonenumber'] = this.phonenumber;
    data['email'] = this.email;
    data['twitter_account'] = this.twitterAccount;
    data['instagram_account'] = this.instagramAccount;
    data['facebook_account'] = this.facebookAccount;
    data['saldo'] = this.saldo;
    return data;
  }
}
