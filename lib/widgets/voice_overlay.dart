import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/voice_assistant_service.dart';
import '../theme/design_tokens.dart';

/// A global voice assistant overlay that matches the Bubbles design system.
/// Triggered by the "Hey Bubbles" wake word Ã¢â‚¬â€ slides up from the bottom
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
            BubblesApp.navigatorKey.currentState?.pushNamed(
              nav['route'] as String,
              arguments: nav['args'],
            );
          });
        }

        // Only render when overlay is visible
        if (!assistant.isOverlayVisible) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            // Ã¢â€â‚¬Ã¢â€â‚¬ Scrim Ã¢â€â‚¬Ã¢â€â‚¬
            Positioned.fill(
              child: Semantics(
                label: 'Dismiss voice assistant',
                button: true,
                child: GestureDetector(
                onTap: () => assistant.hideOverlay(),
                child: AnimatedContainer(
                  duration: AppDurations.normal,
                  color: (isDark ? AppColors.backgroundDark : Colors.black)
                      .withAlpha(153),
                ),
              ),
              ),
            ),

            // Ã¢â€â‚¬Ã¢â€â‚¬ Panel Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â
  // PANEL
  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â

  Widget _buildPanel(
    BuildContext context,
    VoiceAssistantService assistant,
    bool isDark,
  ) {
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
                    AppColors.slate900,
                    AppColors.slate800,
                    AppColors.slate900,
                  ]
                : [Colors.white, AppColors.slate100, Colors.white],
          ),
          border: Border.all(
            color: isDark
                ? Theme.of(context).colorScheme.primary.withAlpha(38)
                : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(isDark ? 31 : 20),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 102 : 26),
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
              // Ã¢â€â‚¬Ã¢â€â‚¬ Status Chip Ã¢â€â‚¬Ã¢â€â‚¬
              _buildStatusChip(assistant, isDark),
              const SizedBox(height: 24),

              // Ã¢â€â‚¬Ã¢â€â‚¬ Visual Indicator Ã¢â€â‚¬Ã¢â€â‚¬
              _buildVisualIndicator(assistant, isDark),
              const SizedBox(height: 24),

              // Ã¢â€â‚¬Ã¢â€â‚¬ Text Display Ã¢â€â‚¬Ã¢â€â‚¬
              _buildTextDisplay(assistant, isDark),
              const SizedBox(height: 20),

              // Ã¢â€â‚¬Ã¢â€â‚¬ Bottom Bar (voice mode + dismiss) Ã¢â€â‚¬Ã¢â€â‚¬
              _buildBottomBar(assistant, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â
  // STATUS CHIP
  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â

  Widget _buildStatusChip(VoiceAssistantService assistant, bool isDark) {
    String label;
    Color accentColor;
    IconData icon;

    switch (assistant.state) {
      case VoiceAssistantState.listening:
        label = 'LISTENING';
        accentColor = Theme.of(context).colorScheme.primary;
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
        accentColor = Theme.of(context).colorScheme.primary;
        icon = Icons.mic_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        color: accentColor.withAlpha(31),
        border: Border.all(color: accentColor.withAlpha(64), width: 1),
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
                      color: accentColor.withAlpha(
                        ((0.5 * (_pulseAnimation.value - 1.0) / 0.2) * 255).round(),
                      ),
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

  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â
  // VISUAL INDICATOR
  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â

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

  /// Pulsing orb with concentric rings Ã¢â‚¬â€ listening state
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
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(38),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(20),
                ),
              ),
              // Center orb
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(102),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Sequenced dots Ã¢â‚¬â€ processing state
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
                      color: AppColors.warning.withAlpha((opacity * 255).round()),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withAlpha((opacity * 0.4 * 255).round()),
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

  /// Waveform bars Ã¢â‚¬â€ speaking state
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
                      AppColors.success.withAlpha(128),
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

  /// Idle orb Ã¢â‚¬â€ subtle waiting state
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
            color: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(((0.06 + glow * 0.04) * 255).round()),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(((0.2 + glow * 0.1) * 255).round()),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((glow * 0.15 * 255).round()),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            Icons.mic_none_rounded,
            color: Theme.of(context).colorScheme.primary.withAlpha(178),
            size: 26,
          ),
        );
      },
    );
  }

  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â
  // TEXT DISPLAY
  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â

  Widget _buildTextDisplay(VoiceAssistantService assistant, bool isDark) {
    String displayText;
    FontWeight weight = FontWeight.w500;
    double fontSize = 14;
    Color textColor;

    switch (assistant.state) {
      case VoiceAssistantState.listening:
        displayText = assistant.partialText.isNotEmpty
            ? '"${assistant.partialText}"'
            : 'Go ahead, I\'m listening...';
        textColor = isDark ? AppColors.slate300 : AppColors.slate600;
        break;
      case VoiceAssistantState.processing:
        displayText = '"${assistant.partialText}"';
        textColor = isDark ? AppColors.slate300 : AppColors.slate600;
        break;
      case VoiceAssistantState.speaking:
        displayText = assistant.lastResponse;
        weight = FontWeight.w500;
        fontSize = 15;
        textColor = isDark ? Colors.white : AppColors.slate900;
        break;
      default:
        displayText = 'Say "Hey Bubbles" to begin';
        textColor = isDark ? AppColors.textSecondary : AppColors.textMuted;
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

  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â
  // BOTTOM BAR
  // Ã¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€ÂÃ¢â€Â

  Widget _buildBottomBar(VoiceAssistantService assistant, bool isDark) {
    return Row(
      children: [
        // Voice mode badge
        _buildVoiceModeBadge(assistant, isDark),
        const Spacer(),
        // Dismiss button
        Semantics(
          button: true,
          label: 'Dismiss voice assistant',
          child: GestureDetector(
          onTap: () => assistant.hideOverlay(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.grey.shade100,
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(20)
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
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
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
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(38),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
