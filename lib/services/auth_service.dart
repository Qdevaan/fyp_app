import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Singleton Pattern
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Returns the current authenticated user, or null if not signed in.
  User? get currentUser => _client.auth.currentUser;

  /// Returns the current session, or null if expired/missing.
  Session? get currentSession => _client.auth.currentSession;

  /// Checks if the current user's email is verified based on Supabase metadata.
  bool get isEmailVerified => _client.auth.currentUser?.emailConfirmedAt != null;

  // ---------------------------------------------------------------------------
  // AUTHENTICATION METHODS
  // ---------------------------------------------------------------------------

  /// Sign in with Google OAuth.
  /// 
  /// Triggers the native browser or system sheet for Google Sign-In.
  /// Requires 'io.supabase.bubbles://login-callback/' to be added to Supabase Redirect URLs.
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google, // Updated for v2
        redirectTo: 'io.supabase.bubbles://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign up with Email and Password.
  /// 
  /// Sends a confirmation email to the user.
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.bubbles://login-callback/',
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with Email and Password.
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      // Sign out errors are rarely critical for the user flow, but we log/rethrow if needed.
      throw _handleAuthError(e);
    }
  }

  /// Refresh the current session. 
  /// Useful for re-checking email verification status without re-logging in.
  Future<void> refreshSession() async {
    try {
      await _client.auth.refreshSession();
    } catch (e) {
      // If refresh fails, user might need to log in again.
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE & DATA METHODS
  // ---------------------------------------------------------------------------

  /// Fetches the user's profile from the 'profiles' table.
  /// Returns null if the row does not exist.
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
          
      return data;
    } catch (e) {
      // In production, you might want to log this error to a monitoring service (e.g. Sentry)
      return null;
    }
  }

  /// Uploads an avatar image to the 'avatars' storage bucket.
  /// 
  /// Returns the public URL of the uploaded file.
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _client.storage.from('avatars').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = _client.storage.from('avatars').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Inserts or updates the user's profile data.
  Future<void> upsertProfile({
    String? fullName,
    String? avatarUrl,
    DateTime? dob,
    String? gender,
    String? country,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      final updates = {
        'id': user.id, // Primary key maps to Auth UID
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'dob': dob?.toIso8601String().split('T').first, // Store as YYYY-MM-DD
        'gender': gender,
        'country': country,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove null values to avoid overwriting existing data with nulls if partially updating
      // (Though for a full completion screen, we usually want to send everything)
      updates.removeWhere((key, value) => value == null);

      await _client.from('profiles').upsert(updates);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR HANDLING
  // ---------------------------------------------------------------------------

  /// Standardizes error messages for the UI.
  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      // Return the specific message from Supabase (e.g., "Invalid login credentials")
      return Exception(error.message);
    } else if (error is PostgrestException) {
      // Database errors
      return Exception(error.message);
    } else if (error is StorageException) {
      // Storage errors
      return Exception(error.message);
    } else {
      // Generic errors
      return Exception('An unexpected error occurred: $error');
    }
  }
}