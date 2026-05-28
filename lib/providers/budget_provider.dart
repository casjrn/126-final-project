import 'package:flutter/material.dart';

class BudgetProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food & Dining', 'pct': 0.0},
    {'name': 'Transportation', 'pct': 0.0},
    {'name': 'Personal Use & Hygiene', 'pct': 0.0},
    {'name': 'School Supplies & Academic Fees', 'pct': 0.0},
    {'name': 'Recreation & Leisure', 'pct': 0.0},
    {'name': 'Utilities & Load', 'pct': 0.0},
  ];

  bool _isBudgetSet = false;

  List<Map<String, dynamic>> get categories => _categories;
  bool get isBudgetSet => _isBudgetSet;

  void updateCategoryPct(String name, double pct) {
    final index = _categories.indexWhere((c) => c['name'] == name);
    if (index != -1) {
      _categories[index]['pct'] = pct;
      notifyListeners();
    }
  }

  void setBudgetActive(bool value) {
    _isBudgetSet = value;
    notifyListeners();
  }
}