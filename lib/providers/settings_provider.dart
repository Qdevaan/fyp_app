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

  bool _pushHighlights = true;
  bool _pushEvents = true;
  bool _pushWeeklyDigest = true;
  bool _pushReminders = true;

  String get defaultLiveTone => _defaultLiveTone;
  String get defaultConsultantTone => _defaultConsultantTone;
  bool get alwaysPromptForTone => _alwaysPromptForTone;
  bool get pushHighlights => _pushHighlights;
  bool get pushEvents => _pushEvents;
  bool get pushWeeklyDigest => _pushWeeklyDigest;
  bool get pushReminders => _pushReminders;

  SettingsProvider() {
    _loadSettings();
  }

  // ── Load: SharedPreferences first, then Supabase overrides ────────────────
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultLiveTone = prefs.getString(_liveToneKey) ?? 'casual';
    _defaultConsultantTone = prefs.getString(_consultantToneKey) ?? 'casual';
    _alwaysPromptForTone = prefs.getBool(_alwaysPromptKey) ?? false;

    _pushHighlights = prefs.getBool('push_highlights') ?? true;
    _pushEvents = prefs.getBool('push_events') ?? true;
    _pushWeeklyDigest = prefs.getBool('push_weekly_digest') ?? true;
    _pushReminders = prefs.getBool('push_reminders') ?? true;

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
          .select('wingman_mode, consultant_mode, push_highlights, push_events, push_weekly_digest, push_reminders')
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
      if (row['push_highlights'] != null) {
        _pushHighlights = row['push_highlights'] as bool;
        await prefs.setBool('push_highlights', _pushHighlights);
      }
      if (row['push_events'] != null) {
        _pushEvents = row['push_events'] as bool;
        await prefs.setBool('push_events', _pushEvents);
      }
      if (row['push_weekly_digest'] != null) {
        _pushWeeklyDigest = row['push_weekly_digest'] as bool;
        await prefs.setBool('push_weekly_digest', _pushWeeklyDigest);
      }
      if (row['push_reminders'] != null) {
        _pushReminders = row['push_reminders'] as bool;
        await prefs.setBool('push_reminders', _pushReminders);
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

  Future<void> setPushHighlights(bool val) async {
    _pushHighlights = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_highlights', val);
    notifyListeners();
    _upsertUserSettings({'push_highlights': val});
  }

  Future<void> setPushEvents(bool val) async {
    _pushEvents = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_events', val);
    notifyListeners();
    _upsertUserSettings({'push_events': val});
  }

  Future<void> setPushWeeklyDigest(bool val) async {
    _pushWeeklyDigest = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_weekly_digest', val);
    notifyListeners();
    _upsertUserSettings({'push_weekly_digest': val});
  }

  Future<void> setPushReminders(bool val) async {
    _pushReminders = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_reminders', val);
    notifyListeners();
    _upsertUserSettings({'push_reminders': val});
  }
}
