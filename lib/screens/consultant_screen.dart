import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/design_tokens.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ConsultantScreen extends StatefulWidget {
  const ConsultantScreen({super.key});

  @override
  State<ConsultantScreen> createState() => _ConsultantScreenState();
}

class _ConsultantScreenState extends State<ConsultantScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  bool _loading = false;
  bool _initializing = false;
  bool _historyLoaded = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);
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
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (maxScroll - currentScroll > 200) {
        if (!_showScrollToBottom) setState(() => _showScrollToBottom = true);
      } else {
        if (_showScrollToBottom) setState(() => _showScrollToBottom = false);
      }
    }
  }

  Future<void> _loadChatHistory() async {
    if (_historyLoaded) return;
    setState(() => _initializing = true);

    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() => _initializing = false);
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('consultant_logs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          List<Map<String, String>> history = [];
          for (var log in response) {
            if (log['question'] != null) history.add({"role": "user", "text": log['question']});
            if (log['answer'] != null) history.add({"role": "ai", "text": log['answer']});
          }

          if (history.isNotEmpty) {
            _messages.insertAll(0, history);
            if (_messages.isEmpty) {
              _messages.add({"role": "ai", "text": "Hello! I have access to your past conversation history. Ask me anything about what you've discussed previously."});
            }
          } else if (_messages.isEmpty) {
            _messages.add({"role": "ai", "text": "Hello! I have access to your past conversation history. Ask me anything about what you've discussed previously."});
          }

          _initializing = false;
          _historyLoaded = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _saveInteraction(String question, String answer) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('consultant_logs').insert({'user_id': user.id, 'question': question, 'answer': answer});
    } catch (e) {
      debugPrint("Error saving interaction: $e");
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = AuthService.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in."), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    setState(() {
      _messages.add({"role": "user", "text": text});
      _loading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final answer = await api.askConsultant(user.id, text);
      if (mounted) {
        setState(() => _messages.add({"role": "ai", "text": answer}));
        _scrollToBottom();
        await _saveInteraction(text, answer);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _messages.add({"role": "ai", "text": "Error connecting to consultant: $e"}));
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool showCenterLoadButton = _messages.isEmpty && !_historyLoaded && !_initializing;
    final bool showInputLoadButton = _messages.isNotEmpty && !_historyLoaded && !_initializing;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP BAR ---
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark.withOpacity(0.95) : AppColors.backgroundLight.withOpacity(0.95),
                border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Consultant AI',
                              style: GoogleFonts.manrope(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.more_horiz, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  // Context chip
                  if (_historyLoaded && _messages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Using past sessions',
                              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- CHAT AREA ---
            Expanded(
              child: Stack(
                children: [
                  _initializing
                      ? const Center(child: CircularProgressIndicator())
                      : _messages.isEmpty && !_historyLoaded
                          ? const SizedBox.shrink()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length + (_loading ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Typing indicator
                                if (_loading && index == _messages.length) {
                                  return _TypingIndicator(isDark: isDark);
                                }

                                final msg = _messages[index];
                                final isUser = msg['role'] == "user";

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: isUser
                                      ? _UserBubble(text: msg['text']!, isDark: isDark)
                                      : _AiBubble(text: msg['text']!, isDark: isDark),
                                );
                              },
                            ),

                  // Center load button
                  if (showCenterLoadButton)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _loadChatHistory,
                        icon: const Icon(Icons.history),
                        label: const Text("Load Previous Chat"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        ),
                      ),
                    ),

                  // Scroll to bottom
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
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- INPUT AREA ---
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark.withOpacity(0.95) : AppColors.backgroundLight.withOpacity(0.95),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showInputLoadButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 4),
                      child: GestureDetector(
                        onTap: _loadChatHistory,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                          ),
                          child: Icon(Icons.history, color: isDark ? Colors.white54 : Colors.grey.shade600, size: 22),
                        ),
                      ),
                    ),
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
                                hintStyle: GoogleFonts.manrope(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 4, bottom: 4),
                            child: IconButton(
                              icon: Icon(Icons.mic, color: AppColors.primary, size: 22),
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
                      onTap: _loading ? null : _sendMessage,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _loading ? (isDark ? AppColors.surfaceDark : Colors.grey.shade300) : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: _loading
                              ? null
                              : [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)],
                        ),
                        child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
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
  const _AiBubble({required this.text, required this.isDark});

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
            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF1E88E5)]),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)],
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
              data: text,
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
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.5), const Color(0xFF1E88E5).withOpacity(0.5)]),
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