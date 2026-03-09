import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/connection_service.dart';
import '../services/voice_assistant_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await AuthService.instance.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showContactSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                    color: isDark
                        ? const Color(0xFF475569)
                        : Colors.grey.shade300,
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
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Have questions, feedback, or need support? Reach out to the Bubbles team.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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
                iconColor: const Color(0xFFF59E0B),
                label: 'Report a Bug',
                value: 'bugs@bubbles.ai',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          // Swipe Left -> go back
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Done',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Settings',
                    style: GoogleFonts.manrope(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),

              // --- Content ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ACCOUNT SECTION
                      SectionLabel(label: 'Account'),
                      GroupedContainer(
                        isDark: isDark,
                        children: [
                          // Profile Tile
                          ProfileTile(isDark: isDark),
                          TileDivider(isDark: isDark),
                          // Subscription
                          SettingsTile(
                            isDark: isDark,
                            iconBg: const Color(0xFF818CF8).withOpacity(0.2),
                            iconColor: const Color(0xFF818CF8),
                            icon: Icons.diamond_outlined,
                            title: 'Subscription',
                            trailing: Text(
                              'Free Plan',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onTap: () =>
                                _showComingSoon(context, 'Subscription'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // PREFERENCES SECTION
                      SectionLabel(label: 'Preferences'),
                      GroupedContainer(
                        isDark: isDark,
                        children: [
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) =>
                                SettingsTile(
                                  isDark: isDark,
                                  iconBg: const Color(
                                    0xFF38BDF8,
                                  ).withOpacity(0.2),
                                  iconColor: const Color(0xFF38BDF8),
                                  icon: Icons.brightness_medium_outlined,
                                  title: 'Theme Mode',
                                  trailing: Text(
                                    themeProvider.themeMode == ThemeMode.system
                                        ? 'System'
                                        : themeProvider.themeMode ==
                                              ThemeMode.dark
                                        ? 'Dark'
                                        : 'Light',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  onTap: () => _showThemeModePicker(
                                    context,
                                    themeProvider,
                                  ),
                                ),
                          ),
                          TileDivider(isDark: isDark),
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) =>
                                SettingsTile(
                                  isDark: isDark,
                                  iconBg: themeProvider.seedColor.withOpacity(
                                    0.2,
                                  ),
                                  iconColor: themeProvider.seedColor,
                                  icon: Icons.color_lens_outlined,
                                  title: 'Accent Color',
                                  trailing: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: themeProvider.seedColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  onTap: () =>
                                      _showColorPicker(context, themeProvider),
                                ),
                          ),
                          TileDivider(isDark: isDark),
                          SettingsTile(
                            isDark: isDark,
                            iconBg: const Color(0xFF34D399).withOpacity(0.2),
                            iconColor: const Color(0xFF34D399),
                            icon: Icons.translate,
                            title: 'Language',
                            trailing: Text(
                              'English (US)',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                            onTap: () => _showComingSoon(context, 'Language'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // VOICE ASSISTANT
                      SectionLabel(label: 'Voice Assistant'),
                      Consumer<VoiceAssistantService>(
                        builder: (context, voice, _) {
                          return GroupedContainer(
                            isDark: isDark,
                            children: [
                              ToggleTile(
                                isDark: isDark,
                                iconBg: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                icon: Icons.hearing_rounded,
                                title: '"Hey Bubbles" Wake Word',
                                value: voice.isWakeWordEnabled,
                                onChanged: (val) =>
                                    voice.setWakeWordEnabled(val),
                              ),
                              TileDivider(isDark: isDark),
                              SettingsTile(
                                isDark: isDark,
                                iconBg: Colors.teal.withOpacity(0.2),
                                iconColor: Colors.tealAccent.shade700,
                                icon: Icons.record_voice_over_outlined,
                                title: 'Voice Mode',
                                trailing: Text(
                                  voice.voiceMode.name[0].toUpperCase() +
                                      voice.voiceMode.name.substring(1),
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                onTap: () =>
                                    _showVoiceModePicker(context, voice),
                              ),
                              TileDivider(isDark: isDark),
                              VoiceEnrollmentSection(isDark: isDark),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // PRIVACY
                      SectionLabel(label: 'Privacy'),
                      GroupedContainer(
                        isDark: isDark,
                        children: [
                          SettingsTile(
                            isDark: isDark,
                            iconBg: Colors.grey.withOpacity(0.2),
                            iconColor: isDark
                                ? const Color(0xFFCBD5E1)
                                : Colors.grey.shade600,
                            icon: Icons.storage_outlined,
                            title: 'Data Management',
                            onTap: () =>
                                _showComingSoon(context, 'Data Management'),
                          ),
                          TileDivider(isDark: isDark),
                          SettingsTile(
                            isDark: isDark,
                            iconBg: Colors.grey.withOpacity(0.2),
                            iconColor: isDark
                                ? const Color(0xFFCBD5E1)
                                : Colors.grey.shade600,
                            icon: Icons.lock_outline,
                            title: 'Permissions',
                            onTap: () =>
                                _showComingSoon(context, 'Permissions'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // NOTIFICATIONS
                      SectionLabel(label: 'Notifications'),
                      Consumer<ConnectionService>(
                        builder: (context, conn, _) => GroupedContainer(
                          isDark: isDark,
                          children: [
                            ToggleTile(
                              isDark: isDark,
                              iconBg: const Color(0xFFF43F5E).withOpacity(0.2),
                              iconColor: const Color(0xFFF43F5E),
                              icon: Icons.notifications_outlined,
                              title: 'Push Notifications',
                              value: true,
                              onChanged: (_) => _showComingSoon(
                                context,
                                'Push Notifications',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ABOUT & SUPPORT
                      SectionLabel(label: 'About & Support'),
                      GroupedContainer(
                        isDark: isDark,
                        children: [
                          SettingsTile(
                            isDark: isDark,
                            iconBg: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.15),
                            iconColor: Theme.of(context).colorScheme.primary,
                            icon: Icons.info_outline_rounded,
                            title: 'About Bubbles',
                            onTap: () => Navigator.pushNamed(context, '/about'),
                          ),
                          TileDivider(isDark: isDark),
                          SettingsTile(
                            isDark: isDark,
                            iconBg: const Color(0xFF10B981).withOpacity(0.15),
                            iconColor: const Color(0xFF10B981),
                            icon: Icons.mail_outline_rounded,
                            title: 'Contact Us',
                            onTap: () => _showContactSheet(context, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // LOG OUT
                      _isLoggingOut
                          ? const Center(child: CircularProgressIndicator())
                          : GestureDetector(
                              onTap: _logout,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Log Out',
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      // Version
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Bubbles v1.0.4',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Made with AI Love',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeModePicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                themeProvider,
                title: 'System Default',
                icon: Icons.brightness_auto,
                mode: ThemeMode.system,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                themeProvider,
                title: 'Light',
                icon: Icons.light_mode,
                mode: ThemeMode.light,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                themeProvider,
                title: 'Dark',
                icon: Icons.dark_mode,
                mode: ThemeMode.dark,
                isDark: isDark,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Close',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
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

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Accent Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                [
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

  void _showVoiceModePicker(BuildContext context, VoiceAssistantService voice) {
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
          // Track selected mode locally so cards update immediately on tap
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
                  Future.delayed(const Duration(milliseconds: 180), () {
                    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : (isDark
                              ? AppColors.surfaceDarkHighlight
                              : Colors.grey.shade100),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark
                                ? Colors.white.withOpacity(0.1)
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
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
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
}
