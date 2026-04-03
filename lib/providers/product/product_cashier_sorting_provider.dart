import 'package:flutter/widgets.dart';
import 'package:unipos_app_335/data/static/product/product_sorting_state.dart';
import 'package:unipos_app_335/data/static/product_cashier/product_cashier_sorting_state.dart';
import 'package:unipos_app_335/services/api/product/product_sorting_service.dart';

class ProductCashierSortingProvider extends ChangeNotifier {
  final ProductSortingService _apiService;

  ProductCashierSortingProvider(this._apiService);

  ProductCashierSortingState _resultState = ProductCashierSortingResultNoneState();

  ProductCashierSortingState get resultState => _resultState;

  Future<void> fetchProductCashierSorting(
    String token,
    String merchantId,
    String name,
    String orderBy,
  ) async {
    try {
      _resultState = ProductCashierSortingResultLoadingState();
      notifyListeners();

      final result = await _apiService.getProductSorting(
        token,
        merchantId,
        name,
        orderBy,
      );
      if (result.rc == "00" && result.data != null) {
        if (result.data!.isEmpty) {
          _resultState = ProductCashierSortingResultNoneState();
        } else {
          _resultState = ProductCashierSortingResultLoadedState(result.data!);
        }
      } else {
        _resultState = ProductCashierSortingResultErrorState(
          result.rc ?? "Gagal memuat history",
        );
      }
      notifyListeners();
    } catch (e) {
      _resultState = ProductCashierSortingResultErrorState(e.toString());
      notifyListeners();
    }
  }

  void updateIsPPN(String productId, int value) {
    final state = _resultState;
    if (state is ProductCashierSortingResultLoadedState) {
      final updatedList = state.data.map((data) {
        if (data.productid == productId) {
          return data.copyWith(isPPN: value);
        }
        return data;
      }).toList();

      _resultState = ProductCashierSortingResultLoadedState(updatedList);
      notifyListeners();
    }
  }

  void updateIsActive(String productId, int value) {
    final state = _resultState;
    if (state is ProductCashierSortingResultLoadedState) {
      final updatedList = state.data.map((data) {
        if (data.productid == productId) {
          return data.copyWith(isActive: value);
        }
        return data;
      }).toList();

      _resultState = ProductCashierSortingResultLoadedState(updatedList);
      notifyListeners();
    }
  }

  void deleteProductCashier(String productId) {
    final state = _resultState;
    if (state is ProductCashierSortingResultLoadedState) {
      final updatedList = state.data
          .where((d) => d.productid != productId)
          .toList();

      _resultState = ProductCashierSortingResultLoadedState(updatedList);
      notifyListeners();
    }
  }

  int get totalData {
    final state = resultState;
    if (state is ProductCashierSortingResultLoadedState) {
      return state.data.length;
    }
    return 0;
  }
}
