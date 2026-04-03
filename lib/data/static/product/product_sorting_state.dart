
import 'package:unipos_app_335/data/model/product/product_sorting_data.dart';

sealed class ProductSortingState {}

class ProductSortingResultNoneState extends ProductSortingState {}

class ProductSortingResultLoadingState extends ProductSortingState {}

class ProductSortingResultErrorState extends ProductSortingState {
  final String message;

  ProductSortingResultErrorState(this.message);
}

class ProductSortingResultLoadedState extends ProductSortingState {
  final List<ProductSortingData> data;

  ProductSortingResultLoadedState(this.data);
}