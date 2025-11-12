class ModelDataAkun {
  String? userid;
  String? fullname;
  String? usertype;
  String? merchantid;
  String? groupmerchantid;
  String? phonenumber;
  String? email;
  String? status;
  String? email_verified;
  String? account_image;
  String? role;
  String? created_at;

  ModelDataAkun({
    required this.userid,
    required this.fullname,
    required this.usertype,
    required this.merchantid,
    required this.groupmerchantid,
    required this.phonenumber,
    required this.email,
    required this.status,
    required this.email_verified,
    required this.account_image,
    required this.role,
    required this.created_at,
  });

  ModelDataAkun.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    fullname = json['fullname'];
    usertype = json['usertype'];
    merchantid = json['merchantid'];
    groupmerchantid = json['groupmerchantid'];
    phonenumber = json['phonenumber'];
    email = json['email'];
    status = json['status'];
    email_verified = json['email_verified'];
    account_image = json['account_image'];
    role = json['role'];
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userid'] = this.userid;
    data['fullname'] = this.fullname;
    data['usertype'] = this.usertype;
    data['merchantid'] = this.merchantid;
    data['groupmerchantid'] = this.groupmerchantid;
    data['phonenumber'] = this.phonenumber;
    data['email'] = this.email;
    data['status'] = this.status;
    data['email_verified'] = this.email_verified;
    data['account_image'] = this.account_image;
    data['role'] = this.role;
    data['created_at'] = this.created_at;
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
