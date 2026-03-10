import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _liveToneKey = 'default_live_tone';
  static const String _consultantToneKey = 'default_consultant_tone';

  String _defaultLiveTone = 'casual';
  String _defaultConsultantTone = 'casual';

  String get defaultLiveTone => _defaultLiveTone;
  static const String _alwaysPromptKey = 'always_prompt_for_tone';

  String get defaultConsultantTone => _defaultConsultantTone;

  bool _alwaysPromptForTone = false;
  bool get alwaysPromptForTone => _alwaysPromptForTone;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultLiveTone = prefs.getString(_liveToneKey) ?? 'casual';
    _defaultConsultantTone = prefs.getString(_consultantToneKey) ?? 'casual';
    _alwaysPromptForTone = prefs.getBool(_alwaysPromptKey) ?? false;
    notifyListeners();
  }

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
  }

  Future<void> setDefaultConsultantTone(String tone) async {
    _defaultConsultantTone = tone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_consultantToneKey, tone);
    notifyListeners();
  }
}
