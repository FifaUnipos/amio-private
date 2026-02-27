import 'package:unipos_app_335/data/model/transaction/history/delete_reasons.dart';
import 'package:unipos_app_335/data/model/transaction/history/delete_reasons_response.dart';

sealed class TransactionHistoryDeleteReasonsResultState {}

class TransactionHistoryDeleteReasonsNoneState extends TransactionHistoryDeleteReasonsResultState {}

class TransactionHistoryDeleteReasonsLoadingState extends TransactionHistoryDeleteReasonsResultState {}

class TransactionHistoryDeleteReasonsErrorState extends TransactionHistoryDeleteReasonsResultState {
  final String message;

  TransactionHistoryDeleteReasonsErrorState(this.message);
}

class TransactionHistoryDeleteReasonsLoadedState extends TransactionHistoryDeleteReasonsResultState {
  final List<TransactionHistoryDeleteReason> data;

  TransactionHistoryDeleteReasonsLoadedState(this.data);
}