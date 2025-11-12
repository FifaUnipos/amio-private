class Product {
  final String? name;
  final int? qty;

  Product({this.name, this.qty});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      qty: json['qty'],
    );
  }
}

class ProductData {
  final List<Product>? topThree;
  final List<Product>? underThree;

  ProductData({this.topThree, this.underThree});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    // Buat list dengan objek Product dari setiap element di topThree dan underThree
    final topThree = <Product>[];
    for (var product in json['top-three']) {
      topThree.add(Product.fromJson(product));
    }
    final underThree = <Product>[];
    for (var product in json['under-three']) {
      underThree.add(Product.fromJson(product));
    }
    return ProductData(topThree: topThree, underThree: underThree);
  }
}
