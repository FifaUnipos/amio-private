class ProductModel {
  String? productid;
  String? name;
  int? price;
  int? price_online_shop;
  // String? isActive;
  int? isActive;
  int? isPPN;
  String? typeproducts;
  String? product_image;

  ProductModel({
    required this.productid,
    required this.name,
    required this.price,
    required this.price_online_shop,
    required this.isActive,
    required this.isPPN,
    required this.typeproducts,
    required this.product_image,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    name = json['name'];
    price = json['price'];
    price_online_shop = json['price_online_shop'];
    isActive = json['isActive'];
    isPPN = json['isPPN'];
    typeproducts = json['typeproducts'];
    product_image = json['product_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productid'] = this.productid;
    data['name'] = this.name;
    data['price'] = this.price;
    data['price_online_shop'] = this.price_online_shop;
    data['isActive'] = this.isActive;
    data['isPPN'] = this.isPPN;
    data['typeproducts'] = this.typeproducts;
    data['product_image'] = this.product_image;
    return data;
  }
}

class CoinModel {
  String? voucherid;
  String? namavoucher;
  String? merchantid;
  int? point;
  int? harga;
  int? isActive;
  int? isDelete;

  CoinModel(
      {this.voucherid,
      this.namavoucher,
      this.merchantid,
      this.point,
      this.harga,
      this.isActive,
      this.isDelete});

  CoinModel.fromJson(Map<String, dynamic> json) {
    voucherid = json['voucherid'];
    namavoucher = json['namavoucher'];
    merchantid = json['merchantid'];
    point = json['point'];
    harga = json['harga'];
    isActive = json['isActive'];
    isDelete = json['isDelete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voucherid'] = this.voucherid;
    data['namavoucher'] = this.namavoucher;
    data['merchantid'] = this.merchantid;
    data['point'] = this.point;
    data['harga'] = this.harga;
    data['isActive'] = this.isActive;
    data['isDelete'] = this.isDelete;
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
