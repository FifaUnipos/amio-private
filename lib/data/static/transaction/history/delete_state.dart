
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
