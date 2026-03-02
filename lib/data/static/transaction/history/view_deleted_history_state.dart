
import 'package:unipos_app_335/data/model/transaction/history/view_deleted_history.dart';

sealed class TransactionViewDeletedHistoryResultState {}

class TransactionViewDeletedHistoryNoneState extends TransactionViewDeletedHistoryResultState {}

class TransactionViewDeletedHistoryLoadingState extends TransactionViewDeletedHistoryResultState {}

class TransactionViewDeletedHistoryErrorState extends TransactionViewDeletedHistoryResultState {
  final String message;

  TransactionViewDeletedHistoryErrorState(this.message);
}

class TransactionViewDeletedHistoryLoadedState extends TransactionViewDeletedHistoryResultState {
  final TransactionViewDeletedHistoryData data;

  TransactionViewDeletedHistoryLoadedState(this.data);
}