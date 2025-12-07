import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class DeepgramService extends ChangeNotifier {
  // CONFIG
  static const String _apiKey = "8f4f1c36dd57bd1fdeb2d77841d095bb5e8c1983"; 
  // Removed encoding=linear16 to allow auto-detection (since we are sending AAC/Container)
  // Kept sample_rate=16000 just in case, but Deepgram usually detects it.
  // Actually, for AAC, it's safer to let Deepgram detect everything.
  static const String _wsUrl = "wss://api.deepgram.com/v1/listen?smart_format=true&diarize=true&model=nova-2";

  // STATE
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String _currentTranscript = "";
  String get currentTranscript => _currentTranscript;

  String _currentSpeaker = "user";
  String get currentSpeaker => _currentSpeaker;

  // INTERNAL
  final AudioRecorder _recorder = AudioRecorder();
  WebSocketChannel? _channel;
  StreamSubscription? _audioStreamSubscription;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // 1. Check Permissions
      if (!await _recorder.hasPermission()) {
        print("❌ DeepgramService: No microphone permission");
        return;
      }

      // 2. Connect WebSocket with Auth Header
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        headers: {'Authorization': 'Token $_apiKey'},
      );

      await _channel!.ready;
      print("✅ DeepgramService: WebSocket Connected");
      _isConnected = true;
      notifyListeners();

      // 3. Start Audio Stream
      // Using AAC LC which is generally supported for streaming
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, 
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      // 4. Send Audio to WebSocket
      _audioStreamSubscription = stream.listen((data) {
        if (_channel != null) {
          _channel!.sink.add(data);
        }
      });

      // 5. Listen for Transcripts
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print("❌ DeepgramService: WebSocket Error: $error");
          disconnect();
        },
        onDone: () {
          print("⚠️ DeepgramService: WebSocket Closed");
          disconnect();
        },
      );

    } catch (e) {
      print("❌ DeepgramService: Connection Failed: $e");
      disconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      // Check if it's a transcript
      if (data['type'] == 'Results') {
         // Deepgram format: channel -> alternatives -> [0] -> transcript
         // Diarization: words -> speaker
         final channel = data['channel'];
         final alternatives = channel['alternatives'] as List;
         if (alternatives.isNotEmpty) {
           final alt = alternatives[0];
           final transcript = alt['transcript'] as String;
           
           if (transcript.trim().isNotEmpty && data['is_final'] == true) {
             // Extract Speaker
             int speakerId = 0;
             if (alt['words'] != null && (alt['words'] as List).isNotEmpty) {
               speakerId = alt['words'][0]['speaker'];
             }
             
             _currentTranscript = transcript;
             _currentSpeaker = speakerId == 0 ? "user" : "other"; // Simple mapping
             
             print("🗣️ Deepgram: [$_currentSpeaker] $transcript");
             notifyListeners();
           }
         }
      }
    } catch (e) {
      print("Error parsing Deepgram message: $e");
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    notifyListeners();

    await _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;

    await _recorder.stop();
    
    await _channel?.sink.close();
    _channel = null;
  }
}
