import 'package:unipos_app_335/data/model/transaction/history/delete_reasons.dart';
import 'package:unipos_app_335/data/model/transaction/history/delete_reasons_response.dart';
import 'package:unipos_app_335/data/model/transaction/history/delete_response.dart';

sealed class TransactionHistoryDeleteResultState {}

class TransactionHistoryDeleteNoneState
    extends TransactionHistoryDeleteResultState {}

class TransactionHistoryDeleteLoadingState
    extends TransactionHistoryDeleteResultState {}

class TransactionHistoryDeleteErrorState
    extends TransactionHistoryDeleteResultState {
  final String message;

  TransactionHistoryDeleteErrorState(this.message);
}

class TransactionHistoryDeleteLoadedState
    extends TransactionHistoryDeleteResultState {
  final String message;
  TransactionHistoryDeleteLoadedState(this.message);
}
