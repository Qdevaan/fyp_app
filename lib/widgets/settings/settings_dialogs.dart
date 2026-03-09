import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/design_tokens.dart';
import '../../providers/theme_provider.dart';
import '../../services/voice_assistant_service.dart';
import 'settings_widgets.dart';

/// Shows a "coming soon" snackbar for a feature.
void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature is coming soon!'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Shows a contact-us bottom sheet.
void showContactSheet(BuildContext context, bool isDark) {
  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.slate800 : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      final primary = Theme.of(context).colorScheme.primary;
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Contact Us',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Have questions, feedback, or need support? Reach out to the Bubbles team.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: isDark ? AppColors.slate400 : AppColors.slate500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ContactRow(
              isDark: isDark,
              icon: Icons.email_outlined,
              iconColor: primary,
              label: 'Email Support',
              value: 'support@bubbles.ai',
            ),
            const SizedBox(height: 12),
            ContactRow(
              isDark: isDark,
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF3B82F6),
              label: 'Website',
              value: 'www.bubbles.ai',
            ),
            const SizedBox(height: 12),
            ContactRow(
              isDark: isDark,
              icon: Icons.bug_report_outlined,
              iconColor: AppColors.warning,
              label: 'Report a Bug',
              value: 'bugs@bubbles.ai',
            ),
          ],
        ),
      );
    },
  );
}

/// Shows a theme mode picker dialog (System / Light / Dark).
void showThemeModePicker(BuildContext context, ThemeProvider themeProvider) {
  showDialog(
    context: context,
    builder: (ctx) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withAlpha(26),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Select Theme Mode',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, themeProvider,
                title: 'System Default',
                icon: Icons.brightness_auto,
                mode: ThemeMode.system,
                isDark: isDark),
            const SizedBox(height: 8),
            _buildThemeOption(context, themeProvider,
                title: 'Light',
                icon: Icons.light_mode,
                mode: ThemeMode.light,
                isDark: isDark),
            const SizedBox(height: 8),
            _buildThemeOption(context, themeProvider,
                title: 'Dark',
                icon: Icons.dark_mode,
                mode: ThemeMode.dark,
                isDark: isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.slate400 : AppColors.slate500,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildThemeOption(
  BuildContext context,
  ThemeProvider themeProvider, {
  required String title,
  required IconData icon,
  required ThemeMode mode,
  required bool isDark,
}) {
  final isSelected = themeProvider.themeMode == mode;
  return GestureDetector(
    onTap: () {
      themeProvider.setThemeMode(mode);
      Navigator.pop(context);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withAlpha(26)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(76)
              : (isDark ? Colors.white10 : Colors.black12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
        ],
      ),
    ),
  );
}

/// Shows an accent color picker dialog.
void showColorPicker(BuildContext context, ThemeProvider themeProvider) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Accent Color'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Colors.blueAccent,
            Colors.redAccent,
            Colors.greenAccent,
            Colors.orangeAccent,
            Colors.purpleAccent,
            Colors.tealAccent,
            Colors.pinkAccent,
            Colors.amberAccent,
            Colors.indigoAccent,
            Colors.grey,
          ].map((color) {
            return GestureDetector(
              onTap: () {
                themeProvider.setThemeColor(color);
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: themeProvider.seedColor.value == color.value
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

/// Shows a voice mode picker bottom sheet (Male / Female / Jarvis).
void showVoiceModePicker(BuildContext context, VoiceAssistantService voice) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? AppColors.surfaceDark
        : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        VoiceMode selectedMode = voice.voiceMode;

        Widget buildCard({
          required VoiceMode mode,
          required IconData icon,
          required String label,
          required Color color,
        }) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final isSelected = selectedMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setSheetState(() => selectedMode = mode);
                voice.setVoiceMode(mode);
                Future.delayed(AppDurations.fast, () {
                  if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                });
              },
              child: AnimatedContainer(
                duration: AppDurations.tooltip,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected
                      ? color.withAlpha(38)
                      : (isDark
                          ? AppColors.surfaceDarkHighlight
                          : Colors.grey.shade100),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : (isDark
                            ? Colors.white.withAlpha(26)
                            : Colors.grey.shade300),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? color
                          : (isDark ? Colors.white54 : Colors.grey),
                      size: 30,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? color
                            : (isDark ? Colors.white54 : Colors.grey),
                      ),
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Voice Mode',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  buildCard(
                    mode: VoiceMode.male,
                    icon: Icons.man_rounded,
                    label: 'Male',
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 10),
                  buildCard(
                    mode: VoiceMode.female,
                    icon: Icons.woman_rounded,
                    label: 'Female',
                    color: Colors.pinkAccent,
                  ),
                  const SizedBox(width: 10),
                  buildCard(
                    mode: VoiceMode.neutral,
                    icon: Icons.smart_toy_rounded,
                    label: 'Jarvis',
                    color: Colors.tealAccent.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ),
  );
}
