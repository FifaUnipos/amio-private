class CartTransaksi {
  String? name;
  String? productid;
  String? image;
  String? desc;
  int? price;
  int quantity = 1;
  CartTransaksi({
    required this.name,
    required this.productid,
    required this.image,
    required this.desc,
    required this.price,
    required this.quantity,
  });
}
