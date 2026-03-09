import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

/// Fullscreen voice overlay shown when the wake word is detected.
/// Covers the entire app with a frosted scrim.
class VoiceOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final String state; // 'listening' | 'thinking' | 'speaking'
  final String? transcript;
  final String? response;

  const VoiceOverlay({
    super.key,
    required this.onDismiss,
    this.state = 'listening',
    this.transcript,
    this.response,
  });

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay>
    with TickerProviderStateMixin {
  late AnimationController _orbCtrl;
  late AnimationController _rippleCtrl;
  late Animation<double> _orbAnim;
  late Animation<double> _rippleAnim;

  final _stateLabels = {
    'listening': 'Listening…',
    'thinking': 'Processing…',
    'speaking': 'Speaking…',
  };

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _rippleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _orbAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut),
    );
    _rippleAnim = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Frosted scrim
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(color: const Color(0xCC101e22)),
        ),
        // Content
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildOrb()),
              _buildPanel(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
            onPressed: widget.onDismiss,
          ),
        ],
      ),
    );
  }

  Widget _buildOrb() {
    final Color orbColor = (() {
      switch (widget.state) {
        case 'thinking': return const Color(0xFFA855F7);
        case 'speaking': return const Color(0xFF10B981);
        default: return BubblesColors.primary;
      }
    })();

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_orbCtrl, _rippleCtrl]),
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripple
              Transform.scale(
                scale: 1.0 + _rippleAnim.value,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: orbColor.withOpacity((1 - _rippleAnim.value / 1.5).clamp(0, 1) * 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Inner pulsing orb
              Transform.scale(
                scale: _orbAnim.value,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      orbColor.withOpacity(0.9),
                      orbColor.withOpacity(0.3),
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: orbColor.withOpacity(0.5),
                        blurRadius: 40, spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.state == 'speaking'
                        ? Icons.volume_up_rounded
                        : widget.state == 'thinking'
                            ? Icons.auto_awesome
                            : Icons.mic,
                    color: Colors.white.withOpacity(0.9),
                    size: 36,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              _stateLabels[widget.state] ?? 'Ready',
              style: GoogleFonts.manrope(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          if (widget.transcript != null && widget.transcript!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOU', style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    letterSpacing: 1.2, color: BubblesColors.primary,
                  )),
                  const SizedBox(height: 4),
                  Text(widget.transcript!, style: const TextStyle(
                    fontSize: 13, color: Colors.white70, height: 1.45,
                  )),
                ],
              ),
            ),
          ],
          if (widget.response != null && widget.response!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: BubblesColors.primary.withOpacity(0.08),
                border: Border.all(color: BubblesColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BUBBLES', style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    letterSpacing: 1.2, color: BubblesColors.primary,
                  )),
                  const SizedBox(height: 4),
                  Text(widget.response!, style: const TextStyle(
                    fontSize: 13, color: Colors.white, height: 1.45,
                  )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: widget.onDismiss,
              child: Text('Dismiss', style: TextStyle(
                fontSize: 12, color: Colors.white.withOpacity(0.5),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
