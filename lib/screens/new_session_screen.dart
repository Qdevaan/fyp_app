import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme/design_tokens.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/deepgram_service.dart';
import '../services/connection_service.dart';
import '../providers/session_provider.dart';
import '../widgets/chat_bubble.dart';

// ============================================================================
//  NEW SESSION SCREEN  (Live Wingman)
//  Business logic managed by SessionProvider; animations stay local.
// ============================================================================
class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Animations (local only)
  late AnimationController _pulseController;
  late AnimationController _blobController;

  SessionProvider get _session =>
      Provider.of<SessionProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    deepgram.addListener(_onDeepgramUpdate);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _blobController = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    deepgram.removeListener(_onDeepgramUpdate);
    deepgram.disconnect();
    _scrollController.dispose();
    _pulseController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  void _onDeepgramUpdate() {
    if (!mounted) return;
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    final api = Provider.of<ApiService>(context, listen: false);
    _session.onTranscriptReceived(deepgram, api);
    _scrollToBottom();
  }

  void _toggleSession() async {
    final deepgram = Provider.of<DeepgramService>(context, listen: false);
    final api = Provider.of<ApiService>(context, listen: false);
    final user = AuthService.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("User not found. Please login again.")),
        );
      }
      return;
    }

    if (_session.isSessionActive) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
          title: Text('End Session?',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          content: Text('Your conversation will be saved.',
              style: GoogleFonts.manrope()),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('End Session'),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Saving Session to Memory...")));
      }

      final success = await _session.endSession(api, deepgram);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Session Saved!"),
              backgroundColor: AppColors.success));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Failed to save."),
              backgroundColor: AppColors.error));
        }
      }
    } else {
      await _session.startSession(api, deepgram);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(0.0,
            duration: const AppDurations.dialog,
            curve: Curves.easeOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SessionProvider>(
      builder: (context, session, _) {
        return Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: Stack(
            children: [
              ..._buildBlobs(isDark, session.isSessionActive),
              SafeArea(
                child: session.isSessionActive
                    ? _buildActiveSession(isDark, session)
                    : _buildPreSession(isDark, session),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBlobs(bool isDark, bool isActive) {
    return [
      AnimatedBuilder(
        animation: _blobController,
        builder: (_, __) => Positioned(
          top: -100 + sin(_blobController.value * 2 * pi) * 30,
          right: -60 + cos(_blobController.value * 2 * pi) * 20,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha(isActive ? 20 : 31),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _blobController,
        builder: (_, __) => Positioned(
          bottom: -80 + cos(_blobController.value * 2 * pi) * 25,
          left: -50 + sin(_blobController.value * 2 * pi) * 15,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withAlpha(isActive ? 10 : 20),
            ),
          ),
        ),
      ),
    ];
  }

  // ========================
  // PRE-SESSION VIEW
  // ========================
  Widget _buildPreSession(bool isDark, SessionProvider session) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Live Wingman',
                    style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white
                            : AppColors.slate900),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                    session.swapSpeakers
                        ? Icons.swap_horiz_rounded
                        : Icons.compare_arrows_rounded,
                    color: isDark ? Colors.white70 : Colors.grey),
                tooltip: "Swap Speakers",
                onPressed: () {
                  session.toggleSwapSpeakers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Speakers Swapped!"),
                        duration: Duration(milliseconds: 500)),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<ConnectionService>(
            builder: (context, conn, _) {
              final isServerOnline = conn.isConnected;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CheckItem(
                      icon: Icons.mic,
                      label: 'Microphone',
                      status: 'Ready',
                      color: AppColors.success,
                      isDark: isDark),
                  const SizedBox(height: 12),
                  _CheckItem(
                    icon: Icons.wifi,
                    label: 'Server',
                    status: isServerOnline ? 'Connected' : 'Offline',
                    color: isServerOnline
                        ? AppColors.success
                        : AppColors.error,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _CheckItem(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                      status: 'Optional',
                      color: AppColors.warning,
                      isDark: isDark),
                  const SizedBox(height: 20),

                  // Server offline warning banner
                  if (!isServerOnline) ...[
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.error.withAlpha(102)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Server Offline',
                                    style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.error),
                                  ),
                                  Text(
                                    'Set your server URL in Connections to enable sessions.',
                                    style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        color: AppColors.error
                                            .withAlpha(204)),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, '/connections'),
                              child: Text('Fix',
                                  style: GoogleFonts.manrope(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else
                    const SizedBox(height: 20),

                  // START Button
                  GestureDetector(
                    onTap: isServerOnline
                        ? _toggleSession
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Server is offline. Connect to the server first.'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, child) {
                        final scale = isServerOnline
                            ? 1.0 +
                                sin(_pulseController.value * 2 * pi) *
                                    0.03
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: isServerOnline ? 1.0 : 0.4,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isServerOnline
                                      ? [
                                          Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          const Color(0xFF1E88E5)
                                        ]
                                      : [
                                          Colors.grey.shade500,
                                          Colors.grey.shade700
                                        ],
                                ),
                                boxShadow: isServerOnline
                                    ? [
                                        BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withAlpha(89),
                                            blurRadius: 30,
                                            spreadRadius: 5)
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      isServerOnline
                                          ? Icons.mic
                                          : Icons.cloud_off,
                                      color: Colors.white,
                                      size: 36),
                                  const SizedBox(height: 4),
                                  Text(
                                      isServerOnline
                                          ? 'START'
                                          : 'OFFLINE',
                                      style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 2)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isServerOnline
                        ? 'Tap to start listening'
                        : 'Connect to server to begin',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.slate400
                          : AppColors.slate500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ========================
  // ACTIVE SESSION VIEW
  // ========================
  Widget _buildActiveSession(bool isDark, SessionProvider session) {
    final logs = session.sessionLogs;
    return Column(
      children: [
        // Header with LIVE badge
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back,
                    color: Colors.transparent),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(51),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.error.withAlpha(102)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text('LIVE',
                            style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                    session.swapSpeakers
                        ? Icons.swap_horiz_rounded
                        : Icons.compare_arrows_rounded,
                    color: isDark ? Colors.white70 : Colors.grey),
                onPressed: () {
                  session.toggleSwapSpeakers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Speakers Swapped!"),
                        duration: Duration(milliseconds: 500)),
                  );
                },
              ),
            ],
          ),
        ),

        // Chat transcript
        Expanded(
          child: logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.graphic_eq,
                          size: 52,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(102)),
                      const SizedBox(height: 10),
                      Text("Listening...",
                          style: GoogleFonts.manrope(
                              color: isDark
                                  ? AppColors.slate400
                                  : AppColors.slate500,
                              fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final msg = logs[logs.length - 1 - index];
                    bool isMe = msg['speaker'] == "User";
                    return ChatBubble(
                        text: msg['text'],
                        isUser: isMe,
                        speakerLabel: isMe ? null : "Other");
                  },
                ),
        ),

        // HUD Panel
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withAlpha(242)
                : Colors.white.withAlpha(242),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(38),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ],
          ),
          child: Column(
            children: [
              // Suggestion box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha(isDark ? 26 : 13),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha(38)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .primary),
                        const SizedBox(width: 6),
                        Text(
                          'AI INSIGHT',
                          style: GoogleFonts.manrope(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(context).size.height *
                                  0.25),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildAdviceContent(isDark, session),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Controls
              if (session.isSaving)
                Column(
                  children: [
                    CircularProgressIndicator(
                        color:
                            Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 10),
                    Text("Saving Memories...",
                        style: GoogleFonts.manrope(
                            color: AppColors.textMuted)),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.surfaceDarkHighlight
                            : Colors.grey.shade200,
                      ),
                      child: Icon(Icons.mic_off,
                          color:
                              isDark ? Colors.white54 : Colors.grey,
                          size: 22),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _toggleSession,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.error,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.error.withAlpha(102),
                                blurRadius: 16,
                                spreadRadius: 2)
                          ],
                        ),
                        child: const Icon(Icons.stop_rounded,
                            color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.surfaceDarkHighlight
                            : Colors.grey.shade200,
                      ),
                      child: Icon(Icons.settings,
                          color:
                              isDark ? Colors.white54 : Colors.grey,
                          size: 22),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceContent(bool isDark, SessionProvider session) {
    if (session.realtimeLost) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.error.withAlpha(77)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Live updates stopped. Tap Retry to fetch response via HTTP.',
                style: GoogleFonts.manrope(
                    fontSize: 12, color: AppColors.error, height: 1.4),
              ),
            ),
            TextButton(
              onPressed: () {
                final api =
                    Provider.of<ApiService>(context, listen: false);
                session.retryWingman(api);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
              ),
              child: Text('Retry',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      );
    }

    final suggestion = session.currentSuggestion;

    if (suggestion.contains("**Context-Based Advice:**")) {
      List<Widget> sections = [];

      final adviceMatch = RegExp(
              r"\*\*Context-Based Advice:\*\*\s*(.*?)(?=(?:\d+\.?\s*)?\*\*Clarification Request:|(?:\d+\.?\s*)?\*\*Apology & Confirmation.*?:?\*\*|$)",
              dotAll: true)
          .firstMatch(suggestion);
      final clarificationMatch = RegExp(
              r"\*\*Clarification Request:\*\*\s*(.*?)(?=(?:\d+\.?\s*)?\*\*Apology & Confirmation.*?:?\*\*|$)",
              dotAll: true)
          .firstMatch(suggestion);
      final apologyMatch =
          RegExp(r"\*\*Apology & Confirmation.*?:?\*\*\s*(.*)", dotAll: true)
              .firstMatch(suggestion);

      if (adviceMatch != null &&
          adviceMatch.group(1)!.trim().isNotEmpty) {
        sections.add(_buildSectionCard(
            "ADVICE",
            adviceMatch.group(1)!.trim(),
            AppColors.success.withAlpha(38),
            AppColors.success,
            Icons.lightbulb_outline,
            isDark));
      }
      if (clarificationMatch != null &&
          clarificationMatch.group(1)!.trim().isNotEmpty) {
        sections.add(_buildSectionCard(
            "CLARIFICATION",
            clarificationMatch.group(1)!.trim(),
            AppColors.warning.withAlpha(38),
            AppColors.warning,
            Icons.help_outline,
            isDark));
      }
      if (apologyMatch != null &&
          apologyMatch.group(1)!.trim().isNotEmpty) {
        sections.add(_buildSectionCard(
            "CONFIRMATION",
            apologyMatch.group(1)!.trim(),
            Theme.of(context)
                .colorScheme
                .primary
                .withAlpha(38),
            Theme.of(context).colorScheme.primary,
            Icons.info_outline,
            isDark));
      }
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections);
    }

    return Text(
      suggestion,
      style: GoogleFonts.manrope(
        color: isDark
            ? AppColors.slate200
            : AppColors.slate900,
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, Color bg,
      Color fg, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(title,
                  style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: fg,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Text(content,
              style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.slate200
                      : AppColors.slate700,
                  height: 1.3)),
        ],
      ),
    );
  }
}

// --- Sub Widgets ---

class _CheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color color;
  final bool isDark;

  const _CheckItem({
    required this.icon,
    required this.label,
    required this.status,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(13)
                : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.slate900,
              ),
            ),
          ),
          Text(
            status,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
