import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/voice_assistant_service.dart';
import '../theme/design_tokens.dart';
import 'voice/voice_overlay_controls.dart';
import 'voice/voice_visual_indicator.dart';

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
                ? AppColors.primary.withAlpha(38)
                : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(isDark ? 31 : 20),
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
              VoiceStatusChip(
                state: assistant.state,
                pulseAnimation: _pulseAnimation,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              VoiceVisualIndicator(
                state: assistant.state,
                pulseAnimation: _pulseAnimation,
                waveController: _waveController,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              VoiceTextDisplay(assistant: assistant, isDark: isDark),
              const SizedBox(height: 20),
              VoiceBottomBar(assistant: assistant, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}
