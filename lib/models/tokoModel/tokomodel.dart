class TokoModelToko {
  String? merchantid;
  String? name;
  String? address;
  String? logomerchantUrl;
  String? createdAt;

  TokoModelToko({
    this.merchantid,
    this.name,
    this.address,
    this.logomerchantUrl,
    this.createdAt,
  });

  factory TokoModelToko.fromJson(Map<String, dynamic> json) {
    return TokoModelToko(
      merchantid: json['merchantid'],
      name: json['name'],
      address: json['address'],
      logomerchantUrl: json['logomerchantUrl'],
      createdAt: json['createdAt'],
    );
  }
}

