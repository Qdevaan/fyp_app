import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../providers/consultant_provider.dart';
import '../services/api_service.dart';
import 'session_history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class ConsultantScreen extends StatefulWidget {
  const ConsultantScreen({super.key});

  @override
  State<ConsultantScreen> createState() => _ConsultantScreenState();
}

class _ConsultantScreenState extends State<ConsultantScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(ConsultantProvider provider) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _sending = true);
    try {
      await provider.sendMessage(text, context.read<ApiService>());
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsultantProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: BubblesColors.bgDark,
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              BubblesColors.primary.withOpacity(0.08),
              BubblesColors.bgDark,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(child: _buildChat(provider)),
            _buildInputBar(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: BubblesColors.glassHeaderDark,
          border: const Border(bottom: BorderSide(color: Color(0x0AFFFFFF))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: BubblesColors.textPrimaryDark),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bubbles AI', style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: BubblesColors.textPrimaryDark,
                  )),
                  Row(
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: BubblesColors.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text('CONSULTANT ONLINE',
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: BubblesColors.primary, letterSpacing: 0.8,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: BubblesColors.textSecondaryDark),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: BubblesColors.textSecondaryDark),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat(ConsultantProvider provider) {
    final messages = provider.messages;

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BubblesColors.primary.withOpacity(0.1),
                  border: Border.all(color: BubblesColors.primary.withOpacity(0.3)),
                ),
                child: const Icon(Icons.psychology, color: BubblesColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text("Hello! I'm your AI Consultant.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: BubblesColors.textPrimaryDark,
                  )),
              const SizedBox(height: 8),
              Text('Ask me anything to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: BubblesColors.textSecondaryDark)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8, runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _SuggestionChip('Analyze my communication', () {
                    _msgCtrl.text = 'Analyze my communication style';
                    _sendMessage(provider);
                  }),
                  _SuggestionChip('Help me with a reply', () {
                    _msgCtrl.text = 'Help me craft a professional reply';
                    _sendMessage(provider);
                  }),
                  _SuggestionChip('Career advice', () {
                    _msgCtrl.text = 'Give me career development advice';
                    _sendMessage(provider);
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: BubblesColors.glassDark,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: BubblesColors.glassBorderDark),
                ),
                child: Text('Today', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: BubblesColors.textMutedDark, letterSpacing: 1.0,
                )),
              ),
            ),
          );
        }
        final msg = messages[i - 1];
        final isUser = msg['role'] == 'user';
        return _ChatBubble(text: msg['content'] ?? '', isUser: isUser);
      },
    );
  }

  Widget _buildInputBar(ConsultantProvider provider) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: BubblesColors.glassDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BubblesColors.glassBorderDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: BubblesColors.textMutedDark, size: 22),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: GoogleFonts.manrope(
                        fontSize: 14, color: BubblesColors.textPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Type your query...',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 14, color: BubblesColors.textMutedDark),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(provider),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none, color: BubblesColors.textMutedDark, size: 22),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => _sendMessage(provider),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: BubblesColors.primary,
                          boxShadow: [
                            BoxShadow(color: BubblesColors.primary.withOpacity(0.3), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.send, color: BubblesColors.bgDark, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 13, color: BubblesColors.textMutedDark),
                      const SizedBox(width: 4),
                      Text('Recent Analysis', style: TextStyle(
                        fontSize: 11, color: BubblesColors.textMutedDark)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 13, color: BubblesColors.textMutedDark),
                      const SizedBox(width: 4),
                      Text('Smart Suggestions', style: TextStyle(
                        fontSize: 11, color: BubblesColors.textMutedDark)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BubblesColors.primary.withOpacity(0.15),
                border: Border.all(color: BubblesColors.primary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.bubble_chart, color: BubblesColors.primary, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? BubblesColors.glassPrimary : BubblesColors.glassDark,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser ? BubblesColors.glassPrimaryBorder : BubblesColors.glassBorderDark,
                    ),
                  ),
                  child: Text(text,
                      style: GoogleFonts.manrope(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: BubblesColors.textPrimaryDark, height: 1.5,
                      )),
                ),
                const SizedBox(height: 3),
                Text('Now', style: TextStyle(
                  fontSize: 10, color: BubblesColors.textMutedDark)),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BubblesColors.glassDark,
                border: Border.all(color: BubblesColors.glassBorderDark),
              ),
              child: const Icon(Icons.person, color: BubblesColors.textSecondaryDark, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: BubblesColors.glassPrimary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BubblesColors.glassPrimaryBorder),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: BubblesColors.primary)),
      ),
    );
  }
}
