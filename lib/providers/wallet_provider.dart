import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();
  
  List<Map<String, dynamic>> _wallets = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get wallets => _wallets;
  bool get isLoading => _isLoading;


  double get totalBalance => _wallets.fold(0.0, (sum, w) {
    final val = w['wallet_balance'] ?? 0;
    return sum + val.toDouble();
  });

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      _wallets = await _service.fetchWallets();
      notifyListeners();
    } catch (e) {
      debugPrint("Refresh failed: $e");
    }
  }

  Future<void> addWallet({
    required String userId,
    required String name,
    required String type,
    required double balance,
  }) async {
    _setLoading(true);
    try {
      await _service.createWallet(
        userId: userId,
        name: name,
        type: type,
        balance: balance,
      );
      await refresh();  
    } catch (e) {
      debugPrint("Add wallet failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  // 1. ADD MONEY LOGIC
  Future<void> addMoney(String walletId, double currentBalance, double amountToAdd) async {
    _setLoading(true);
    try {
      final newBalance = currentBalance + amountToAdd;
      await Supabase.instance.client
          .from('wallets')
          .update({'wallet_balance': newBalance})
          .eq('wallet_id', walletId); // FIXED: Changed 'id' to 'wallet_id'
      
      await refresh();  
    } catch (e) {
      debugPrint("Error adding money: $e");
    } finally {
      _setLoading(false);
    }
  }

  // 2. TRANSFER MONEY LOGIC (RPC VERSION)
  Future<void> transferMoney({
    required String fromId,
    required String toId,
    required double amount,
  }) async {
    _setLoading(true);
    try {
      await Supabase.instance.client.rpc(
        'transfer_money',
        params: {
          'from_wallet_id': fromId,
          'to_wallet_id': toId,
          'amount': amount,
        },
      );
      await refresh();  
    } catch (e) {
      debugPrint("Transfer failed: $e");
      rethrow;  
    } finally {
      _setLoading(false);
    }
  }

  //fetch wallets
    Future<void> fetchWallets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallets = await _service.fetchWallets();
    } catch (e) {
      debugPrint("Provider Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // DEDUCT MONEY
  Future<void> deductMoney(String walletId, double currentBalance, double amountToSubtract) async {
    _setLoading(true);
    try {
      final newBalance = currentBalance - amountToSubtract;
      await Supabase.instance.client
          .from('wallets')
          .update({'wallet_balance': newBalance})
          .eq('wallet_id', walletId);
      
      await refresh(); // Refresh UI with new balance
    } catch (e) {
      debugPrint("Error deducting money: $e");
    } finally {
      _setLoading(false);
    }
  }

  //gets cash wallets
  double get cashBalance {
    return _wallets
      .where((w) => w['wallet_type']?.toString().toLowerCase() == 'cash')
      .fold(0.0, (sum, w) {
      return sum + (double.tryParse(w['wallet_balance'].toString()) ?? 0.0);
      });
  }

}

