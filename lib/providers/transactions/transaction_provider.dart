import 'package:flutter/material.dart';
import 'package:unipos_app_335/models/transactionModel.dart';
import 'package:unipos_app_335/utils/repository/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionHistoryModel> _historyList = [];
  List<TransactionHistoryModel> _billList = [];
  bool _isLoadingHistory = false;
  bool _isLoadingBills = false;

  List<TransactionHistoryModel> get historyList => _historyList;
  List<TransactionHistoryModel> get billList => _billList;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingBills => _isLoadingBills;

  Future<void> fetchHistory({
    required String token,
    required String merchantId,
    String orderBy = "upDownCreate",
  }) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _historyList = await _repository.getHistory(
        token: token,
        merchantId: merchantId,
        orderBy: orderBy,
        onSyncUpdate: (updatedList) {
          _historyList = updatedList;
          _isLoadingHistory = false;
          notifyListeners();
        },
      );
      
      // If repository returns data instantly from cache, we can stop initial loading
      if (_historyList.isNotEmpty) {
        _isLoadingHistory = false;
      }
    } catch (e) {
      print("Error in TransactionProvider.fetchHistory: $e");
      _isLoadingHistory = false;
    }
    notifyListeners();
  }

  Future<void> fetchBills({
    required String token,
    required String merchantId,
    String orderBy = "upDownCreate",
  }) async {
    _isLoadingBills = true;
    notifyListeners();

    try {
      _billList = await _repository.getBills(
        token: token,
        merchantId: merchantId,
        orderBy: orderBy,
        onSyncUpdate: (updatedList) {
          _billList = updatedList;
          _isLoadingBills = false;
          notifyListeners();
        },
      );

      if (_billList.isNotEmpty) {
        _isLoadingBills = false;
      }
    } catch (e) {
      print("Error in TransactionProvider.fetchBills: $e");
      _isLoadingBills = false;
    }
    notifyListeners();
  }

  TransactionDetailModel? _transactionDetail;
  bool _isLoadingDetail = false;

  TransactionDetailModel? get transactionDetail => _transactionDetail;
  bool get isLoadingDetail => _isLoadingDetail;

  Future<void> fetchTransactionDetail({
    required String token,
    required String merchantId,
    required String transactionId,
  }) async {
    _isLoadingDetail = true;
    _transactionDetail = null; // Reset for new fetch
    notifyListeners();

    try {
      _transactionDetail = await _repository.getTransactionDetail(
        token: token,
        merchantId: merchantId,
        transactionId: transactionId,
      );
    } catch (e) {
      print("Error in TransactionProvider.fetchTransactionDetail: $e");
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> saveBill({
    required String token,
    required String merchantId,
    required Map<String, dynamic> transaction,
    required List<Map<String, dynamic>> details,
  }) async {
    final success = await _repository.saveBill(
      token: token,
      merchantId: merchantId,
      transaction: transaction,
      details: details,
    );

    if (success) {
      // Refresh bill list automatically
      fetchBills(token: token, merchantId: merchantId);
    }

    return success;
  }

  Future<List<Map<String, dynamic>>> getCancelReasons({
    required String token,
    required String transactionId,
  }) async {
    return await _repository.getCancelReasons(
      token: token,
      transactionId: transactionId,
    );
  }

  Future<bool> deleteBill({
    required String token,
    required String merchantId,
    required String transactionId,
    required String reasonId,
    required String notes,
  }) async {
    final success = await _repository.deleteBill(
      token: token,
      transactionId: transactionId,
      reasonId: reasonId,
      notes: notes,
    );

    if (success) {
      // Refresh list to show offline status or remove
      fetchBills(token: token, merchantId: merchantId);
    }

    return success;
  }
}
