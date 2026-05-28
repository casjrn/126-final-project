import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _service = GoalService();
  
  Map<String, dynamic>? _goal;
  bool _isLoading = false;

  double get targetAmount => double.tryParse(_goal?['target_amount']?.toString() ?? '0.0') ?? 0.0;
  double get currentAmount => double.tryParse(_goal?['current_amount']?.toString() ?? '0.0') ?? 0.0;
  double get cumulativeAmount => double.tryParse(_goal?['cumulative_savings']?.toString() ?? '0.0') ?? 0.0;
  bool get isLoading => _isLoading;

  Future<void> fetchGoal() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();

    _goal = await _service.getGoal(user.id);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setTarget(double amount) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _service.updateTarget(user.id, amount);
      await fetchGoal();
    }
  }

  Future<void> addSavings(double amount) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _service.addSavings(
        userId: user.id,
        amount: amount,
        current: currentAmount,
        cumulative: cumulativeAmount,
        target: targetAmount, 
      );
      await fetchGoal();
    } catch (e) {
      debugPrint("Add Savings Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}