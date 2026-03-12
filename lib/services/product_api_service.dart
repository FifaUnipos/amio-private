import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/services/config/apimethod.dart';
import 'package:unipos_app_335/services/config/app_endpoints.dart';

class ProductApiService {
  Future<List<ModelDataProduk>?> fetchProducts({
    required String token,
    required String name,
    required String isactive,
    required List<String> merchid,
    required String orderby,
  }) async {
    try {
      final body = {
        "deviceid": identifier,
        "merchant_id": merchid,
        "name": name,
        "is_active": isactive,
        "order_by": orderby,
      };

      final response = await http.post(
        Uri.parse(ApiEndpoints.getProductUrl),
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

  Future<List<Map<String, dynamic>>?> fetchProductVariants({
    required String token,
    required String merchantId,
    required String productId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.getVariantLink),
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: json.encode({
          "deviceid": identifier,
          "merchant_id": merchantId,
          "product_id": productId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rc'] == '00') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return null;
    } catch (e) {
      print("Error in ProductApiService.fetchProductVariants: $e");
      return null;
    }
  }

  Future<String> createProduct(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.createProdukUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode({...data, "deviceid": identifier}),
    );
    return json.decode(response.body)['rc'];
  }

  Future<String> updateProduct(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.updateProdukUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode({...data, "deviceid": identifier}),
    );
    return json.decode(response.body)['rc'];
  }

  Future<String> deleteProduct(String token, List<String> ids, String merchId) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.deleteProdukUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode({"id": ids, "merchant_id": merchId, "deviceid": identifier}),
    );
    return json.decode(response.body)['rc'];
  }

  Future<String> changePpn(String token, String status, List<String> ids, String merchId) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.changePpnUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode({"id": ids, "status": status, "merchant_id": merchId, "deviceid": identifier}),
    );
    return json.decode(response.body)['rc'];
  }

  Future<String> changeActive(String token, String status, List<String> ids, String merchId) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.changeActiveUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode({"id": ids, "status": status, "merchant_id": merchId, "deviceid": identifier}),
    );
    return json.decode(response.body)['rc'];
  }
}
