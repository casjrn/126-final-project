import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Starts the Sign Up process. 
  /// The DB Trigger handles creating the row in the 'Users' table.
  Future<User?> signUpAndCreateProfile({
    required String email,
    required String password,
    required String username,
  }) async {
    debugPrint("AuthService: Sign Up initiated for $username");
    
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username}, // The SQL Trigger reads this map
    );

    return res.user;
  }

  /// Authenticates an existing user.
  Future<AuthResponse> logIn({
    required String email,
    required String password,
  }) async {
    debugPrint("AuthService: Login request for $email");
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}