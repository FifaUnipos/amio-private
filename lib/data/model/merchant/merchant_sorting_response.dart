import 'package:unipos_app_335/data/model/merchant/merchant_sorting_data.dart';

class MerchantSortingResponse {
  final String? rc;
  final List<MerchantSortingData>? data;

  MerchantSortingResponse({this.rc, this.data});

  factory MerchantSortingResponse.fromJson(Map<String, dynamic> json) {
    return MerchantSortingResponse(
      rc: json['rc']?.toString(),
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => MerchantSortingData.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
