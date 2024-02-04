class CartTransaksi {
  String? name;
  String? productid;
  String? image;
  String? desc;
  num? price;
  num quantity = 1;
  CartTransaksi({
    required this.name,
    required this.productid,
    required this.image,
    required this.desc,
    required this.price,
    required this.quantity,
  });
}
