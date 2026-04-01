import 'package:flutter/widgets.dart';
import 'package:unipos_app_335/data/static/merchant/merchant_sorting_state.dart';
import 'package:unipos_app_335/services/api/merchant/merchant_sorting_service.dart';

class MerchantSortingProvider extends ChangeNotifier {
  final MerchantSortingService _apiService;

  MerchantSortingProvider(this._apiService);

  MerchantSortingState _resultState = MerchantSortingResultNoneState();

  MerchantSortingState get resultState => _resultState;

  Future<void> fetchMerchantSorting(
    String token,
    String name,
    String orderBy,
  ) async {
    try {
      _resultState = MerchantSortingResultLoadingState();
      notifyListeners();

      final result = await _apiService.getMerchantSorting(token, name, orderBy);
      if (result.rc == "00" && result.data != null) {
        if (result.data!.isEmpty) {
          _resultState = MerchantSortingResultNoneState();
        } else {
          _resultState = MerchantSortingResultLoadedState(result.data!);
        }
      } else {
        _resultState = MerchantSortingResultErrorState(
          result.rc ?? "Gagal memuat history",
        );
      }
      notifyListeners();
    } catch (e) {
      _resultState = MerchantSortingResultErrorState(e.toString());
      notifyListeners();
    }
  }
}
