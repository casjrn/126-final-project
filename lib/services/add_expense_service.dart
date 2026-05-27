import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExpenseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addExpense({
    required String walletId,
    required String categoryId,
    required double amount,
    String? description,
    DateTime? customDate, // Added flexibility in case they backdate an expense
  }) async {
    try {
      await _client.from('expenses').insert({
        'wallet_id': walletId,
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        // Uses picked date, or falls back to UTC now
        'created_at': (customDate ?? DateTime.now()).toUtc().toIso8601String(),
      });
    } on PostgrestException catch (error) {
      // Handle specific Supabase/database errors (e.g., Foreign key violations)
      debugPrint('Database error: ${error.message}');
      rethrow; 
    } catch (error) {
      // Handle generic/network errors
      debugPrint('Unexpected error: $error');
      rethrow;
    }
  }
}