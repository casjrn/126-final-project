import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Executes sign up and handles public custom table insertion.
  /// Returns the [User] object if successful, otherwise throws exceptions handled by the view.
  Future<User?> signUpAndCreateProfile({
    required String email,
    required String password,
    required String username,
  }) async {
    debugPrint("Step 1: Starting Auth Sign Up...");
    
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    final user = res.user;
    if (user == null) {
      debugPrint("Step 2 Error: User object is null! Check if email confirmation is required.");
      return null;
    }

    debugPrint("Step 2: Auth Success. User ID: ${user.id}");
    debugPrint("Step 3: Attempting DB Insert into 'Users'...");

    // .select() is added to force a response from the DB for debugging
    await _client.from('Users').insert({
      'user_id': user.id,
      'username': username,
      'user_email': email
    }).select();

    debugPrint("Step 4: DB Success! Row created in Users table.");
    
    return user;
  
  }

    // Authenticates an existing user via email and password.
    // Returns an [AuthResponse] containing session data if successful.
    Future<AuthResponse> logIn({
      required String email,
      required String password,
    }) async {
      debugPrint("AuthService: Requesting session configuration for $email...");
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    }
  }
