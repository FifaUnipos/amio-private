
import 'package:unipos_app_335/data/model/product/product_sorting_data.dart';

sealed class ProductCashierSortingState {}

class ProductCashierSortingResultNoneState extends ProductCashierSortingState {}

class ProductCashierSortingResultLoadingState extends ProductCashierSortingState {}

class ProductCashierSortingResultErrorState extends ProductCashierSortingState {
  final String message;

  ProductCashierSortingResultErrorState(this.message);
}

class ProductCashierSortingResultLoadedState extends ProductCashierSortingState {
  final List<ProductSortingData> data;

  ProductCashierSortingResultLoadedState(this.data);
}