import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/voice_assistant_service.dart';
import '../theme/design_tokens.dart';

/// A global voice assistant overlay that matches the Bubbles design system.
/// Triggered by the "Hey Bubbles" wake word — slides up from the bottom
/// with a glassmorphic panel showing state, waveforms, and response text.
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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
        // Don't show on auth screens
        if (!assistant.isActive) return const SizedBox.shrink();

        // Handle pending navigation
        final nav = assistant.consumePendingNavigation();
        if (nav != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(nav);
          });
        }

        // Only render when overlay is visible
        if (!assistant.isOverlayVisible) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            // ── Scrim ──
            Positioned.fill(
              child: GestureDetector(
                onTap: () => assistant.hideOverlay(),
                child: AnimatedContainer(
                  duration: AppDurations.normal,
                  color: (isDark ? AppColors.backgroundDark : Colors.black)
                      .withOpacity(0.6),
                ),
              ),
            ),

            // ── Panel ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildPanel(context, assistant, isDark),
            ),
          ],
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PANEL
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildPanel(
      BuildContext context, VoiceAssistantService assistant, bool isDark) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF1F5F9),
                  Colors.white,
                ],
        ),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withOpacity(0.15)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isDark ? 0.12 : 0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Status Chip ──
            _buildStatusChip(assistant, isDark),
            const SizedBox(height: 24),

            // ── Visual Indicator ──
            _buildVisualIndicator(assistant, isDark),
            const SizedBox(height: 24),

            // ── Text Display ──
            _buildTextDisplay(assistant, isDark),
            const SizedBox(height: 20),

            // ── Bottom Bar (voice mode + dismiss) ──
            _buildBottomBar(assistant, isDark),
          ],
        ),
      ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATUS CHIP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildStatusChip(VoiceAssistantService assistant, bool isDark) {
    String label;
    Color accentColor;
    IconData icon;

    switch (assistant.state) {
      case VoiceAssistantState.listening:
        label = 'LISTENING';
        accentColor = AppColors.primary;
        icon = Icons.hearing_rounded;
        break;
      case VoiceAssistantState.processing:
        label = 'THINKING';
        accentColor = AppColors.warning;
        icon = Icons.psychology_rounded;
        break;
      case VoiceAssistantState.speaking:
        label = 'SPEAKING';
        accentColor = AppColors.success;
        icon = Icons.volume_up_rounded;
        break;
      default:
        label = 'READY';
        accentColor = AppColors.primary;
        icon = Icons.mic_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        color: accentColor.withOpacity(0.12),
        border: Border.all(
          color: accentColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated pulse dot
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.5 * (_pulseAnimation.value - 1.0) / 0.2),
                      blurRadius: 6,
                      spreadRadius: 2 * (_pulseAnimation.value - 1.0) / 0.2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Icon(icon, color: accentColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // VISUAL INDICATOR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildVisualIndicator(VoiceAssistantService assistant, bool isDark) {
    switch (assistant.state) {
      case VoiceAssistantState.listening:
        return _buildListeningOrb(isDark);
      case VoiceAssistantState.processing:
        return _buildProcessingIndicator(isDark);
      case VoiceAssistantState.speaking:
        return _buildSpeakingWaves(isDark);
      default:
        return _buildIdleOrb(isDark);
    }
  }

  /// Pulsing orb with concentric rings — listening state
  Widget _buildListeningOrb(bool isDark) {
    return SizedBox(
      height: 90,
      width: 90,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 90 * _pulseAnimation.value,
                height: 90 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 65 * (1.0 + (_pulseAnimation.value - 1.0) * 0.6),
                height: 65 * (1.0 + (_pulseAnimation.value - 1.0) * 0.6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
              // Center orb
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Sequenced dots — processing state
  Widget _buildProcessingIndicator(bool isDark) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          return AnimatedBuilder(
            animation: _waveController,
            builder: (context, _) {
              final phase = (_waveController.value * 2 * pi) + (i * 1.2);
              final scale = 0.6 + (sin(phase) + 1) * 0.35;
              final opacity = 0.4 + (sin(phase) + 1) * 0.3;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.warning.withOpacity(opacity),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withOpacity(opacity * 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// Waveform bars — speaking state
  Widget _buildSpeakingWaves(bool isDark) {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(11, (i) {
              final phase = (_waveController.value * 2 * pi) + (i * 0.6);
              final height = 14.0 + (sin(phase) * 20).abs();
              return AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.5),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  /// Idle orb — subtle waiting state
  Widget _buildIdleOrb(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        final glow = (_pulseAnimation.value - 1.0) / 0.2; // 0..1
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.06 + glow * 0.04),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2 + glow * 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(glow * 0.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            Icons.mic_none_rounded,
            color: AppColors.primary.withOpacity(0.7),
            size: 26,
          ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TEXT DISPLAY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildTextDisplay(VoiceAssistantService assistant, bool isDark) {
    String displayText;
    FontWeight weight = FontWeight.w500;
    double fontSize = 14;
    Color textColor;

    switch (assistant.state) {
      case VoiceAssistantState.listening:
        displayText = assistant.partialText.isNotEmpty
            ? '"${assistant.partialText}"'
            : 'Go ahead, I\'m listening…';
        textColor = isDark
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF475569);
        break;
      case VoiceAssistantState.processing:
        displayText = '"${assistant.partialText}"';
        textColor = isDark
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF475569);
        break;
      case VoiceAssistantState.speaking:
        displayText = assistant.lastResponse;
        weight = FontWeight.w500;
        fontSize = 15;
        textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        break;
      default:
        displayText = 'Say "Hey Bubbles" to begin';
        textColor = isDark
            ? AppColors.textSecondary
            : AppColors.textMuted;
    }

    return AnimatedSwitcher(
      duration: AppDurations.normal,
      child: Text(
        displayText,
        key: ValueKey(displayText),
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          fontSize: fontSize,
          fontWeight: weight,
          color: textColor,
          height: 1.5,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BOTTOM BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildBottomBar(VoiceAssistantService assistant, bool isDark) {
    return Row(
      children: [
        // Voice mode badge
        _buildVoiceModeBadge(assistant, isDark),
        const Spacer(),
        // Dismiss button
        GestureDetector(
          onTap: () => assistant.hideOverlay(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.shade100,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Dismiss',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceModeBadge(VoiceAssistantService assistant, bool isDark) {
    final mode = assistant.voiceMode;
    IconData icon;
    String label;

    switch (mode) {
      case VoiceMode.male:
        icon = Icons.record_voice_over_rounded;
        label = 'Male';
        break;
      case VoiceMode.female:
        icon = Icons.record_voice_over_rounded;
        label = 'Female';
        break;
      case VoiceMode.neutral:
        icon = Icons.smart_toy_rounded;
        label = 'Jarvis';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: AppColors.primary.withOpacity(0.08),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
