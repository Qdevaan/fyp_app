import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen>
    with TickerProviderStateMixin {
  bool _sessionActive = false;
  bool _micMuted = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _waveCtrl;
  Timer? _timer;
  int _elapsed = 0;

  final _transcript = <_TranscriptLine>[
    const _TranscriptLine(speaker: 'User', text: 'I need help approaching someone at this conference.', time: '0:14'),
    const _TranscriptLine(speaker: 'AI', text: 'Perfect timing! I\'ll analyze the context and suggest openers. What\'s the occasion?', time: '0:17'),
    const _TranscriptLine(speaker: 'User', text: 'Tech networking event. She\'s the one by the coffee stand.', time: '0:22'),
  ];

  final _aiSuggestions = [
    'Try: "That coffee looks amazing — I had the worst morning. What brought you to this event?"',
    'Tip: Make eye contact and smile before speaking to seem approachable.',
    'Follow-up: Ask about their current project or favorite talk from today.',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleSession() {
    setState(() => _sessionActive = !_sessionActive);
    if (_sessionActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed++);
      });
    } else {
      _timer?.cancel();
      _elapsed = 0;
    }
  }

  String get _timeStr {
    final m = _elapsed ~/ 60;
    final s = _elapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF101e22), Color(0xFF0d2a33)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _sessionActive ? _buildActiveSession() : _buildPreSession(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: const BoxDecoration(
          color: BubblesColors.glassHeaderDark,
          border: Border(bottom: BorderSide(color: Color(0x1A13BDEC))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: BubblesColors.textPrimaryDark),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Wingman', style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: BubblesColors.textPrimaryDark,
                  )),
                  if (_sessionActive)
                    Text(_timeStr, style: GoogleFonts.manrope(
                      fontSize: 12, color: BubblesColors.primary,
                    )),
                ],
              ),
            ),
            if (_sessionActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Live', style: GoogleFonts.manrope(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreSession() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _ModeCard(
            icon: Icons.people_outline,
            label: 'Social Wingman',
            description: 'Real-time coaching for social interactions',
            color: BubblesColors.primary,
            selected: true,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.work_outline,
            label: 'Business Coach',
            description: 'Professional meeting & negotiation support',
            color: const Color(0xFF10B981),
            selected: false,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.favorite_outline,
            label: 'Relationship Guide',
            description: 'Dating and romantic conversation assistance',
            color: const Color(0xFFF43F5E),
            selected: false,
          ),
          const SizedBox(height: 32),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
            child: GestureDetector(
              onTap: _toggleSession,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF13bdec), Color(0xFF0ea5d0)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BubblesColors.primary.withOpacity(0.45),
                      blurRadius: 32, spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Tap to Start Session', style: GoogleFonts.manrope(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: BubblesColors.textSecondaryDark,
          )),
          const SizedBox(height: 8),
          Text('Bubbles will listen and provide real-time coaching',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: BubblesColors.textMutedDark),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession() {
    return Column(
      children: [
        _buildStatusBar(),
        Expanded(
          flex: 3,
          child: _buildTranscript(),
        ),
        _buildAIFeedback(),
        _buildControls(),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: BubblesColors.glassPrimary,
        border: Border.all(color: BubblesColors.glassPrimaryBorder),
      ),
      child: Row(
        children: [
          _AnimWave(controller: _waveCtrl),
          const SizedBox(width: 12),
          Expanded(child: Text('Listening...', style: GoogleFonts.manrope(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: BubblesColors.primary,
          ))),
          Text(_timeStr, style: GoogleFonts.manrope(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: BubblesColors.primary,
          )),
        ],
      ),
    );
  }

  Widget _buildTranscript() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassBox(
        borderRadius: 16, padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('LIVE TRANSCRIPT', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 1.2, color: BubblesColors.textMutedDark,
            )),
          ),
          const Divider(color: BubblesColors.glassBorderDark, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _transcript.length,
              itemBuilder: (_, i) {
                final t = _transcript[i];
                final isUser = t.speaker == 'User';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUser
                              ? BubblesColors.primary.withOpacity(0.2)
                              : const Color(0xFF10B981).withOpacity(0.2),
                        ),
                        child: Icon(
                          isUser ? Icons.person_outline : Icons.android,
                          size: 14,
                          color: isUser ? BubblesColors.primary : const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(t.speaker, style: GoogleFonts.manrope(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: isUser ? BubblesColors.primary : const Color(0xFF10B981),
                                )),
                                const Spacer(),
                                Text(t.time, style: TextStyle(
                                  fontSize: 9, color: BubblesColors.textMutedDark,
                                )),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(t.text, style: TextStyle(
                              fontSize: 12, color: BubblesColors.textPrimaryDark,
                              height: 1.45,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildAIFeedback() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassPrimaryBox(
        borderRadius: 16, padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: BubblesColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('AI Coaching', style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: BubblesColors.primary, letterSpacing: 0.5,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Text(_aiSuggestions[0], style: TextStyle(
            fontSize: 12, color: BubblesColors.textPrimaryDark, height: 1.5,
          )),
        ],
      ),
    ),
    );
  }

  Widget _buildControls() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlBtn(
              icon: _micMuted ? Icons.mic_off : Icons.mic,
              label: _micMuted ? 'Unmute' : 'Mute',
              onTap: () => setState(() => _micMuted = !_micMuted),
              active: !_micMuted,
            ),
            GestureDetector(
              onTap: _toggleSession,
              child: Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF43F5E).withOpacity(0.15),
                  border: Border.all(color: const Color(0xFFF43F5E).withOpacity(0.5), width: 2),
                ),
                child: const Icon(Icons.stop_rounded, color: Color(0xFFF43F5E), size: 32),
              ),
            ),
            _ControlBtn(
              icon: Icons.note_add_outlined,
              label: 'Note',
              onTap: () {},
              active: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool selected;
  const _ModeCard({
    required this.icon, required this.label, required this.description,
    required this.color, required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: 14,
      bgColor: selected ? color.withOpacity(0.08) : BubblesColors.glassDark,
      borderColor: selected ? color.withOpacity(0.35) : BubblesColors.glassBorderDark,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: BubblesColors.textPrimaryDark,
                )),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(
                  fontSize: 11, color: BubblesColors.textSecondaryDark,
                )),
              ],
            ),
          ),
          if (selected)
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: color,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _ControlBtn({required this.icon, required this.label, required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? BubblesColors.glassPrimary : BubblesColors.glassDark,
              border: Border.all(
                color: active ? BubblesColors.glassPrimaryBorder : BubblesColors.glassBorderDark,
              ),
            ),
            child: Icon(icon, color: active ? BubblesColors.primary : BubblesColors.textSecondaryDark, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            fontSize: 10, color: BubblesColors.textSecondaryDark, fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

class _AnimWave extends StatelessWidget {
  final AnimationController controller;
  const _AnimWave({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final h = 4.0 + 12.0 * ((1 + (t - i * 0.2) % 1.0) % 1.0);
            return Container(
              width: 3, height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: BubblesColors.primary,
              ),
            );
          }),
        );
      },
    );
  }
}

class _TranscriptLine {
  final String speaker;
  final String text;
  final String time;
  const _TranscriptLine({required this.speaker, required this.text, required this.time});
}
