import 'dart:convert'; // Needed for JSON encoding/decoding
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this

class AuthService {
  // Singleton Pattern
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  
  // Key for storing profile data in SharedPreferences
  static const String _profileCacheKey = 'cached_user_profile';

  /// Returns the current authenticated user, or null if not signed in.
  User? get currentUser => _client.auth.currentUser;

  /// Returns the current session, or null if expired/missing.
  Session? get currentSession => _client.auth.currentSession;

  /// Checks if the current user's email is verified based on Supabase metadata.
  bool get isEmailVerified => _client.auth.currentUser?.emailConfirmedAt != null;

  // ---------------------------------------------------------------------------
  // AUTHENTICATION METHODS
  // ---------------------------------------------------------------------------

  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.bubbles://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

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

  /// Sign out the current user and CLEAR local cache.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // Clear the locally saved profile so the next user doesn't see it
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileCacheKey);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE & DATA METHODS (Caching Implemented Here)
  // ---------------------------------------------------------------------------

  /// Fetches the user's profile.
  /// Logic:
  /// 1. Check Local Storage. If data exists, return it immediately (Fast!).
  /// 2. If no local data, fetch from Supabase.
  /// 3. Save Supabase result to Local Storage for next time.
  Future<Map<String, dynamic>?> getProfile({bool forceRefresh = false}) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final prefs = await SharedPreferences.getInstance();

      // 1. Return Local Cache if available and we aren't forcing a refresh
      if (!forceRefresh && prefs.containsKey(_profileCacheKey)) {
        final jsonString = prefs.getString(_profileCacheKey);
        if (jsonString != null) {
          // Decode JSON string back to Map
          return jsonDecode(jsonString) as Map<String, dynamic>;
        }
      }

      // 2. Fetch from Supabase (Network Call)
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
          
      // 3. Save to Local Storage
      if (data != null) {
        await prefs.setString(_profileCacheKey, jsonEncode(data));
      }

      return data;
    } catch (e) {
      // If network fails but we have cache, we could try returning cache here too,
      // but for now, we just return null or rethrow.
      return null;
    }
  }

  /// Inserts or updates the user's profile data AND updates local cache.
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
        'id': user.id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'dob': dob?.toIso8601String().split('T').first,
        'gender': gender,
        'country': country,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove nulls so we don't wipe out existing data with nulls
      updates.removeWhere((key, value) => value == null);

      // 1. Send to Supabase
      await _client.from('profiles').upsert(updates);

      // 2. Update Local Cache immediately
      // We merge the new updates with whatever we already had locally
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> currentCache = {};
      
      if (prefs.containsKey(_profileCacheKey)) {
        final jsonString = prefs.getString(_profileCacheKey);
        if (jsonString != null) {
          currentCache = jsonDecode(jsonString) as Map<String, dynamic>;
        }
      }

      // Merge new updates into current cache
      final newCache = {...currentCache, ...updates};
      await prefs.setString(_profileCacheKey, jsonEncode(newCache));

    } catch (e) {
      throw _handleAuthError(e);
    }
  }

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

  // ---------------------------------------------------------------------------
  // ERROR HANDLING
  // ---------------------------------------------------------------------------

  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      return Exception(error.message);
    } else if (error is PostgrestException) {
      return Exception(error.message);
    } else if (error is StorageException) {
      return Exception(error.message);
    } else {
      return Exception('An unexpected error occurred: $error');
    }
  }
}