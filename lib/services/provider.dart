import 'package:flutter/material.dart';

class ProductVariantProvider extends ChangeNotifier {
  List<dynamic> _productVariants = [];

  List<dynamic> get productVariants => _productVariants;

  void setProductData(List<dynamic> newData) {
    _productVariants = newData;
    notifyListeners();
  }

  void clear() {
    _productVariants = [];
    notifyListeners();
  }
}
