import 'package:unipos_app_335/data/model/merchant/merchant_sorting_data.dart';

sealed class MerchantSortingState {}

class MerchantSortingResultNoneState extends MerchantSortingState {}

class MerchantSortingResultLoadingState extends MerchantSortingState {}

class MerchantSortingResultErrorState extends MerchantSortingState {
  final String message;
  MerchantSortingResultErrorState(this.message);
}

class MerchantSortingResultLoadedState extends MerchantSortingState {
  final List<MerchantSortingData> data;
  MerchantSortingResultLoadedState(this.data);
}