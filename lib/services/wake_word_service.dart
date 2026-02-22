import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';

/// Service that wraps Picovoice Porcupine for on-device wake word detection.
///
/// Uses the custom "Hey Bubbles" .ppn model for efficient, always-on,
/// offline wake word detection — far more reliable and battery-friendly
/// than the previous speech_to_text approach.
class WakeWordService extends ChangeNotifier {
  PorcupineManager? _porcupineManager;
  bool _isListening = false;
  bool _isInitialized = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  /// Callback fired when the wake word is detected.
  VoidCallback? onWakeWordDetected;

  // ─── Initialisation ───────────────────────────────────

  /// Creates the PorcupineManager from the custom .ppn asset.
  /// Must be called once before [startListening].
  Future<void> init() async {
    if (_isInitialized) return;

    final accessKey = dotenv.env['PICOVOICE_ACCESS_KEY'] ?? '';
    if (accessKey.isEmpty || accessKey == 'YOUR_PICOVOICE_ACCESS_KEY_HERE') {
      debugPrint('⚠️ Porcupine: No valid PICOVOICE_ACCESS_KEY found in .env');
      return;
    }

    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        accessKey,
        ['assets/wake_word/hey-bubbles_en_android_v4_0_0.ppn'],
        _onWakeWordDetected,
        sensitivities: [0.7], // 0.0 (least sensitive) to 1.0 (most sensitive)
        errorCallback: _onError,
      );
      _isInitialized = true;
      debugPrint('🎙️ Porcupine: Initialized successfully');
    } on PorcupineException catch (e) {
      debugPrint('❌ Porcupine init error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Porcupine unexpected error: $e');
    }
  }

  // ─── Detection Callback ───────────────────────────────

  void _onWakeWordDetected(int keywordIndex) {
    debugPrint('🎙️ Porcupine: Wake word detected! (index: $keywordIndex)');
    // Notify the VoiceAssistantService
    onWakeWordDetected?.call();
  }

  void _onError(PorcupineException error) {
    debugPrint('❌ Porcupine runtime error: ${error.message}');
  }

  // ─── Listening Control ────────────────────────────────

  /// Start listening for the wake word.
  /// Porcupine handles its own audio capture via flutter_voice_processor.
  Future<void> startListening() async {
    if (!_isInitialized || _isListening) return;

    try {
      await _porcupineManager?.start();
      _isListening = true;
      debugPrint('🎙️ Porcupine: Listening for "Hey Bubbles"...');
      notifyListeners();
    } on PorcupineException catch (e) {
      debugPrint('❌ Porcupine start error: ${e.message}');
    }
  }

  /// Stop listening for the wake word.
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _porcupineManager?.stop();
      _isListening = false;
      debugPrint('🎙️ Porcupine: Stopped listening');
      notifyListeners();
    } on PorcupineException catch (e) {
      debugPrint('❌ Porcupine stop error: ${e.message}');
    }
  }

  // ─── Cleanup ──────────────────────────────────────────

  @override
  void dispose() {
    _porcupineManager?.delete();
    _porcupineManager = null;
    _isInitialized = false;
    _isListening = false;
    super.dispose();
  }
}
