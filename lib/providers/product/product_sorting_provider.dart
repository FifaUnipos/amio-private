import 'package:flutter/widgets.dart';
import 'package:unipos_app_335/data/static/product/product_sorting_state.dart';
import 'package:unipos_app_335/services/api/product/product_sorting_service.dart';

class ProductSortingProvider extends ChangeNotifier {
  final ProductSortingService _apiService;

  ProductSortingProvider(this._apiService);

  ProductSortingState _resultState = ProductSortingResultNoneState();

  ProductSortingState get resultState => _resultState;

  Future<void> fetchProductSorting(
    String token,
    List<String> merchantId,
    String name,
    String orderBy,
  ) async {
    try {
      _resultState = ProductSortingResultLoadingState();
      notifyListeners();

      final result = await _apiService.getProductSorting(
        token,
        merchantId,
        name,
        orderBy,
      );
      if (result.rc == "00" && result.data != null) {
        _resultState = ProductSortingResultLoadedState(result.data!);
      } else {
        _resultState = ProductSortingResultErrorState(
          result.rc ?? "Gagal memuat history",
        );
      }
      notifyListeners();
    } catch (e) {
      _resultState = ProductSortingResultErrorState(e.toString());
      notifyListeners();
    }
  }

  void updateIsPPN(String productId, int value) {
    final state = _resultState;
    if (state is ProductSortingResultLoadedState) {
      final updatedList = state.data.map((data) {
        if (data.productid == productId) {
          return data.copyWith(isPPN: value);
        }
        return data;
      }).toList();

      _resultState = ProductSortingResultLoadedState(updatedList);
      notifyListeners();
    }
  }

  void updateIsActive(String productId, int value) {
    final state = _resultState;
    if (state is ProductSortingResultLoadedState) {
      final updatedList = state.data.map((data) {
        if (data.productid == productId) {
          return data.copyWith(isActive: value);
        }
        return data;
      }).toList();

      _resultState = ProductSortingResultLoadedState(updatedList);
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    final state = _resultState;
    if (state is ProductSortingResultLoadedState) {
      final updatedList = state.data
        .where((d) => d.productid != productId)
        .toList();

      _resultState = ProductSortingResultLoadedState(updatedList);
      notifyListeners();
    }
  }

  int get totalData {
    final state = resultState;
    if (state is ProductSortingResultLoadedState) {
      return state.data.length;
    }
    return 0;
  }
}
