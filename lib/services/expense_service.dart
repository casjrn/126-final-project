import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchExpenses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('expenses')
        .select('''
          *,
          categories(category_name),
          wallets(wallet_name)
        ''')
        .eq('user_id', userId)
        .order('expense_date', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await _supabase.from('categories').select('category_id, category_name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchWallets() async {
    final response = await _supabase.from('wallets').select('wallet_id, wallet_name, wallet_balance');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createExpense(Map<String, dynamic> data) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");
    
    final completeData = {...data, 'user_id': userId};
    await _supabase.from('expenses').insert(completeData).select();
  
  }

  Future<void> deleteExpense(String id) async {
    await _supabase.from('expenses').delete().eq('expense_id', id);
  }

  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await _supabase.from('expenses').update(data).eq('expense_id', id);
  }
}