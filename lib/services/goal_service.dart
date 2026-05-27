import 'package:supabase_flutter/supabase_flutter.dart';

class GoalService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Creates the user's first savings goal
  Future<void> createInitialGoal({
    required String userId,
    required double target,
  }) async {
    await _client.from('goals').insert({
      'user_id': userId,
      'goal_name': 'Weekly Savings Target',
      'target_amount': target,
      'current_amount': 0.00,
    });
  }
}