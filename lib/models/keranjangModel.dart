class CartTransaksi {
  String? name;
  String? productid;
  String? image;
  String? desc;
  String idRequest = "";
  num? price;
  num? baseUsed;
  num quantity = 1;
  String? variants;

  bool isOnline;
  bool isCustomize;

  CartTransaksi({
    required this.name,
    required this.productid,
    required this.image,
    required this.desc,
    required this.price,
    required this.quantity,
    required this.idRequest,
    this.variants,
    this.baseUsed,
    this.isOnline = false,
    this.isCustomize = false,
  });
}
