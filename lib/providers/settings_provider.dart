import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

/// Manages user preferences with dual persistence:
///  - SharedPreferences for offline/instant reads
///  - Supabase `user_settings` table for cross-device sync (schema_v2)
class SettingsProvider with ChangeNotifier {
  static const String _liveToneKey = 'default_live_tone';
  static const String _consultantToneKey = 'default_consultant_tone';
  static const String _alwaysPromptKey = 'always_prompt_for_tone';

  String _defaultLiveTone = 'casual';
  String _defaultConsultantTone = 'casual';
  bool _alwaysPromptForTone = false;

  String get defaultLiveTone => _defaultLiveTone;
  String get defaultConsultantTone => _defaultConsultantTone;
  bool get alwaysPromptForTone => _alwaysPromptForTone;

  SettingsProvider() {
    _loadSettings();
  }

  // ── Load: SharedPreferences first, then Supabase overrides ────────────────
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultLiveTone = prefs.getString(_liveToneKey) ?? 'casual';
    _defaultConsultantTone = prefs.getString(_consultantToneKey) ?? 'casual';
    _alwaysPromptForTone = prefs.getBool(_alwaysPromptKey) ?? false;
    notifyListeners();

    // Overlay with remote values if available
    await _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;
      final row = await Supabase.instance.client
          .from('user_settings')
          .select('wingman_mode, consultant_mode')
          .eq('user_id', user.id)
          .maybeSingle();
      if (row == null) return;
      final prefs = await SharedPreferences.getInstance();
      if (row['wingman_mode'] != null) {
        _defaultLiveTone = row['wingman_mode'] as String;
        await prefs.setString(_liveToneKey, _defaultLiveTone);
      }
      if (row['consultant_mode'] != null) {
        _defaultConsultantTone = row['consultant_mode'] as String;
        await prefs.setString(_consultantToneKey, _defaultConsultantTone);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('SettingsProvider._loadFromSupabase: $e');
    }
  }

  // ── Upsert helper ─────────────────────────────────────────────────────────
  Future<void> _upsertUserSettings(Map<String, dynamic> updates) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;
      await Supabase.instance.client.from('user_settings').upsert({
        'user_id': user.id,
        ...updates,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('SettingsProvider._upsertUserSettings: $e');
    }
  }

  // ── Setters ───────────────────────────────────────────────────────────────
  Future<void> setAlwaysPromptForTone(bool value) async {
    _alwaysPromptForTone = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alwaysPromptKey, value);
    notifyListeners();
  }

  Future<void> setDefaultLiveTone(String tone) async {
    _defaultLiveTone = tone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_liveToneKey, tone);
    notifyListeners();
    _upsertUserSettings({'wingman_mode': tone});
  }

  Future<void> setDefaultConsultantTone(String tone) async {
    _defaultConsultantTone = tone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_consultantToneKey, tone);
    notifyListeners();
    _upsertUserSettings({'consultant_mode': tone});
  }
}
