import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();
  
  List<Map<String, dynamic>> _wallets = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get wallets => _wallets;
  bool get isLoading => _isLoading;

  // Calculate total balance across all wallets
  double get totalBalance => _wallets.fold(0.0, (sum, w) => sum + (w['wallet_balance'] ?? 0));

  // The method your Setup Page will call
  Future<void> addWallet({
    required String userId,
    required String name,
    required String type,
    required double balance,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createWallet(
        userId: userId,
        name: name,
        type: type,
        balance: balance,
      );
      await refresh(); // Automatically fetch the latest data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pull fresh data from Supabase
  Future<void> refresh() async {
    _wallets = await _service.fetchWallets();
    notifyListeners();
  }
}