import 'package:flutter/widgets.dart';
import 'package:unipos_app_335/data/static/transaction/history/view_deleted_history_state.dart';
import 'package:unipos_app_335/services/api/transaction/history/view_deleted_history.dart';

class TransactionViewDeletedHistoryProvider extends ChangeNotifier {
  final TransactionViewDeletedHistoryService _apiService;

  TransactionViewDeletedHistoryProvider(this._apiService);

  TransactionViewDeletedHistoryResultState _resultState =
      TransactionViewDeletedHistoryNoneState();

  TransactionViewDeletedHistoryResultState get resultState => _resultState;

  Future<void> fetchViewDeletedHistory(
    String token,
    String transactionId,
    String merchantId,
  ) async {
    try {
      _resultState = TransactionViewDeletedHistoryLoadingState();
      notifyListeners();

      final result = await _apiService.transactionViewDeletedHistory(
        token,
        transactionId,
        merchantId,
      );
        if (result.rc == "00" && result.data != null && result.data!.references != null) {
        _resultState = TransactionViewDeletedHistoryLoadedState(result.data!);
      } else {
        _resultState = TransactionViewDeletedHistoryErrorState(result.rc ?? "Gagal memuat history");
      }
      notifyListeners();
    } catch (e) {
      _resultState = TransactionViewDeletedHistoryErrorState(e.toString());
      notifyListeners();
    }
  }
}
