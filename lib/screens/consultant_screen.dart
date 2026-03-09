import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/design_tokens.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/connection_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/consultant/voice_mode.dart';
import '../widgets/consultant/consultant_widgets.dart';

// â”€â”€â”€ Voice mode state for the consultant â”€â”€â”€â”€â”€â”€â”€â”€


// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  CONSULTANT SCREEN  (ChatGPT-style multi-chat)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class ConsultantScreen extends StatefulWidget {
  const ConsultantScreen({super.key});

  @override
  State<ConsultantScreen> createState() => _ConsultantScreenState();
}

class _ConsultantScreenState extends State<ConsultantScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _supabase = Supabase.instance.client;

  // â”€â”€ Current chat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String? _currentSessionId;
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  bool _showScrollToBottom = false;

  // â”€â”€ Drawer / past chats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<Map<String, dynamic>> _pastChats = [];
  bool _drawerLoading = false;
  bool _drawerLoaded = false;
  bool _loadingChat = false; // loading messages for a selected past chat

  // â”€â”€ Hands-free voice mode â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  CVoiceMode _voiceMode = CVoiceMode.off;
  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;
  final AudioPlayer _ttsPlayer = AudioPlayer();
  String _voicePartial = '';
  bool _voiceModeActive = false; // true when the loop should keep running
  late final AnimationController _micPulse;
  late final Animation<double> _micPulseAnim;

  static const _welcomeMsg =
      "Hello! I'm your Consultant AI.\import '../widgets/consultant/voice_mode.dart';\nimport '../widgets/consultant/consultant_widgets.dart';\nn\nI have access to your **knowledge graph**, **session memories**, and **past summaries**. Ask me anything about your conversations, relationships, or decisions.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);
    _messages.add({"role": "ai", "text": _welcomeMsg});

    // Mic pulse animation (used when listening)
    _micPulse = AnimationController(
      vsync: this as TickerProvider,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _micPulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _micPulse, curve: Curves.easeInOut),
    );

    _initVoice();
  }

  bool _processedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_processedArgs) {
      _processedArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('initialQuery')) {
        final query = args['initialQuery'] as String;
        // Schedule sending after initial frame renders
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _controller.text = ""; // Don't keep it in the text box if sending via voice
          // Clean the query: e.g., "tell me when is saras birthday" -> "when is saras birthday"
          String cleanQuery = query.toLowerCase();
          if (cleanQuery.startsWith('tell me ')) {
            cleanQuery = cleanQuery.replaceFirst('tell me ', '');
          }
          if (cleanQuery.startsWith('what is ')) {
            cleanQuery = cleanQuery.replaceFirst('what is ', '');
          }
          if (cleanQuery.startsWith('who is ')) {
            cleanQuery = cleanQuery.replaceFirst('who is ', '');
          }
          
          _voiceModeActive = true; 
          _setVoiceMode(CVoiceMode.processing);
          _sendVoiceMessage(cleanQuery);
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _micPulse.dispose();
    _ttsPlayer.dispose();
    _stt.stop();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = View.of(context).viewInsets.bottom;
    if (bottomInset > 0.0) _scrollToBottom();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final diff = _scrollController.position.maxScrollExtent - _scrollController.offset;
    final show = diff > 200;
    if (show != _showScrollToBottom) setState(() => _showScrollToBottom = show);
  }

  // â”€â”€ New / clear chat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _newChat() {
    Navigator.pop(context); // close drawer
    setState(() {
      _currentSessionId = null;
      _messages
        ..clear()
        ..add({"role": "ai", "text": _welcomeMsg});
    });
  }

  // â”€â”€ Load sidebar chat list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadPastChats() async {
    if (_drawerLoading) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    setState(() => _drawerLoading = true);
    try {
      // Fetch all rows grouped by session_id; first question = title
      final rows = List<Map<String, dynamic>>.from(
        await _supabase
            .from('consultant_logs')
            .select('session_id, question, created_at')
            .eq('user_id', user.id)
            .not('session_id', 'is', null)
            .order('created_at', ascending: true),
      );

      final Map<String, Map<String, dynamic>> seen = {};
      for (final r in rows) {
        final sid = r['session_id'] as String?;
        if (sid == null) continue;
        seen.putIfAbsent(sid, () => {
          'session_id': sid,
          'title': r['question'] as String? ?? 'Chat',
          'created_at': r['created_at'] as String? ?? '',
        });
      }

      // Sort most-recent first
      final list = seen.values.toList()
        ..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));

      if (mounted) {
        setState(() {
          _pastChats = list;
          _drawerLoading = false;
          _drawerLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('_loadPastChats error: $e');
      if (mounted) setState(() => _drawerLoading = false);
    }
  }

  // â”€â”€ Load messages for a selected past chat â”€
  Future<void> _loadChatById(String sessionId) async {
    if (_loadingChat) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    Navigator.pop(context); // close drawer immediately
    setState(() {
      _loadingChat = true;
      _messages.clear();
    });

    try {
      final rows = List<Map<String, dynamic>>.from(
        await _supabase
            .from('consultant_logs')
            .select('question, answer, created_at')
            .eq('session_id', sessionId)
            .eq('user_id', user.id)
            .order('created_at', ascending: true),
      );

      if (mounted) {
        setState(() {
          _currentSessionId = sessionId;
          for (final r in rows) {
            if (r['question'] != null) _messages.add({"role": "user", "text": r['question'] as String});
            if (r['answer'] != null) _messages.add({"role": "ai", "text": r['answer'] as String});
          }
          if (_messages.isEmpty) {
            _messages.add({"role": "ai", "text": "This conversation appears to be empty."});
          }
          _loadingChat = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      debugPrint('_loadChatById error: $e');
      if (mounted) setState(() => _loadingChat = false);
    }
  }

  // â”€â”€ Not-connected dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _showNotConnectedDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Not Connected',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'The Consultant AI requires a server connection. Please connect first in Settings.',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/connections');
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Connect',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Send message (SSE streaming) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading || _loadingChat) return;

    // Connection check
    final conn = Provider.of<ConnectionService>(context, listen: false);
    if (!conn.isConnected) {
      _showNotConnectedDialog();
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not logged in."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _messages.add({"role": "user", "text": text, "time": _nowTime()});
      _loading = true;
      _controller.clear();
    });
    _scrollToBottom();

    final api = Provider.of<ApiService>(context, listen: false);
    final buf = StringBuffer();
    bool firstToken = true;

    try {
      final stream = api.askConsultantStream(
        user.id,
        text,
        sessionId: _currentSessionId,
        onSessionCreated: (sid) {
          if (mounted) {
            setState(() {
              _currentSessionId = sid;
              _drawerLoaded = false; // stale â€” will reload on next drawer open
            });
          }
        },
      );

      final aiTime = _nowTime();
      await for (final token in stream) {
        if (!mounted) break;
        buf.write(token);
        if (firstToken) {
          setState(() {
            _loading = false;
            _messages.add({"role": "ai", "text": buf.toString(), "streaming": "true", "time": aiTime});
          });
          firstToken = false;
        } else {
          setState(() => _messages.last = {"role": "ai", "text": buf.toString(), "streaming": "true", "time": aiTime});
        }
        _scrollToBottom();
      }

      if (mounted) {
        setState(() {
          if (_messages.isNotEmpty && _messages.last['streaming'] == 'true') {
            _messages.last = {"role": "ai", "text": buf.toString(), "time": _messages.last['time'] ?? _nowTime()};
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (firstToken) {
            _messages.add({"role": "ai", "text": "Error connecting to consultant: $e", "time": _nowTime()});
          } else {
            _messages.last = {"role": "ai", "text": buf.isEmpty ? "Error: $e" : buf.toString(), "time": _messages.last['time'] ?? _nowTime()};
          }
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // â”€â”€ Current time helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _nowTime() {
    final dt = DateTime.now();
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:$m $period';
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  HANDS-FREE VOICE MODE
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  Future<void> _initVoice() async {
    _sttReady = await _stt.initialize(
      onError: (e) => debugPrint('ðŸŽ™ï¸ STT error: ${e.errorMsg}'),
    );
    // When TTS audio ends, auto-restart listening if still in voice mode
    _ttsPlayer.onPlayerComplete.listen((_) {
      if (_voiceModeActive && mounted) {
        _setVoiceMode(CVoiceMode.listening);
        _startSTT();
      }
    });
  }

  void _setVoiceMode(CVoiceMode mode) {
    if (!mounted) return;
    setState(() => _voiceMode = mode);
  }

  /// Toggle hands-free mode on / off.
  void _toggleVoiceMode() {
    if (_voiceMode == CVoiceMode.off) {
      _startVoiceMode();
    } else {
      _stopVoiceMode();
    }
  }

  void _startVoiceMode() {
    if (!_sttReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone not available.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    _voiceModeActive = true;
    _setVoiceMode(CVoiceMode.listening);
    _startSTT();
  }

  void _stopVoiceMode() {
    _voiceModeActive = false;
    _ttsPlayer.stop();
    _stt.stop();
    _setVoiceMode(CVoiceMode.off);
    setState(() => _voicePartial = '');
  }

  /// Interrupt mid-speak / mid-listen and start listening instead.
  void _interruptAndListen() {
    if (_voiceMode == CVoiceMode.speaking) {
      _ttsPlayer.stop(); // onPlayerComplete will NOT fire when stopped manually
      _setVoiceMode(CVoiceMode.listening);
      _startSTT();
    }
  }

  void _startSTT() {
    if (!_sttReady || !_voiceModeActive) return;
    setState(() => _voicePartial = '');
    _stt.listen(
      onResult: _onSTTResult,
      listenMode: ListenMode.dictation,
      pauseFor: const Duration(seconds: 2),
      cancelOnError: false,
      partialResults: true,
    );
  }

  void _onSTTResult(SpeechRecognitionResult result) {
    if (!mounted || !_voiceModeActive) return;
    setState(() => _voicePartial = result.recognizedWords);
    if (result.finalResult) {
      final text = result.recognizedWords.trim();
      if (text.isEmpty) {
        // Nothing heard â€” keep listening
        _startSTT();
        return;
      }
      _sendVoiceMessage(text);
    }
  }

  Future<void> _sendVoiceMessage(String text) async {
    if (!mounted || !_voiceModeActive) return;

    // Connection check
    final conn = Provider.of<ConnectionService>(context, listen: false);
    if (!conn.isConnected) {
      _stopVoiceMode();
      _showNotConnectedDialog();
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) return;

    setState(() {
      _voicePartial = '';
      _messages.add({'role': 'user', 'text': text, 'time': _nowTime()});
      _voiceMode = CVoiceMode.processing;
      _loading = true;
    });
    _scrollToBottom();

    final api = Provider.of<ApiService>(context, listen: false);
    final buf = StringBuffer();
    bool firstToken = true;

    try {
      final stream = api.askConsultantStream(
        user.id,
        text,
        sessionId: _currentSessionId,
        onSessionCreated: (sid) {
          if (mounted) {
            setState(() {
              _currentSessionId = sid;
              _drawerLoaded = false;
            });
          }
        },
      );

      final aiTime = _nowTime();
      await for (final token in stream) {
        if (!mounted || !_voiceModeActive) break;
        buf.write(token);
        if (firstToken) {
          setState(() {
            _loading = false;
            _messages.add({'role': 'ai', 'text': buf.toString(), 'streaming': 'true', 'time': aiTime});
            _voiceMode = CVoiceMode.speaking; // show speaking state while streaming
          });
          firstToken = false;
        } else {
          setState(() => _messages.last = {'role': 'ai', 'text': buf.toString(), 'streaming': 'true', 'time': aiTime});
        }
        _scrollToBottom();
      }

      if (mounted) {
        setState(() {
          _loading = false;
          if (_messages.isNotEmpty && _messages.last['streaming'] == 'true') {
            _messages.last = {'role': 'ai', 'text': buf.toString(), 'time': _messages.last['time'] ?? _nowTime()};
          }
        });
      }

      // Speak the completed response
      if (_voiceModeActive && buf.isNotEmpty) {
        await _speakText(buf.toString());
      }
    } catch (e) {
      if (mounted && _voiceModeActive) {
        setState(() {
          if (firstToken) {
            _messages.add({'role': 'ai', 'text': 'Error: $e', 'time': _nowTime()});
          }
          _loading = false;
          _voiceMode = CVoiceMode.listening;
        });
        _startSTT();
      }
    }
  }

  /// Calls Deepgram Aura TTS and plays the audio.
  /// After playback ends, `onPlayerComplete` restarts listening automatically.
  Future<void> _speakText(String text) async {
    if (!_voiceModeActive || !mounted) return;

    // Strip markdown for TTS (basic)
    final plain = text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
        .replaceAll(RegExp(r'#+\s'), '')
        .replaceAll(RegExp(r'`(.+?)`'), r'$1')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();

    final apiKey = dotenv.env['DEEPGRAM_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      debugPrint('âš ï¸ No Deepgram API key â€” skipping TTS');
      if (_voiceModeActive && mounted) {
        _setVoiceMode(CVoiceMode.listening);
        _startSTT();
      }
      return;
    }

    _setVoiceMode(CVoiceMode.speaking);

    try {
      final response = await http.post(
        Uri.parse('https://api.deepgram.com/v1/speak?model=aura-orpheus-en'),
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': plain}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/consultant_tts.mp3');
        await file.writeAsBytes(response.bodyBytes);
        await _ttsPlayer.play(DeviceFileSource(file.path));
        // onPlayerComplete in _initVoice handles restarting STT
      } else {
        debugPrint('âŒ TTS error: ${response.statusCode}');
        if (_voiceModeActive && mounted) {
          _setVoiceMode(CVoiceMode.listening);
          _startSTT();
        }
      }
    } catch (e) {
      debugPrint('âŒ TTS network error: $e');
      if (_voiceModeActive && mounted) {
        _setVoiceMode(CVoiceMode.listening);
        _startSTT();
      }
    }
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _chatTitle(Map<String, dynamic> chat) {
    final q = chat['title'] as String? ?? 'Chat';
    return q.length > 48 ? '${q.substring(0, 48)}â€¦' : q;
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  // â”€â”€ Drawer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDrawer(bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
              child: Row(
                children: [
                  AppLogo(size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Conversations',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'New chat',
                    onPressed: _newChat,
                    icon: Icon(Icons.edit_square, color: primary, size: 22),
                  ),
                ],
              ),
            ),

            Divider(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200, height: 1),

            // New Chat tile
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: primary, size: 20),
              ),
              title: Text(
                'New Chat',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: primary,
                ),
              ),
              onTap: _newChat,
            ),

            if (_drawerLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_drawerLoaded && _pastChats.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No past conversations yet.\nStart chatting to build history.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF475569) : Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              )
            else if (_drawerLoaded)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  itemCount: _pastChats.length,
                  itemBuilder: (_, i) {
                    final chat = _pastChats[i];
                    final sid = chat['session_id'] as String;
                    final isActive = sid == _currentSessionId;
                    return ChatHistoryTile(
                      title: _chatTitle(chat),
                      date: _formatDate(chat['created_at'] as String?),
                      isActive: isActive,
                      isDark: isDark,
                      onTap: () => _loadChatById(sid),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(isDark),
      onDrawerChanged: (isOpen) {
        if (isOpen && !_drawerLoaded && !_drawerLoading) _loadPastChats();
      },
      body: SafeArea(
        child: Column(
          children: [
            // â”€â”€ TOP BAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.9),
                border: Border(bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                )),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    // Drawer / menu button
                    IconButton(
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: Icon(Icons.menu_rounded,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        'Consultant',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    // Hands-free mic toggle
                    MicToggleButton(
                      voiceMode: _voiceMode,
                      onTap: () {
                        if (_voiceMode == CVoiceMode.speaking) {
                          _interruptAndListen();
                        } else {
                          _toggleVoiceMode();
                        }
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // â”€â”€ CONNECTION BANNER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Consumer<ConnectionService>(
              builder: (_, conn, __) => conn.isConnected
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/connections'),
                      child: Container(
                        width: double.infinity,
                        color: Colors.redAccent.withOpacity(0.12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 15),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Not connected to server â€” tap to connect',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.redAccent, size: 16),
                          ],
                        ),
                      ),
                    ),
            ),

            // â”€â”€ CHAT AREA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: Stack(
                children: [
                  _loadingChat
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                          itemCount: _messages.length + (_loading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_loading && index == _messages.length) {
                              return TypingIndicator(isDark: isDark);
                            }
                            final msg = _messages[index];
                            final isUser = msg['role'] == "user";
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: isUser
                                  ? UserBubble(
                                      text: msg['text']!,
                                      isDark: isDark,
                                      time: msg['time'],
                                    )
                                  : AiBubble(
                                      text: msg['text']!,
                                      isDark: isDark,
                                      streaming: msg['streaming'] == 'true',
                                      time: msg['time'],
                                    ),
                            );
                          },
                        ),

                  // Scroll-to-bottom fab
                  if (_showScrollToBottom)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: _scrollToBottom,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // â”€â”€ VOICE STATUS BANNER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_voiceMode != CVoiceMode.off)
              VoiceStatusBanner(
                voiceMode: _voiceMode,
                partial: _voicePartial,
                isDark: isDark,
                micPulseAnim: _micPulseAnim,
                onStop: _stopVoiceMode,
              ),

            // â”€â”€ INPUT AREA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                border: Border(top: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                )),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLines: 4,
                              minLines: 1,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ask about your conversations...',
                                hintStyle: GoogleFonts.manrope(
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: (_loading || _loadingChat) ? null : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (_loading || _loadingChat)
                            ? (isDark ? AppColors.surfaceDark : Colors.grey.shade300)
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: (_loading || _loadingChat)
                            ? null
                            : [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  DRAWER TILE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
