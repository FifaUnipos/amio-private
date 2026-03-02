import 'package:flutter/widgets.dart';
import 'package:unipos_app_335/data/static/transaction/history/delete_reasons_state.dart';
import 'package:unipos_app_335/services/api/transaction/history/delete_get_reasons.dart';

class TransactionHistoryDeleteReasonsProvider extends ChangeNotifier {
  final TransactionHistoryDeleteReasonsService _apiService;

  TransactionHistoryDeleteReasonsProvider(this._apiService);

  TransactionHistoryDeleteReasonsResultState _resultState = TransactionHistoryDeleteReasonsNoneState();

  TransactionHistoryDeleteReasonsResultState get resultState => _resultState;

  Future<void> fetchDeleteListReasons(String transactionId, String token) async {
    try {
      _resultState = TransactionHistoryDeleteReasonsLoadingState();
      notifyListeners();
      
      final result = await _apiService.transactionHistoryDeleteGetReasons(transactionId, token, "default_device_id");

      if (result.rc == "00" && result.data != null && result.data!.alasan != null) {
        _resultState = TransactionHistoryDeleteReasonsLoadedState(result.data!.alasan!);
      } else {
        _resultState = TransactionHistoryDeleteReasonsErrorState(result.rc ?? "Gagal memuat list alasan hapus");
      }
      notifyListeners();
    } on Exception catch (e) {
      _resultState = TransactionHistoryDeleteReasonsErrorState(e.toString());
      notifyListeners();
    }
  }
}
