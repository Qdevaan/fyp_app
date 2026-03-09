import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';

/// Service that wraps Picovoice Porcupine for on-device wake word detection.
///
/// Uses the custom "Hey Bubbles" .ppn model for efficient, always-on,
/// offline wake word detection — far more reliable and battery-friendly
/// than the previous speech_to_text approach.
class WakeWordService extends ChangeNotifier with WidgetsBindingObserver {
  PorcupineManager? _porcupineManager;
  bool _isListening = false;
  bool _isInitialized = false;
  bool _isInitializing = false; // guard against concurrent init calls

  bool _wasListeningBeforePause = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  /// Callback fired when the wake word is detected.
  VoidCallback? onWakeWordDetected;

  // ─── Initialisation ───────────────────────────────────

  WakeWordService() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      if (_isListening) {
        _wasListeningBeforePause = true;
        stopListening();
        debugPrint('🎙️ Porcupine: Paused listening due to app backgrounding');
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasListeningBeforePause && !_isListening && _isInitialized) {
        startListening();
        _wasListeningBeforePause = false;
        debugPrint('🎙️ Porcupine: Resumed listening after app foregrounding');
      }
    }
  }

  /// Creates the PorcupineManager from the custom .ppn asset.
  /// Must be called once before [startListening].
  Future<void> init() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;

    final accessKey = dotenv.env['PICOVOICE_ACCESS_KEY'] ?? '';
    if (accessKey.isEmpty || accessKey == 'YOUR_PICOVOICE_ACCESS_KEY_HERE') {
      debugPrint('⚠️ Porcupine: No valid PICOVOICE_ACCESS_KEY found in .env');
      _isInitializing = false;
      return;
    }

    try {
      // Flutter assets live inside the APK at flutter_assets/, which the
      // Porcupine native SDK cannot resolve directly from a path string.
      // Extract the .ppn asset to the app's temp directory and pass that path.
      final keywordPath = await _extractAssetToFile(
        'assets/wake_word/hey-bubbles_en_android_v4_0_0.ppn',
        'hey-bubbles.ppn',
      );

      if (keywordPath == null) {
        debugPrint('❌ Porcupine: Failed to extract .ppn asset to temp file');
        _isInitializing = false;
        return;
      }

      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        accessKey,
        [keywordPath],
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
    } finally {
      _isInitializing = false;
    }
  }

  /// Copies a Flutter asset to the app's temp directory so the Porcupine
  /// native SDK can access it via a real filesystem path.
  Future<String?> _extractAssetToFile(String assetPath, String fileName) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        flush: true,
      );
      debugPrint('🎙️ Porcupine: Extracted .ppn to ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ Porcupine: Asset extraction error: $e');
      return null;
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
    WidgetsBinding.instance.removeObserver(this);
    _porcupineManager?.delete();
    _porcupineManager = null;
    _isInitialized = false;
    _isListening = false;
    super.dispose();
  }
}
