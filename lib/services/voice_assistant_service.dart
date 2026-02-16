import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:http/http.dart' as http;
import 'connection_service.dart';

// ─── Enums ───────────────────────────────────────────────

/// The current state of the voice assistant pipeline.
enum VoiceAssistantState {
  idle,       // Not active — waiting for wake word or tap
  listening,  // Wake word detected — actively capturing command
  processing, // Command captured — sending to server
  speaking,   // TTS reading out the response
}

/// Voice modes the user can choose from.
enum VoiceMode {
  male,    // Deep, lower pitch
  female,  // Higher pitch
  neutral, // Robotic, Jarvis-like
}

// ─── Service ────────────────────────────────────────────

class VoiceAssistantService extends ChangeNotifier {
  // ── Dependencies ──
  final ConnectionService _connectionService;

  // ── Speech-to-Text ──
  final SpeechToText _stt = SpeechToText();
  bool _sttInitialized = false;

  // ── Text-to-Speech ──
  final FlutterTts _tts = FlutterTts();

  // ── State ──
  VoiceAssistantState _state = VoiceAssistantState.idle;
  VoiceAssistantState get state => _state;

  String _lastResponse = '';
  String get lastResponse => _lastResponse;

  String _partialText = '';
  String get partialText => _partialText;

  bool _isWakeWordEnabled = true;
  bool get isWakeWordEnabled => _isWakeWordEnabled;

  bool _isOverlayVisible = false;
  bool get isOverlayVisible => _isOverlayVisible;

  /// Whether the service is active (user is authenticated and on a main screen).
  bool _isActive = false;
  bool get isActive => _isActive;

  VoiceMode _voiceMode = VoiceMode.neutral;
  VoiceMode get voiceMode => _voiceMode;

  // ── Wake word detection ──
  bool _isBackgroundListening = false;
  Timer? _restartTimer;

  // ── Prefs keys ──
  static const String _voiceModeKey = 'voice_mode';
  static const String _wakeWordKey = 'wake_word_enabled';

  // ── Constructor ──
  VoiceAssistantService(this._connectionService) {
    _init();
  }

  // ─── Initialisation ───────────────────────────────────

  Future<void> _init() async {
    await _loadPreferences();
    await _initSTT();
    await _initTTS();
    // Don't auto-start wake word listening here.
    // Wait for activate() to be called (e.g. from HomeScreen).
  }

  /// Call this when user is authenticated and on a main screen.
  void activate() {
    if (_isActive) return;
    _isActive = true;
    debugPrint('🎙️ Voice assistant activated');
    if (_isWakeWordEnabled && _sttInitialized) {
      _startWakeWordListening();
    }
  }

