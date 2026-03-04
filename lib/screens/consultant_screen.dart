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

// ─── Voice mode state for the consultant ────────
enum _CVoiceMode { off, listening, processing, speaking }

// ────────────────────────────────────────────
//  CONSULTANT SCREEN  (ChatGPT-style multi-chat)
// ────────────────────────────────────────────
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

  // ── Current chat ──────────────────────────
  String? _currentSessionId;
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  bool _showScrollToBottom = false;

  // ── Drawer / past chats ───────────────────
  List<Map<String, dynamic>> _pastChats = [];
  bool _drawerLoading = false;
  bool _drawerLoaded = false;
  bool _loadingChat = false; // loading messages for a selected past chat

  // ── Hands-free voice mode ─────────────────
  _CVoiceMode _voiceMode = _CVoiceMode.off;
  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;
  final AudioPlayer _ttsPlayer = AudioPlayer();
  String _voicePartial = '';
  bool _voiceModeActive = false; // true when the loop should keep running
  late final AnimationController _micPulse;
  late final Animation<double> _micPulseAnim;

  static const _welcomeMsg =
      "Hello! I'm your Consultant AI.\n\nI have access to your **knowledge graph**, **session memories**, and **past summaries**. Ask me anything about your conversations, relationships, or decisions.";

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

  // ── New / clear chat ──────────────────────
  void _newChat() {
    Navigator.pop(context); // close drawer
    setState(() {
      _currentSessionId = null;
      _messages
        ..clear()
        ..add({"role": "ai", "text": _welcomeMsg});
    });
  }

  // ── Load sidebar chat list ─────────────────
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

  // ── Load messages for a selected past chat ─
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

  // ── Not-connected dialog ─────────────────
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

  // ── Send message (SSE streaming) ───────────
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
              _drawerLoaded = false; // stale — will reload on next drawer open
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

  // ── Current time helper ──────────────────────
  String _nowTime() {
    final dt = DateTime.now();
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:$m $period';
  }

  // ══════════════════════════════════════════════════════════
  //  HANDS-FREE VOICE MODE
  // ══════════════════════════════════════════════════════════

  Future<void> _initVoice() async {
    _sttReady = await _stt.initialize(
      onError: (e) => debugPrint('🎙️ STT error: ${e.errorMsg}'),
    );
    // When TTS audio ends, auto-restart listening if still in voice mode
    _ttsPlayer.onPlayerComplete.listen((_) {
      if (_voiceModeActive && mounted) {
        _setVoiceMode(_CVoiceMode.listening);
        _startSTT();
      }
    });
  }

  void _setVoiceMode(_CVoiceMode mode) {
    if (!mounted) return;
    setState(() => _voiceMode = mode);
  }

  /// Toggle hands-free mode on / off.
  void _toggleVoiceMode() {
    if (_voiceMode == _CVoiceMode.off) {
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
    _setVoiceMode(_CVoiceMode.listening);
    _startSTT();
  }

  void _stopVoiceMode() {
    _voiceModeActive = false;
    _ttsPlayer.stop();
    _stt.stop();
    _setVoiceMode(_CVoiceMode.off);
    setState(() => _voicePartial = '');
  }

  /// Interrupt mid-speak / mid-listen and start listening instead.
  void _interruptAndListen() {
    if (_voiceMode == _CVoiceMode.speaking) {
      _ttsPlayer.stop(); // onPlayerComplete will NOT fire when stopped manually
      _setVoiceMode(_CVoiceMode.listening);
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
        // Nothing heard — keep listening
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
      _voiceMode = _CVoiceMode.processing;
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
            _voiceMode = _CVoiceMode.speaking; // show speaking state while streaming
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
          _voiceMode = _CVoiceMode.listening;
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
      debugPrint('⚠️ No Deepgram API key — skipping TTS');
      if (_voiceModeActive && mounted) {
        _setVoiceMode(_CVoiceMode.listening);
        _startSTT();
      }
      return;
    }

    _setVoiceMode(_CVoiceMode.speaking);

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
        debugPrint('❌ TTS error: ${response.statusCode}');
        if (_voiceModeActive && mounted) {
          _setVoiceMode(_CVoiceMode.listening);
          _startSTT();
        }
      }
    } catch (e) {
      debugPrint('❌ TTS network error: $e');
      if (_voiceModeActive && mounted) {
        _setVoiceMode(_CVoiceMode.listening);
        _startSTT();
      }
    }
  }

  // ══════════════════════════════════════════════════════════

  // ── Helpers ────────────────────────────────
  String _chatTitle(Map<String, dynamic> chat) {
    final q = chat['title'] as String? ?? 'Chat';
    return q.length > 48 ? '${q.substring(0, 48)}…' : q;
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

  // ── Drawer ─────────────────────────────────
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
                    return _ChatHistoryTile(
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

  // ── Build ──────────────────────────────────
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
            // ── TOP BAR ──────────────────────────────
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
                    _MicToggleButton(
                      voiceMode: _voiceMode,
                      onTap: () {
                        if (_voiceMode == _CVoiceMode.speaking) {
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

            // ── CONNECTION BANNER ────────────────────
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
                                'Not connected to server — tap to connect',
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

            // ── CHAT AREA ─────────────────────────────
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
                              return _TypingIndicator(isDark: isDark);
                            }
                            final msg = _messages[index];
                            final isUser = msg['role'] == "user";
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: isUser
                                  ? _UserBubble(
                                      text: msg['text']!,
                                      isDark: isDark,
                                      time: msg['time'],
                                    )
                                  : _AiBubble(
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

            // ── VOICE STATUS BANNER ───────────────────────
            if (_voiceMode != _CVoiceMode.off)
              _VoiceStatusBanner(
                voiceMode: _voiceMode,
                partial: _voicePartial,
                isDark: isDark,
                micPulseAnim: _micPulseAnim,
                onStop: _stopVoiceMode,
              ),

            // ── INPUT AREA ────────────────────────────
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

// ────────────────────────────────────────────
//  DRAWER TILE
// ────────────────────────────────────────────
class _ChatHistoryTile extends StatelessWidget {
  final String title;
  final String date;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _ChatHistoryTile({
    required this.title,
    required this.date,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? primary.withOpacity(isDark ? 0.15 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: primary.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? primary
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        height: 1.3,
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF475569) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Bubble Widgets ---

class _UserBubble extends StatelessWidget {
  final String text;
  final bool isDark;
  final String? time;
  const _UserBubble({required this.text, required this.isDark, this.time});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // "You" label
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                child: Text(
                  'YOU',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              // Bubble
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(3),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              // Timestamp
              if (time != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4, top: 4),
                  child: Text(
                    time!,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiBubble extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool streaming;
  final String? time;
  const _AiBubble({required this.text, required this.isDark, this.streaming = false, this.time});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar – app logo
        AppLogo(size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "BUBBLES AI" label
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 4),
                child: Text(
                  'BUBBLES AI',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              // Bubble – flat top-left corner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: MarkdownBody(
                  data: streaming ? '$text ◌' : text,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.manrope(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      height: 1.6,
                    ),
                    strong: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                    em: GoogleFonts.manrope(
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              // Timestamp
              if (time != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2, top: 4),
                  child: Text(
                    time!,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLogo(size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 4),
                child: Text(
                  'BUBBLES AI',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                      child: _BouncingDot(delay: i * 150),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFF64748B),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────
//  MIC TOGGLE BUTTON (top-bar)
// ────────────────────────────────────────────
class _MicToggleButton extends StatelessWidget {
  final _CVoiceMode voiceMode;
  final VoidCallback onTap;
  final bool isDark;

  const _MicToggleButton({
    required this.voiceMode,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isActive = voiceMode != _CVoiceMode.off;
    final isSpeaking = voiceMode == _CVoiceMode.speaking;

    return Tooltip(
      message: isActive
          ? (isSpeaking ? 'Tap to interrupt' : 'Stop hands-free mode')
          : 'Hands-free mode',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? primary.withOpacity(0.15)
                : Colors.transparent,
            border: Border.all(
              color: isActive ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            isSpeaking
                ? Icons.volume_up_rounded
                : (isActive ? Icons.mic_rounded : Icons.mic_none_rounded),
            size: 20,
            color: isActive
                ? primary
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────
//  VOICE STATUS BANNER (above input, when active)
// ────────────────────────────────────────────
class _VoiceStatusBanner extends StatelessWidget {
  final _CVoiceMode voiceMode;
  final String partial;
  final bool isDark;
  final Animation<double> micPulseAnim;
  final VoidCallback onStop;

  const _VoiceStatusBanner({
    required this.voiceMode,
    required this.partial,
    required this.isDark,
    required this.micPulseAnim,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final label = switch (voiceMode) {
      _CVoiceMode.listening   => partial.isEmpty ? 'Listening…' : partial,
      _CVoiceMode.processing  => 'Thinking…',
      _CVoiceMode.speaking    => 'Speaking — tap mic to interrupt',
      _CVoiceMode.off         => '',
    };
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Pulsing mic icon
          AnimatedBuilder(
            animation: micPulseAnim,
            builder: (_, child) => Transform.scale(
              scale: voiceMode == _CVoiceMode.listening ? micPulseAnim.value : 1.0,
              child: child,
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.15),
              ),
              child: Icon(
                voiceMode == _CVoiceMode.speaking
                    ? Icons.volume_up_rounded
                    : voiceMode == _CVoiceMode.processing
                        ? Icons.hourglass_top_rounded
                        : Icons.mic_rounded,
                size: 17,
                color: primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Status text
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: voiceMode == _CVoiceMode.listening && partial.isNotEmpty
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                fontStyle: voiceMode == _CVoiceMode.listening && partial.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
          // Stop button
          GestureDetector(
            onTap: onStop,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.12),
              ),
              child: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
