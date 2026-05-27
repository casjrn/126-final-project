import 'package:supabase_flutter/supabase_flutter.dart';

class GoalService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getGoal(String userId) async {
    return await _client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  // Updates only the Target
  Future<void> updateTarget(String userId, double target) async {
    await _client.from('goals').upsert({
      'user_id': userId,
      'goal_name': 'Weekly Savings Target',
      'target_amount': target,
    }, onConflict: 'user_id');
  }

  // Increments both Current and Cumulative savings
Future<void> addSavings({
    required String userId,
    required double amount,
    required double current,
    required double cumulative,
    required double target,
  }) async {
    await _client.from('goals').upsert({
      'user_id': userId,
      'goal_name': 'Weekly Savings Target',
      'target_amount': target,
      'current_amount': current + amount,
      'cumulative_savings': cumulative + amount,
    }, onConflict: 'user_id');
  }
}