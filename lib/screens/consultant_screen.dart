import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/design_tokens.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// ────────────────────────────────────────────
//  CONSULTANT SCREEN  (ChatGPT-style multi-chat)
// ────────────────────────────────────────────
class ConsultantScreen extends StatefulWidget {
  const ConsultantScreen({super.key});

  @override
  State<ConsultantScreen> createState() => _ConsultantScreenState();
}

class _ConsultantScreenState extends State<ConsultantScreen> with WidgetsBindingObserver {
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

  static const _welcomeMsg =
      "Hello! I'm your Consultant AI.\n\nI have access to your **knowledge graph**, **session memories**, and **past summaries**. Ask me anything about your conversations, relationships, or decisions.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);
    _messages.add({"role": "ai", "text": _welcomeMsg});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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

  // ── Send message (SSE streaming) ───────────
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading || _loadingChat) return;

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not logged in."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _messages.add({"role": "user", "text": text});
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

      await for (final token in stream) {
        if (!mounted) break;
        buf.write(token);
        if (firstToken) {
          setState(() {
            _loading = false;
            _messages.add({"role": "ai", "text": buf.toString(), "streaming": "true"});
          });
          firstToken = false;
        } else {
          setState(() => _messages.last = {"role": "ai", "text": buf.toString(), "streaming": "true"});
        }
        _scrollToBottom();
      }

      if (mounted) {
        setState(() {
          if (_messages.isNotEmpty && _messages.last['streaming'] == 'true') {
            _messages.last = {"role": "ai", "text": buf.toString()};
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (firstToken) {
            _messages.add({"role": "ai", "text": "Error connecting to consultant: $e"});
          } else {
            _messages.last = {"role": "ai", "text": buf.isEmpty ? "Error: $e" : buf.toString()};
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
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [primary, const Color(0xFF1E88E5)]),
                    ),
                    child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
                  ),
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
                color: isDark ? AppColors.backgroundDark.withOpacity(0.95) : AppColors.backgroundLight.withOpacity(0.95),
                border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    // Back
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
                    ),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _currentSessionId == null ? 'New Chat' : 'Consultant AI',
                            style: GoogleFonts.manrope(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          if (_currentSessionId != null)
                            Text(
                              'Session active',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Chat history
                    IconButton(
                      tooltip: 'Chat history',
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: Icon(Icons.history, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
                    ),
                    // New chat
                    IconButton(
                      tooltip: 'New chat',
                      onPressed: _loading ? null : _newChat,
                      icon: Icon(Icons.edit_square,
                          color: _loading
                              ? (isDark ? const Color(0xFF334155) : Colors.grey.shade300)
                              : Theme.of(context).colorScheme.primary,
                          size: 22),
                    ),
                  ],
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
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_loading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_loading && index == _messages.length) {
                              return _TypingIndicator(isDark: isDark);
                            }
                            final msg = _messages[index];
                            final isUser = msg['role'] == "user";
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: isUser
                                  ? _UserBubble(text: msg['text']!, isDark: isDark)
                                  : _AiBubble(
                                      text: msg['text']!,
                                      isDark: isDark,
                                      streaming: msg['streaming'] == 'true',
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

            // ── INPUT AREA ────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark.withOpacity(0.95) : AppColors.backgroundLight.withOpacity(0.95),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bubbleDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLines: 4,
                              minLines: 1,
                              style: GoogleFonts.manrope(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                              decoration: InputDecoration(
                                hintText: 'Ask anything...',
                                hintStyle: GoogleFonts.manrope(
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 4, bottom: 4),
                            child: IconButton(
                              icon: Icon(Icons.mic, color: Theme.of(context).colorScheme.primary, size: 22),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: (_loading || _loadingChat) ? null : _sendMessage,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: (_loading || _loadingChat)
                              ? (isDark ? AppColors.surfaceDark : Colors.grey.shade300)
                              : Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: (_loading || _loadingChat)
                              ? null
                              : [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                      ),
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
  const _UserBubble({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool streaming;
  const _AiBubble({required this.text, required this.isDark, this.streaming = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AI Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, const Color(0xFF1E88E5)]),
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8)],
          ),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bubbleDark : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: MarkdownBody(
              data: streaming ? '$text ▌' : text,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.manrope(
                  fontSize: 15,
                  color: isDark ? const Color(0xFFE2E8F0) : Colors.black87,
                  height: 1.5,
                ),
                strong: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
                em: GoogleFonts.manrope(fontStyle: FontStyle.italic, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
              ),
            ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.5), const Color(0xFF1E88E5).withOpacity(0.5)]),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bubbleDark.withOpacity(0.5) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
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
