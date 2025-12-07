import 'dart:convert';

import 'package:http/http.dart' as http;
import 'connection_service.dart';

class ApiService {
  final ConnectionService _connectionService;

  ApiService(this._connectionService);

  String get _baseUrl => _connectionService.serverUrl;
  bool get isConnected => _connectionService.isConnected;

  Future<Map<String, dynamic>?> getLiveKitToken(String userId) async {
    if (_baseUrl.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getToken?userId=$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Token Error: $e");
    }
    return null;
  }

  // --- 1. VOICE ENROLLMENT ---
  /// Uploads audio to enroll the user's voice signature
  Future<void> enrollVoice({
    required String userId,
    required String userName,
    required String audioPath,
  }) async {
    if (_baseUrl.isEmpty) throw Exception('Server URL not set.');

    final uri = Uri.parse('$_baseUrl/enroll'); // Updated endpoint for Colab

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.fields['user_id'] = userId;
      request.fields['user_name'] = userName;
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Enrollment failed: $e');
    }
  }

  // --- 2. LIVE WINGMAN ---
  /// Sends a short audio chunk for live processing
  Future<Map<String, dynamic>> processAudioChunk(String filePath) async {
    if (_baseUrl.isEmpty) return {"transcript": "", "suggestion": "No Server URL"};

    try {
      var uri = Uri.parse("$_baseUrl/process_audio");
      var request = http.MultipartRequest('POST', uri);
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      var streamedResponse = await request.send().timeout(const Duration(seconds: 5));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Server Error (${response.statusCode}): ${response.body}");
        return {"transcript": "", "suggestion": ""}; // Return empty on error
      }
    } catch (e) {
      print("API Chunk Error: $e");
      return {"transcript": "", "suggestion": ""};
    }
  }

  // --- 3. SESSION SAVING ---
  /// Uploads the full session log for vector embedding
  Future<bool> saveSession(String userId, List<Map<String, dynamic>> logs) async {
    if (_baseUrl.isEmpty) return false;

    try {
      var uri = Uri.parse("$_baseUrl/save_session");
      
      // Flatten logs for context
      String fullTranscript = logs.map((l) => "${l['speaker']}: ${l['text']}").join("\n");

      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "user_id": userId,
          "transcript": fullTranscript,
          "logs": logs
        }),
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      print("Save Session Error: $e");
      return false;
    }
  }

  // --- 4. CONSULTANT ---
  /// Asks the AI a question based on history
  Future<String> askConsultant(String userId, String question) async {
    if (_baseUrl.isEmpty) return "Please connect to the server first.";

    try {
      var uri = Uri.parse("$_baseUrl/ask_consultant");
      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "user_id": userId,
          "question": question
        }),
      ).timeout(const Duration(seconds: 30)); // Llama 70B can be slow

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['answer'];
      }
      return "Brain Error: ${response.statusCode}";
    } catch (e) {
      return "Connection Error: $e";
    }
  }

  // --- 5. WINGMAN (TEXT) ---
  Future<String?> sendTranscriptToWingman(String userId, String transcript) async {
    if (_baseUrl.isEmpty) return null;

    try {
      var uri = Uri.parse("$_baseUrl/process_transcript_wingman");
      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "user_id": userId,
          "transcript": transcript
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['advice'];
      }
    } catch (e) {
      print("Wingman API Error: $e");
    }
    return null;
  }
}