  /// Call this when user logs out or navigates to auth screens.
  void deactivate() {
    if (!_isActive) return;
    _isActive = false;
    debugPrint('🎙️ Voice assistant deactivated');
    _stopWakeWordListening();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_voiceModeKey) ?? VoiceMode.neutral.index;
    _voiceMode = VoiceMode.values[modeIndex.clamp(0, VoiceMode.values.length - 1)];
    _isWakeWordEnabled = prefs.getBool(_wakeWordKey) ?? true;
    notifyListeners();
  }

  Future<void> _initSTT() async {
    try {
      _sttInitialized = await _stt.initialize(
        onStatus: _onSTTStatus,
        onError: (error) => debugPrint('🎙️ STT error: ${error.errorMsg}'),
      );
      debugPrint('🎙️ STT initialized: $_sttInitialized');
    } catch (e) {
      debugPrint('🎙️ STT init failed: $e');
    }
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('en-US');
    await _applyVoiceMode();
    _tts.setCompletionHandler(() {
      // When TTS finishes speaking, return to idle
      _setState(VoiceAssistantState.idle);
      // Restart wake word after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isWakeWordEnabled && !_isBackgroundListening) {
          _startWakeWordListening();
        }
      });
    });
  }

  // ─── Voice Mode ───────────────────────────────────────

  Future<void> setVoiceMode(VoiceMode mode) async {
    _voiceMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_voiceModeKey, mode.index);
    await _applyVoiceMode();
  }

  Future<void> _applyVoiceMode() async {
    switch (_voiceMode) {
      case VoiceMode.male:
        await _tts.setPitch(0.8);
        await _tts.setSpeechRate(0.45);
        break;
      case VoiceMode.female:
        await _tts.setPitch(1.3);
        await _tts.setSpeechRate(0.50);
        break;
      case VoiceMode.neutral:
        await _tts.setPitch(1.0);
        await _tts.setSpeechRate(0.42);
        break;
    }
  }

  // ─── Wake Word Toggle ────────────────────────────────

  Future<void> setWakeWordEnabled(bool enabled) async {
    _isWakeWordEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wakeWordKey, enabled);

    if (enabled) {
      _startWakeWordListening();
    } else {
      _stopWakeWordListening();
    }
  }

  // ─── Wake Word Listening (Background) ────────────────

  void _startWakeWordListening() {
    if (!_isActive) return;
    if (!_sttInitialized || _isBackgroundListening) return;
    if (_state != VoiceAssistantState.idle) return;

    _isBackgroundListening = true;
    debugPrint('🎙️ Starting wake word listening...');

    _stt.listen(
      onResult: _onWakeWordResult,
      listenMode: ListenMode.dictation,
      pauseFor: const Duration(seconds: 3),
      cancelOnError: false,
      partialResults: true,
    );
  }

  void _stopWakeWordListening() {
    _isBackgroundListening = false;
    _restartTimer?.cancel();
    if (_stt.isListening) {
      _stt.stop();
    }
  }

  void _onWakeWordResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.toLowerCase();
    debugPrint('🎙️ Wake word partial: "$text"');

    if (text.contains('hey bubbles') || text.contains('hey bubble')) {
      debugPrint('🎙️ ✅ Wake word detected!');
      _stt.stop();
      _isBackgroundListening = false;

      // Extract any command text that came after the wake word
      String afterWake = '';
      final wakeIdx = text.indexOf('hey bubbles');
      final wakeIdx2 = text.indexOf('hey bubble');
      final idx = wakeIdx >= 0 ? wakeIdx : wakeIdx2;
      if (idx >= 0) {
        final wakePhrase = wakeIdx >= 0 ? 'hey bubbles' : 'hey bubble';
        afterWake = text.substring(idx + wakePhrase.length).trim();
      }

      // Show overlay and start active listening
      _showOverlay();

      if (afterWake.isNotEmpty && result.finalResult) {
        // User already said the command with the wake word
        _processCommand(afterWake);
      } else {
        // Switch to active command listening
        _startCommandListening();
      }
    }
  }

  void _onSTTStatus(String status) {
    debugPrint('🎙️ STT status: $status');
    if (status == 'done' || status == 'notListening') {
      if (_isBackgroundListening) {
        // Restart wake word listening after a pause
        _isBackgroundListening = false;
        _restartTimer?.cancel();
        _restartTimer = Timer(const Duration(milliseconds: 300), () {
          if (_isActive && _isWakeWordEnabled && _state == VoiceAssistantState.idle) {
            _startWakeWordListening();
          }
        });
      }
    }
  }

  // ─── Active Command Listening ────────────────────────

  void _startCommandListening() {
    if (!_sttInitialized) return;

    _setState(VoiceAssistantState.listening);
    _partialText = '';
    notifyListeners();

    _stt.listen(
      onResult: _onCommandResult,
      listenMode: ListenMode.dictation,
      pauseFor: const Duration(seconds: 3),
      cancelOnError: false,
      partialResults: true,
    );
  }

  void _onCommandResult(SpeechRecognitionResult result) {
    _partialText = result.recognizedWords;
    notifyListeners();

    if (result.finalResult) {
      final command = result.recognizedWords.trim();
      debugPrint('🎙️ Command captured: "$command"');
      if (command.isNotEmpty) {
        _processCommand(command);
      } else {
        // No command heard — go back to idle
        _setState(VoiceAssistantState.idle);
        _hideOverlayAfterDelay();
      }
    }
  }

  // ─── Manual Activation (Tap the FAB) ─────────────────

  void activateManually() {
    _stopWakeWordListening();
    _showOverlay();
    _startCommandListening();
  }

  // ─── Command Processing ──────────────────────────────

  Future<void> _processCommand(String command) async {
    _setState(VoiceAssistantState.processing);
    _partialText = command;
    notifyListeners();

    // Check server connection
    if (!_connectionService.isConnected || _connectionService.serverUrl.isEmpty) {
      await _speak("I can't reach the server right now. Please check your connection in settings.");
      return;
    }

    try {
      final userId = _getUserId();
      final response = await _sendVoiceCommand(userId, command);

      if (response != null) {
        _lastResponse = response['response'] ?? "I'm not sure how to help with that.";
        final action = response['action'] as String? ?? 'none';
        final target = response['target'] as String?;

        // Speak the response
        await _speak(_lastResponse);

        // Execute navigation action after speaking starts
        if (action == 'navigate' && target != null) {
          _pendingNavigation = target;
        }
      } else {
        await _speak("Sorry, I had trouble processing that. Can you try again?");
      }
    } catch (e) {
      debugPrint('❌ Voice command error: $e');
      await _speak("Something went wrong. Please try again.");
    }
  }

  String? _pendingNavigation;

  /// Call this from the overlay widget to get & consume pending navigation.
  String? consumePendingNavigation() {
    final nav = _pendingNavigation;
    _pendingNavigation = null;
    return nav;
  }

  String _getUserId() {
    // Get user ID from Supabase - imported at usage site
    try {
      // Access via a method that can be set externally
      return _userId ?? 'anonymous';
    } catch (e) {
      return 'anonymous';
    }
  }

  String? _userId;
  void setUserId(String id) {
    _userId = id;
  }

  Future<Map<String, dynamic>?> _sendVoiceCommand(String userId, String command) async {
    try {
      final uri = Uri.parse('${_connectionService.serverUrl}/voice_command');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'user_id': userId,
          'command': command,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('❌ Voice command server error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Voice command network error: $e');
      return null;
    }
  }

  // ─── TTS ─────────────────────────────────────────────

  Future<void> _speak(String text) async {
    _lastResponse = text;
    _setState(VoiceAssistantState.speaking);
    notifyListeners();
    await _tts.speak(text);
  }

  // ─── Overlay Visibility ──────────────────────────────

  void _showOverlay() {
    _isOverlayVisible = true;
    notifyListeners();
  }

  void hideOverlay() {
    _isOverlayVisible = false;
    _setState(VoiceAssistantState.idle);
    _tts.stop();
    if (_stt.isListening) {
      _stt.stop();
    }
    notifyListeners();
    // Restart wake word
    if (_isWakeWordEnabled) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _startWakeWordListening();
      });
    }
  }

  void _hideOverlayAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_state == VoiceAssistantState.idle) {
        hideOverlay();
      }
    });
  }

  // ─── Helpers ─────────────────────────────────────────

  void _setState(VoiceAssistantState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _restartTimer?.cancel();
    _stt.stop();
    _tts.stop();
    super.dispose();
  }
}
