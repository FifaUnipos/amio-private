class UserModel {
  String? userid;
  String? fullname;
  String? phonenumber;
  String? merchantid;
  String? groupmerchantid;
  String? usertype;
  String? email;
  String? role;
  String? accountImage;
  String? status;

  UserModel({
    this.userid,
    this.fullname,
    this.phonenumber,
    this.merchantid,
    this.groupmerchantid,
    this.usertype,
    this.email,
    this.role,
    this.accountImage,
    this.status,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    fullname = json['fullname'];
    phonenumber = json['phonenumber'];
    merchantid = json['merchantid'];
    groupmerchantid = json['groupmerchantid'];
    usertype = json['usertype'];
    email = json['email'];
    role = json['role'];
    accountImage = json['account_image'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['fullname'] = fullname;
    data['phonenumber'] = phonenumber;
    data['merchantid'] = merchantid;
    data['groupmerchantid'] = groupmerchantid;
    data['usertype'] = usertype;
    data['email'] = email;
    data['role'] = role;
    data['account_image'] = accountImage;
    data['status'] = status;
    return data;
  }
}
