import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/services/apimethod.dart';

class ProductApiService {
  Future<List<ModelDataProduk>?> fetchProducts({
    required String token,
    required String name,
    required List<String> merchid,
    required String orderby,
  }) async {
    try {
      final body = {
        "deviceid": identifier,
        "merchantid": merchid,
        "name": name,
        "order_by": orderby,
      };

      final response = await http.post(
        Uri.parse(getProductUrl),
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['rc'] == '00') {
          final List<ModelDataProduk> result = [];
          for (Map<String, dynamic> item in jsonResponse['data']) {
            result.add(ModelDataProduk.fromJson(item));
          }
          return result;
        }
      }
      return null;
    } catch (e) {
      print("Error in ProductApiService.fetchProducts: $e");
      return null;
    }
  }
}
