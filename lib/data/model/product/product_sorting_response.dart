

import 'package:unipos_app_335/data/model/product/product_sorting_data.dart';

class ProductSortingResponse {
  final String? rc;
  final List<ProductSortingData>? data;

  ProductSortingResponse({this.rc, this.data});

  factory ProductSortingResponse.fromJson(Map<String, dynamic> json) {
    return ProductSortingResponse(
      rc: json['rc']?.toString(),
      data: json['data'] != null
          ? List<ProductSortingData>.from(json['data'].map((x) => ProductSortingData.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'rc': rc, if (data != null) 'data': data!.map((x) => x.toJson()).toList()};
  }
}
