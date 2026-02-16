import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/voice_assistant_service.dart';

/// A global floating voice assistant overlay.
/// Shows a mic FAB and expands into a glassmorphic panel with animations.
class VoiceOverlay extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const VoiceOverlay({super.key, this.navigatorKey});

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  // Draggable FAB position (null = not yet initialized, will default to bottom-right)
  Offset? _fabOffset;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantService>(
      builder: (context, assistant, _) {
        // Don't show overlay on auth screens (login, signup, etc.)
        if (!assistant.isActive) {
          return const SizedBox.shrink();
        }

        // Check for pending navigation
        final nav = assistant.consumePendingNavigation();
        if (nav != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(nav);
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Initialize FAB position to bottom-right on first build
            _fabOffset ??= Offset(
              constraints.maxWidth - 24 - 60,  // 60 = FAB size
              constraints.maxHeight - 24 - 60,
            );

            return Stack(
              children: [
                // ── Overlay Panel ──
                if (assistant.isOverlayVisible)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => assistant.hideOverlay(),
                      child: Container(color: Colors.black54),
                    ),
                  ),

                if (assistant.isOverlayVisible)
                  Positioned(
                    bottom: 100,
                    left: 24,
                    right: 24,
                    child: _buildOverlayPanel(context, assistant),
                  ),

                // ── Draggable Floating Mic Button ──
                if (!assistant.isOverlayVisible)
                  Positioned(
                    left: _fabOffset!.dx,
                    top: _fabOffset!.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          final newDx = (_fabOffset!.dx + details.delta.dx)
                              .clamp(0.0, constraints.maxWidth - 60);
                          final newDy = (_fabOffset!.dy + details.delta.dy)
                              .clamp(0.0, constraints.maxHeight - 60);
                          _fabOffset = Offset(newDx, newDy);
                        });
                      },
                      child: _buildMicFAB(context, assistant),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Floating Mic Button ────────────────────────────────

  Widget _buildMicFAB(BuildContext context, VoiceAssistantService assistant) {
    final theme = Theme.of(context);
    final isWakeActive = assistant.isWakeWordEnabled;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isWakeActive ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'voice_assistant_fab',
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 8,
          onPressed: () => assistant.activateManually(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.mic_rounded, size: 28),
              if (isWakeActive)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overlay Panel ──────────────────────────────────────

  Widget _buildOverlayPanel(BuildContext context, VoiceAssistantService assistant) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark
            ? Colors.grey.shade900.withOpacity(0.92)
            : Colors.white.withOpacity(0.92),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Status Header ──
          _buildStatusHeader(theme, assistant),
          const SizedBox(height: 20),

          // ── Visual Indicator ──
          _buildVisualIndicator(theme, assistant),
          const SizedBox(height: 20),

          // ── Text Display ──
          _buildTextDisplay(theme, assistant),
          const SizedBox(height: 16),

          // ── Voice Mode Badge ──
          _buildVoiceModeBadge(theme, assistant),
          const SizedBox(height: 12),

          // ── Close Button ──
          TextButton.icon(
            onPressed: () => assistant.hideOverlay(),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Dismiss'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Header ──────────────────────────────────────

  Widget _buildStatusHeader(ThemeData theme, VoiceAssistantService assistant) {
    String statusText;
    IconData statusIcon;
    Color statusColor;

    switch (assistant.state) {
      case VoiceAssistantState.listening:
        statusText = 'Listening...';
        statusIcon = Icons.hearing_rounded;
        statusColor = Colors.blueAccent;
        break;
      case VoiceAssistantState.processing:
        statusText = 'Processing...';
        statusIcon = Icons.psychology_rounded;
        statusColor = Colors.orangeAccent;
        break;
      case VoiceAssistantState.speaking:
        statusText = 'Speaking...';
        statusIcon = Icons.volume_up_rounded;
        statusColor = Colors.greenAccent;
        break;
      default:
        statusText = 'Ready';
        statusIcon = Icons.mic_rounded;
        statusColor = theme.colorScheme.primary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(statusIcon, color: statusColor, size: 22)
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1500.ms, color: statusColor.withOpacity(0.5)),
        const SizedBox(width: 10),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: statusColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Visual Indicator (Pulsing orb / wave bars) ─────────

  Widget _buildVisualIndicator(ThemeData theme, VoiceAssistantService assistant) {
    if (assistant.state == VoiceAssistantState.listening) {
      return _buildPulsingOrb(theme);
    } else if (assistant.state == VoiceAssistantState.processing) {
      return _buildProcessingDots(theme);
    } else if (assistant.state == VoiceAssistantState.speaking) {
      return _buildSoundWaves(theme);
    }
    return _buildIdleOrb(theme);
  }

  Widget _buildPulsingOrb(ThemeData theme) {
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return Container(
                width: 80 * _pulseAnimation.value,
                height: 80 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          // Middle ring
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              final scale = 1.0 + (_pulseAnimation.value - 1.0) * 0.6;
              return Container(
                width: 55 * scale,
                height: 55 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.15),
                ),
              );
            },
          ),
          // Center orb
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingDots(ThemeData theme) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent,
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(),
                  delay: Duration(milliseconds: i * 150),
                )
                .scaleXY(begin: 0.5, end: 1.3, duration: 600.ms, curve: Curves.easeInOut)
                .then()
                .scaleXY(begin: 1.3, end: 0.5, duration: 600.ms, curve: Curves.easeInOut),
          );
        }),
      ),
    );
  }

  Widget _buildSoundWaves(ThemeData theme) {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(9, (i) {
              final phase = (_waveController.value * 2 * pi) + (i * 0.7);
              final height = 15 + (sin(phase) * 18).abs();
              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 5,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent,
                      Colors.green.shade400,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildIdleOrb(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.mic_none_rounded,
        color: theme.colorScheme.primary,
        size: 28,
      ),
    );
  }

  // ── Text Display ───────────────────────────────────────

  Widget _buildTextDisplay(ThemeData theme, VoiceAssistantService assistant) {
    String displayText = '';
    if (assistant.state == VoiceAssistantState.listening) {
      displayText = assistant.partialText.isNotEmpty
          ? '"${assistant.partialText}"'
          : 'Go ahead, I\'m listening...';
    } else if (assistant.state == VoiceAssistantState.processing) {
      displayText = '"${assistant.partialText}"';
    } else if (assistant.state == VoiceAssistantState.speaking) {
      displayText = assistant.lastResponse;
    } else {
      displayText = 'Tap the mic or say "Hey Bubbles"';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        displayText,
        key: ValueKey(displayText),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: assistant.state == VoiceAssistantState.speaking ? 15 : 14,
          fontWeight: assistant.state == VoiceAssistantState.speaking
              ? FontWeight.w500
              : FontWeight.normal,
          color: theme.colorScheme.onSurface.withOpacity(0.85),
          fontStyle: assistant.state == VoiceAssistantState.listening
              ? FontStyle.italic
              : FontStyle.normal,
          height: 1.5,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Voice Mode Badge ───────────────────────────────────

  Widget _buildVoiceModeBadge(ThemeData theme, VoiceAssistantService assistant) {
    final mode = assistant.voiceMode;
    IconData icon;
    String label;

    switch (mode) {
      case VoiceMode.male:
        icon = Icons.record_voice_over_rounded;
        label = 'Male Voice';
        break;
      case VoiceMode.female:
        icon = Icons.record_voice_over_rounded;
        label = 'Female Voice';
        break;
      case VoiceMode.neutral:
        icon = Icons.smart_toy_rounded;
        label = 'Neutral (Jarvis)';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
