import 'package:flutter/material.dart';
import 'package:moneytracker/database/database_helper.dart';
import 'package:moneytracker/model/transaction.dart';

class TransactionsProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionsProvider() {
    _loadTransactions();
  }

  // Load transactions from the database
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await DatabaseHelper.instance.getAllTransactions();

    _isLoading = false;
    notifyListeners();
  }

  double getTotalIncomes() {
    return _transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .map((transaction) => transaction.amount)
        .fold(0, (a, b) => a + b);
  }

  double getTotalExpenses() {
    return _transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .map((transaction) => transaction.amount)
        .fold(0, (a, b) => a + b);
  }

  double getBalance() {
    return getTotalIncomes() + getTotalExpenses();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await _loadTransactions(); // Reload from the DB
  }

  Future<void> clearTransactions() async {
    // This method will be implemented later in DatabaseHelper
    _transactions.clear();
    notifyListeners();
  }
}
