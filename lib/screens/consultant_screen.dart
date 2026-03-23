import 'dart:ui';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../providers/consultant_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/consultant/voice_mode.dart';
import '../widgets/consultant/consultant_widgets.dart';
import '../widgets/consultant/welcome_messages.dart';
import '../widgets/glass_morphism.dart';

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

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = View.of(context).viewInsets.bottom;
    if (bottomInset > 0.0) _scrollToBottom();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final diff =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    final show = diff > 200;
    if (show != _showScrollToBottom) setState(() => _showScrollToBottom = show);
  }

  // -- New / clear chat (delegates to provider) --
  void _newChat() {
    Navigator.pop(context); // close drawer
    _chat.newChat(_getWelcomeMessage());
  }

  // -- Load sidebar chat list (delegates to provider) --
  Future<void> _loadPastChats() async {
    await _chat.loadPastChats();
  }

  // -- Load messages for a selected past chat (delegates to provider) --
  Future<void> _loadChatById(String sessionId) async {
    Navigator.pop(context); // close drawer immediately
    await _chat.loadChatById(sessionId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // -- Not-connected dialog --
  void _showNotConnectedDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => GlassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Not Connected',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'The Consultant AI requires a server connection. Please connect first in Settings.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/connections');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(31),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  child: Text(
                    'Connect',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -- Send message (delegates streaming to provider) --
  void _sendMessage() {
    final text = _controller.text.trim();
    final chat = _chat;
    if (text.isEmpty || chat.loading || chat.loadingChat) return;

    final conn = Provider.of<ConnectionService>(context, listen: false);
    if (!conn.isConnected) {
      _showNotConnectedDialog();
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not logged in."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _controller.clear();
    final api = Provider.of<ApiService>(context, listen: false);
    chat.sendMessage(text, api);
    _scrollToBottom();
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

  void _interruptAndListen() {
    if (_voiceMode == CVoiceMode.speaking) {
      _ttsPlayer.stop();
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
        _startSTT();
        return;
      }
      _sendVoiceMessage(text);
    }
  }

  Future<void> _sendVoiceMessage(String text) async {
    if (!mounted || !_voiceModeActive) return;

    final conn = Provider.of<ConnectionService>(context, listen: false);
    if (!conn.isConnected) {
      _stopVoiceMode();
      _showNotConnectedDialog();
      return;
    }

    setState(() {
      _voicePartial = '';
      _voiceMode = CVoiceMode.processing;
    });

    final api = Provider.of<ApiService>(context, listen: false);
    await _chat.sendMessage(
      text,
      api,
      onFirstToken: () {
        if (mounted && _voiceModeActive) {
          _setVoiceMode(CVoiceMode.speaking);
        }
      },
      onComplete: (fullResponse) async {
        if (_voiceModeActive && fullResponse.isNotEmpty) {
          await _speakText(fullResponse);
        }
      },
    );
    _scrollToBottom();
  }

  Future<void> _speakText(String text) async {
    if (!_voiceModeActive || !mounted) return;

    final plain = text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
        .replaceAll(RegExp(r'#+\s'), '')
        .replaceAll(RegExp(r'`(.+?)`'), r'$1')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();

    final apiKey = dotenv.env['DEEPGRAM_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      if (_voiceModeActive && mounted) {
        _setVoiceMode(CVoiceMode.listening);
        _startSTT();
      }
      return;
    }

    _setVoiceMode(CVoiceMode.speaking);

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://api.deepgram.com/v1/speak?model=aura-orpheus-en',
            ),
            headers: {
              'Authorization': 'Token $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'text': plain}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/consultant_tts.mp3');
        await file.writeAsBytes(response.bodyBytes);
        await _ttsPlayer.play(DeviceFileSource(file.path));
      } else {
        debugPrint('TTS error: ${response.statusCode}');
        if (_voiceModeActive && mounted) {
          _setVoiceMode(CVoiceMode.listening);
          _startSTT();
        }
      }
    } catch (e) {
      debugPrint('TTS network error: $e');
      if (_voiceModeActive && mounted) {
        _setVoiceMode(CVoiceMode.listening);
        _startSTT();
      }
    }
  }

  // -- Helpers --
  String _chatTitle(Map<String, dynamic> chat) {
    final q = chat['title'] as String? ?? 'Chat';
    return q.length > 48 ? '${q.substring(0, 48)}\u2026' : q;
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

  // -- Drawer (reads from provider) --
  Widget _buildDrawer(bool isDark, ConsultantProvider chat) {
    final primary = Theme.of(context).colorScheme.primary;
    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
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
                        color: isDark ? Colors.white : AppColors.slate900,
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
            Divider(
              color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
              height: 1,
            ),
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withAlpha(31),
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
            if (chat.drawerLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (chat.drawerLoaded && chat.pastChats.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No past conversations yet.\nStart chatting to build history.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: isDark ? AppColors.slate600 : Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              )
            else if (chat.drawerLoaded)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  itemCount: chat.pastChats.length,
                  itemBuilder: (_, i) {
                    final c = chat.pastChats[i];
                    final sid = c['session_id'] as String;
                    final isActive = sid == chat.currentSessionId;
                    return ChatHistoryTile(
                      title: _chatTitle(c),
                      date: _formatDate(c['created_at'] as String?),
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

    return Consumer<ConsultantProvider>(
      builder: (context, chat, _) {
        return MeshGradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            drawer: _buildDrawer(isDark, chat),
            onDrawerChanged: (isOpen) {
              if (isOpen && !chat.drawerLoaded && !chat.drawerLoading) {
                _loadPastChats();
              }
            },
            body: SafeArea(
              child: Column(
                children: [
                  // -- TOP BAR --
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? AppColors.glassBorder
                              : AppColors.slate200,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Semantics(
                            label: 'Open conversations menu',
                            child: IconButton(
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              icon: Icon(
                                Icons.menu_rounded,
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Consultant',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.slate900,
                              ),
                            ),
                          ),
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

                  // -- CONNECTION BANNER --
                  Consumer<ConnectionService>(
                    builder: (_, conn, __) => conn.isConnected
                        ? const SizedBox.shrink()
                        : Semantics(
                            label: 'Not connected to server. Tap to connect.',
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/connections'),
                              child: Container(
                                width: double.infinity,
                                color: AppColors.error.withAlpha(31),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.wifi_off_rounded,
                                      color: AppColors.error,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Not connected to server - tap to connect',
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.error,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),

                  // -- CHAT AREA --
                  Expanded(
                    child: Stack(
                      children: [
                        chat.loadingChat
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  24,
                                  16,
                                  16,
                                ),
                                itemCount:
                                    chat.messages.length +
                                    (chat.loading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (chat.loading &&
                                      index == chat.messages.length) {
                                    return TypingIndicator(isDark: isDark);
                                  }
                                  final msg = chat.messages[index];
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
                                            streaming:
                                                msg['streaming'] == 'true',
                                            time: msg['time'],
                                          ),
                                  );
                                },
                              ),
                        if (_showScrollToBottom)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Semantics(
                              label: 'Scroll to bottom',
                              child: GestureDetector(
                                onTap: _scrollToBottom,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withAlpha(77),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // -- VOICE STATUS BANNER --
                  if (_voiceMode != CVoiceMode.off)
                    VoiceStatusBanner(
                      voiceMode: _voiceMode,
                      partial: _voicePartial,
                      isDark: isDark,
                      micPulseAnim: _micPulseAnim,
                      onStop: _stopVoiceMode,
                    ),

                  // -- INPUT AREA --
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.backgroundDark.withAlpha(200)
                              : Colors.white.withAlpha(220),
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? AppColors.glassBorder
                                  : Colors.white.withAlpha(255),
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.0),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                                  child: TextField(
                                    controller: _controller,
                                    maxLines: 4,
                                    minLines: 1,
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.slate900,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDark
                                          ? AppColors.glassInput
                                          : Colors.white.withAlpha(220),
                                      hintText:
                                          'Ask about your conversations...',
                                      hintStyle: GoogleFonts.manrope(
                                        color: isDark
                                            ? AppColors.textMuted
                                            : AppColors.textSecondary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.glassBorder
                                              : AppColors.slate300,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.glassBorder
                                              : AppColors.slate300,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 14,
                                          ),
                                    ),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Semantics(
                              label: 'Send message',
                              child: GestureDetector(
                                onTap: (chat.loading || chat.loadingChat)
                                    ? null
                                    : _sendMessage,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: (chat.loading || chat.loadingChat)
                                        ? (isDark
                                              ? AppColors.glassWhite
                                              : Colors.grey.shade300)
                                        : Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow:
                                        (chat.loading || chat.loadingChat)
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(77),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
