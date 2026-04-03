import 'dart:convert';

import 'package:unipos_app_335/data/model/merchant/merchant_sorting_response.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:http/http.dart' as http;

class MerchantSortingService {
  Future<MerchantSortingResponse> getMerchantSorting(
    String token,
    String name,
    String orderBy,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final response = await http.post(
      Uri.parse(getMerch),
      headers: {'token': token},
      body: {
        "deviceid": identifier,
        "name": name,
        "address": "",
        "orderby": orderBy,
      },
    );

    if (response.statusCode == 200) {
      return MerchantSortingResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load stores (${response.statusCode})');
    }
  }
}
