import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connection_service.dart';

class ApiService {
  final ConnectionService _connectionService;

  ApiService(this._connectionService);

  String get _baseUrl => _connectionService.serverUrl;
  bool get isConnected => _connectionService.isConnected;

  // ── Retry with exponential backoff ──
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(milliseconds: 500);

  /// Retries [action] up to [_maxRetries] times with exponential backoff + jitter.
  /// Only retries on network / timeout errors – not on successful HTTP responses.
  Future<T> _withRetry<T>(Future<T> Function() action, {int? maxRetries}) async {
    final retries = maxRetries ?? _maxRetries;
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        return await action();
      } on TimeoutException {
        if (attempt == retries) rethrow;
      } on http.ClientException {
        if (attempt == retries) rethrow;
      } catch (e) {
        // Don't retry on non-network errors (e.g. FormatException)
        if (e is! TimeoutException && e is! http.ClientException) rethrow;
      }
      final delay = _baseDelay * pow(2, attempt).toInt();
      final jitter = Duration(milliseconds: Random().nextInt(delay.inMilliseconds ~/ 2 + 1));
      await Future.delayed(delay + jitter);
      debugPrint('Retry attempt ${attempt + 1}/$retries');
    }
    throw TimeoutException('All $retries retries exhausted');
  }

  Future<Map<String, dynamic>?> getLiveKitToken(String userId) async {
    if (_baseUrl.isEmpty) return null;
    try {
      return await _withRetry(() async {
        final response = await http.post(
          Uri.parse('$_baseUrl/getToken'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
          body: jsonEncode({'userId': userId}),
        ).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        return null;
      });
    } catch (e) {
      debugPrint("Token Error: $e");
    }
    return null;
  }

  // --- 1. VOICE ENROLLMENT ---
  /// Uploads audio to enroll the user's voice signature.
  /// Returns the enrolled_at timestamp string if successful, throws otherwise.
  Future<String> enrollVoice({
    required String userId,
    required String userName,
    required String audioPath,
  }) async {
    if (_baseUrl.isEmpty) throw Exception('Server URL not set.');

    final uri = Uri.parse('$_baseUrl/enroll');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.fields['user_id'] = userId;
      request.fields['user_name'] = userName;
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception(
          'Server error ${response.statusCode}: ${response.body}',
        );
      }

      // Confirm the embedding was actually persisted in Supabase
      final status = await checkEnrollmentStatus(userId);
      if (status == null) {
        throw Exception(
          'Enrollment uploaded but embedding not found in database.',
        );
      }
      return status;
    } catch (e) {
      throw Exception('Enrollment failed: $e');
    }
  }

  /// Queries voice_enrollments to verify the embedding row exists.
  /// Returns the enrolled_at timestamp string, or null if not enrolled.
  Future<String?> checkEnrollmentStatus(String userId) async {
    try {
      final res = await Supabase.instance.client
          .from('voice_enrollments')
          .select('enrolled_at')
          .eq('user_id', userId)
          .maybeSingle();
      return res?['enrolled_at'] as String?;
    } catch (e) {
      debugPrint('checkEnrollmentStatus error: $e');
      return null;
    }
  }

  // --- 2. LIVE WINGMAN ---
  /// Sends a short audio chunk for live processing
  Future<Map<String, dynamic>> processAudioChunk(String filePath) async {
    if (_baseUrl.isEmpty)
      return {"transcript": "", "suggestion": "No Server URL"};

    try {
      var uri = Uri.parse("$_baseUrl/process_audio");
      var request = http.MultipartRequest('POST', uri);
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Server Error (${response.statusCode}): ${response.body}");
        return {"transcript": "", "suggestion": ""}; // Return empty on error
      }
    } catch (e) {
      debugPrint("API Chunk Error: $e");
      return {"transcript": "", "suggestion": ""};
    }
  }

  // --- 3. SESSION SAVING ---
  /// Uploads the full session log for vector embedding
  Future<bool> saveSession(
    String userId,
    List<Map<String, dynamic>> logs,
  ) async {
    if (_baseUrl.isEmpty) return false;

    try {
      return await _withRetry(() async {
        var uri = Uri.parse("$_baseUrl/save_session");
        String fullTranscript = logs
            .map((l) => "${l['speaker']}: ${l['text']}")
            .join("\n");

        var response = await http
            .post(
              uri,
              headers: {
                "Content-Type": "application/json",
                "ngrok-skip-browser-warning": "true",
              },
              body: jsonEncode({
                "user_id": userId,
                "transcript": fullTranscript,
                "logs": logs,
              }),
            )
            .timeout(const Duration(seconds: 15));

        return response.statusCode == 200;
      });
    } catch (e) {
      debugPrint("Save Session Error: $e");
      return false;
    }
  }

  // --- 4. CONSULTANT ---
  /// Asks the AI a question based on history
  Future<String> askConsultant(String userId, String question) async {
    if (_baseUrl.isEmpty) return "Please connect to the server first.";

    try {
      return await _withRetry(() async {
      var uri = Uri.parse("$_baseUrl/ask_consultant");
      var response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
              "ngrok-skip-browser-warning": "true",
            },
            body: jsonEncode({"user_id": userId, "question": question}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['answer'] as String;
      }
      return "Brain Error: ${response.statusCode}";
      });
    } catch (e) {
      return "Connection Error: $e";
    }
  }

  // --- 5. WINGMAN (TEXT) ---
  Future<String?> sendTranscriptToWingman(
    String userId,
    String transcript, {
    String? sessionId,
    String speakerRole = 'others',
  }) async {
    if (_baseUrl.isEmpty) return null;

    try {
      return await _withRetry(() async {
      var uri = Uri.parse("$_baseUrl/process_transcript_wingman");
      final body = <String, dynamic>{
        "user_id": userId,
        "transcript": transcript,
        "speaker_role": speakerRole,
        if (sessionId != null) "session_id": sessionId,
      };
      var response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
              "ngrok-skip-browser-warning": "true",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['advice'] as String?;
      }
      return null;
      });
    } catch (e) {
      debugPrint("Wingman API Error: $e");
    }
    return null;
  }

  // --- 6. SESSION LIFECYCLE ---
  /// Creates a new live session on the server and returns the session_id.
  Future<String?> createLiveSession(String userId) async {
    if (_baseUrl.isEmpty) return null;
    try {
      return await _withRetry(() async {
        final res = await http
            .post(
              Uri.parse("$_baseUrl/start_session"),
              headers: {
                "Content-Type": "application/json",
                "ngrok-skip-browser-warning": "true",
              },
              body: jsonEncode({"user_id": userId, "mode": "live_wingman"}),
            )
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          return jsonDecode(res.body)['session_id'] as String?;
        }
        return null;
      });
    } catch (e) {
      debugPrint("createLiveSession error: $e");
    }
    return null;
  }

  /// Ends a live session: fetches transcript, generates summary, marks completed.
  Future<void> endLiveSession(String sessionId, String userId) async {
    if (_baseUrl.isEmpty) return;
    try {
      await _withRetry(() async {
        await http
            .post(
              Uri.parse("$_baseUrl/end_session"),
              headers: {
                "Content-Type": "application/json",
                "ngrok-skip-browser-warning": "true",
              },
              body: jsonEncode({"session_id": sessionId, "user_id": userId}),
            )
            .timeout(const Duration(seconds: 30));
      });
    } catch (e) {
      debugPrint("endLiveSession error: $e");
    }
  }

  // --- 7. STREAMING CONSULTANT (SSE) ---
  /// Streams tokens from /ask_consultant_stream via Server-Sent Events.
  /// Yields text tokens one at a time. Caller should concatenate them.
  /// [onSessionCreated] is called once with the session_id when the stream ends.
  Stream<String> askConsultantStream(
    String userId,
    String question, {
    String? sessionId,
    void Function(String sessionId)? onSessionCreated,
  }) async* {
    if (_baseUrl.isEmpty) {
      yield 'Please connect to the server first.';
      return;
    }
    final client = http.Client();
    try {
      final request = http.Request(
        'POST',
        Uri.parse("$_baseUrl/ask_consultant_stream"),
      );
      request.headers['Content-Type'] = 'application/json';
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.headers['Accept'] = 'text/event-stream';
      request.body = jsonEncode({
        'user_id': userId,
        'question': question,
        if (sessionId != null) 'session_id': sessionId,
      });

      final streamedResponse = await client
          .send(request)
          .timeout(const Duration(seconds: 60));
      if (streamedResponse.statusCode != 200) {
        yield 'Server error: ${streamedResponse.statusCode}';
        return;
      }

      String buffer = '';
      await for (final bytes in streamedResponse.stream) {
        buffer += utf8.decode(bytes, allowMalformed: true);
        // Process complete SSE lines
        while (buffer.contains('\n')) {
          final idx = buffer.indexOf('\n');
          final line = buffer.substring(0, idx).trim();
          buffer = buffer.substring(idx + 1);
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            try {
              final parsed = jsonDecode(data) as Map<String, dynamic>;
              if (parsed['token'] != null) {
                yield parsed['token'] as String;
              } else if (parsed['done'] == true) {
                final sid = parsed['session_id'] as String?;
                if (sid != null && onSessionCreated != null)
                  onSessionCreated(sid);
                return;
              } else if (parsed['error'] != null) {
                yield '\n[Error: ${parsed['error']}]';
                return;
              }
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      yield '\n[Connection error: $e]';
    } finally {
      client.close();
    }
  }

  // --- 8. ASK ABOUT ENTITY ---
  /// Returns an AI summary of everything known about a named entity.
  Future<String> askAboutEntity(String userId, String entityName) async {
    if (_baseUrl.isEmpty) return 'Server not connected.';
    try {
      final res = await http
          .post(
            Uri.parse("$_baseUrl/ask_entity"),
            headers: {
              "Content-Type": "application/json",
              "ngrok-skip-browser-warning": "true",
            },
            body: jsonEncode({"user_id": userId, "entity_name": entityName}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['answer'] as String? ?? '—';
      }
      return 'Error: ${res.statusCode}';
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  Future<Map<String, dynamic>?> parseVoiceCommand(
    String userId,
    String command,
  ) async {
    if (!_connectionService.isConnected) return null;
    final url = Uri.parse("${_connectionService.serverUrl}/voice_command");
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'user_id': userId, 'command': command}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Voice command parse error: $e');
      return null;
    }
  }
}
