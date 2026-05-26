import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Creates the user's first physical wallet
  Future<void> createInitialWallet({
    required String userId,
    required double balance,
  }) async {
    await _client.from('wallets').insert({
      'user_id': userId,
      'wallet_name': 'Physical Wallet',
      'wallet_balance': balance,
    });
  }
}