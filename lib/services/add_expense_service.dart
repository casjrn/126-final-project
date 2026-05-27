import 'package:supabase_flutter/supabase_flutter.dart';

class AddExpenseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Insert a new expense
  Future<void> addExpense({
    required String walletId,
    required String categoryId,
    required double amount,
    String? description,
    String? refId, // Included since it's in your schema (nullable UUID)
  }) async {
    // 1. Get the currently logged-in user's ID
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception("User must be logged in to save an expense.");
    }

    // 2. Perform the insert using the EXACT database column names
    await _client.from('expenses').insert({
      'user_id': currentUser.id,               // Required UUID column
      'category_id': categoryId,               // Match schema name
      'wallet_id': walletId,                   // Match schema name
      'ref_id': refId,                         // Nullable UUID
      'expense_description': description,      // Replaces 'description'
      'expense_amount': amount,                // Replaces 'amount'
      'expense_date': DateTime.now().toIso8601String().split('T')[0], // Formats to standard YYYY-MM-DD
      'expense_created_at': DateTime.now().toUtc().toIso8601String(), // Replaces 'created_at'
    });
  }
}