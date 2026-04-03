import 'dart:convert';

import 'package:unipos_app_335/data/model/product/product_sorting_response.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:http/http.dart' as http;

class ProductSortingService {
  Future<ProductSortingResponse> getProductSorting(
    String token,
    String merchantId,
    String name,
    String orderBy,
  ) async {
    final response = await http.post(
      Uri.parse(ApiProduct.getProduct),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "deviceid": identifier,
        "merchant_id": [merchantId],
        "name": name,
        "order_by": orderBy,
      }),
    );

    if (response.statusCode == 200) {
      return ProductSortingResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load transaction deleted history');
    }
  }
}
