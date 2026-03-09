import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'User') as String;
    final email = user?.email ?? '';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: isDark ? BubblesColors.bgDark : BubblesColors.bgLight,
      body: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountCard(context, name, email, avatarUrl, isDark),
                  const SizedBox(height: 20),
                  _SectionLabel('PREFERENCES'),
                  const SizedBox(height: 8),
                  _buildPrefsCard(context, isDark, themeProvider),
                  const SizedBox(height: 20),
                  _SectionLabel('VOICE ASSISTANT'),
                  const SizedBox(height: 8),
                  _buildVoiceCard(context, isDark),
                  const SizedBox(height: 20),
                  _SectionLabel('ACCOUNT'),
                  const SizedBox(height: 8),
                  _buildAccountActionsCard(context, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BubblesBottomNav(
        currentIndex: 4,
        onTap: (i) {
          if (i != 4) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? BubblesColors.glassHeaderDark : BubblesColors.bgLight,
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0x1A13BDEC) : const Color(0x0F000000),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back,
                color: isDark ? BubblesColors.textPrimaryDark : BubblesColors.textPrimaryLight),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text('Settings', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? BubblesColors.textPrimaryDark : BubblesColors.textPrimaryLight,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext ctx, String name, String email,
      String? avatarUrl, bool isDark) {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(16),
      bgColor: isDark ? BubblesColors.glassDark : const Color(0xFFF0F9FF),
      borderColor: isDark ? BubblesColors.glassBorderDark : const Color(0x3313BDEC),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: BubblesColors.primary.withOpacity(0.2),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: GoogleFonts.manrope(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: BubblesColors.primary,
                    ))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.manrope(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: isDark ? BubblesColors.textPrimaryDark : BubblesColors.textPrimaryLight,
                )),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(
                  fontSize: 12, color: isDark ? BubblesColors.textSecondaryDark : BubblesColors.textSecondaryLight,
                )),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
            color: isDark ? BubblesColors.textMutedDark : BubblesColors.textMutedLight),
        ],
      ),
    );
  }

  Widget _buildPrefsCard(BuildContext ctx, bool isDark, ThemeProvider theme) {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.symmetric(vertical: 4),
      bgColor: isDark ? BubblesColors.glassDark : const Color(0xFFF0F9FF),
      borderColor: isDark ? BubblesColors.glassBorderDark : const Color(0x2013BDEC),
      child: Column(
        children: [
          _ToggleTile(
            icon: Icons.dark_mode_outlined,
            label: 'Dark Mode',
            value: isDark,
            onChanged: (_) => theme.setThemeMode(theme.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
            isDark: isDark,
          ),
          _Divider(isDark),
          _ToggleTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            value: true,
            onChanged: (_) {},
            isDark: isDark,
          ),
          _Divider(isDark),
          _NavTile(
            icon: Icons.palette_outlined,
            label: 'Accent Color',
            trailing: Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: BubblesColors.primary,
              ),
            ),
            onTap: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCard(BuildContext ctx, bool isDark) {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.symmetric(vertical: 4),
      bgColor: isDark ? BubblesColors.glassDark : const Color(0xFFF0F9FF),
      borderColor: isDark ? BubblesColors.glassBorderDark : const Color(0x2013BDEC),
      child: Column(
        children: [
          _ToggleTile(
            icon: Icons.mic_outlined,
            label: 'Wake Word Detection',
            value: true,
            onChanged: (_) {},
            isDark: isDark,
          ),
          _Divider(isDark),
          _ToggleTile(
            icon: Icons.volume_up_outlined,
            label: 'Voice Responses',
            value: true,
            onChanged: (_) {},
            isDark: isDark,
          ),
          _Divider(isDark),
          _NavTile(
            icon: Icons.record_voice_over_outlined,
            label: 'Voice Enrollment',
            onTap: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionsCard(BuildContext ctx, bool isDark) {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.symmetric(vertical: 4),
      bgColor: isDark ? BubblesColors.glassDark : const Color(0xFFF0F9FF),
      borderColor: isDark ? BubblesColors.glassBorderDark : const Color(0x2013BDEC),
      child: Column(
        children: [
          _NavTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy & Data',
            onTap: () {},
            isDark: isDark,
          ),
          _Divider(isDark),
          _NavTile(
            icon: Icons.info_outline,
            label: 'About Bubbles',
            onTap: () {},
            isDark: isDark,
          ),
          _Divider(isDark),
          _NavTile(
            icon: Icons.logout,
            label: 'Log Out',
            color: const Color(0xFFF43F5E),
            onTap: () => _confirmLogout(ctx),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassBox(
          borderRadius: 20, padding: const EdgeInsets.all(24),
          bgColor: BubblesColors.glassHeaderDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF43F5E).withOpacity(0.15),
                ),
                child: const Icon(Icons.logout, color: Color(0xFFF43F5E), size: 26),
              ),
              const SizedBox(height: 16),
              Text('Log Out?', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: BubblesColors.textPrimaryDark,
              )),
              const SizedBox(height: 8),
              Text('You will need to log in again to access Bubbles.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: BubblesColors.textSecondaryDark),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Log Out',
                      variant: AppButtonVariant.danger,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await Supabase.instance.client.auth.signOut();
                        if (ctx.mounted) {
                          Navigator.of(ctx).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(text, style: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w700,
      letterSpacing: 1.2, color: BubblesColors.textMutedDark,
    )),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  const _ToggleTile({required this.icon, required this.label, required this.value,
    required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: BubblesColors.primary, size: 20),
      title: Text(label, style: GoogleFonts.manrope(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: isDark ? BubblesColors.textPrimaryDark : BubblesColors.textPrimaryLight,
      )),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: BubblesColors.primary,
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;
  final Widget? trailing;
  const _NavTile({required this.icon, required this.label, required this.onTap,
    required this.isDark, this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? BubblesColors.textPrimaryDark : BubblesColors.textPrimaryLight);
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(icon, color: color ?? BubblesColors.primary, size: 20),
      title: Text(label, style: GoogleFonts.manrope(
        fontSize: 14, fontWeight: FontWeight.w600, color: c,
      )),
      trailing: trailing ?? Icon(Icons.chevron_right,
        color: isDark ? BubblesColors.textMutedDark : BubblesColors.textMutedLight, size: 18),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider(this.isDark);
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    color: isDark ? BubblesColors.glassBorderDark : const Color(0x0A000000),
    indent: 55,
  );
}
