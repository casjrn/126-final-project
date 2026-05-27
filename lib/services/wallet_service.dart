import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  final SupabaseClient _client = Supabase.instance.client;

  // Insert a new wallet
  Future<void> createWallet({
    required String userId,
    required String name,
    required String type,
    required double balance,
  }) async {
    await _client.from('wallets').insert({
      'user_id': userId,
      'wallet_name': name,
      'wallet_type': type,
      'wallet_balance': balance,
    });
  }

  // Fetch all wallets for a specific user
  Future<List<Map<String, dynamic>>> fetchWallets() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    return await _client
        .from('wallets')
        .select()
        .eq('user_id', user.id)
        .order('wallet_created_at');
  }
}