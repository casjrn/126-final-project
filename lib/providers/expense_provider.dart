import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service = ExpenseService();
  List<Map<String, dynamic>> _expenses = [];
  
  List<Map<String, String>> _categoryOptions = [];
  List<Map<String, String>> _walletOptions = [];

  List<Map<String, dynamic>> get expenses => _expenses;
  List<Map<String, String>> get categoryOptions => _categoryOptions;
  List<Map<String, String>> get walletOptions => _walletOptions;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.fetchExpenses(),
      _service.fetchCategories(),
      _service.fetchWallets(),
    ]);

    _expenses = List<Map<String, dynamic>>.from(results[0] as List);

    _categoryOptions = (results[1] as List).map((e) => {
      'id': e['category_id'].toString(),
      'name': e['category_name'].toString(),
    }).toList();

    _walletOptions = (results[2] as List).map((e) => {
      'id': e['wallet_id'].toString(),
      'name': e['wallet_name'].toString(),
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Map<String, dynamic> data) async {
    await _service.createExpense(data);
    await refresh();
    notifyListeners();
  }

  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await _service.updateExpense(id, data);
    await refresh();
  }

  Future<void> removeExpense(String id) async {
    await _service.deleteExpense(id);
    await refresh();
  }
}