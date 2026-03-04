import 'package:flutter/widgets.dart';

import 'package:unipos_app_335/data/static/transaction/history/delete_state.dart';
import 'package:unipos_app_335/services/api/transaction/history/delete.dart';



class TransactionHistoryDeleteProvider extends ChangeNotifier {
  final TransactionHistoryDeleteService _apiService;

  TransactionHistoryDeleteProvider(this._apiService);

  TransactionHistoryDeleteResultState _resultState =
      TransactionHistoryDeleteNoneState();

  TransactionHistoryDeleteResultState get resultState => _resultState;

  void resetState() {
    _resultState = TransactionHistoryDeleteNoneState();
    notifyListeners();
  }

  Future<void> deleteTransactionHistory(
    String detailAlasan,
    String idKategori,
    String transactionId,
    String token,
  ) async {
    try {
      _resultState = TransactionHistoryDeleteLoadingState();
      notifyListeners();

      final result = await _apiService.transactionHistoryDelete(
        transactionId,
        idKategori,
        detailAlasan,
        token,
      );

      if (result.rc == "00") {
        _resultState = TransactionHistoryDeleteLoadedState(
          result.message ?? 'Hapus transaksi berhasil',
        );
      } else {
        _resultState = TransactionHistoryDeleteErrorState(
          result.message ?? result.rc ?? "Gagal hapus transaksi",
        );
      }
      notifyListeners();
    } on Exception catch (e) {
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceAll('Exception: ', '');
      }
      _resultState = TransactionHistoryDeleteErrorState(msg);
      notifyListeners();
    }
  }
}
