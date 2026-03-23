import 'dart:async';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';
import '../theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../utils/permissions_util.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/social_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/glass_morphism.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        if (!_isEmailLoading && mounted) {
          await _handlePostLogin();
        }
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowThemeDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSelectedTheme = prefs.getBool('has_selected_theme') ?? false;
    if (!hasSelectedTheme) {
      await _showThemeSelectionDialog();
      await prefs.setBool('has_selected_theme', true);
    }
  }

  Future<void> _showThemeSelectionDialog() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GlassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(51)),
                        ),
                        child: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select Theme',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDark ? Colors.white : AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildThemeListTile(ctx, themeProvider, isDark,
                      icon: Icons.brightness_auto,
                      label: 'System Default',
                      mode: ThemeMode.system),
                  _buildThemeListTile(ctx, themeProvider, isDark,
                      icon: Icons.light_mode,
                      label: 'Light',
                      mode: ThemeMode.light),
                  _buildThemeListTile(ctx, themeProvider, isDark,
                      icon: Icons.dark_mode,
                      label: 'Dark',
                      mode: ThemeMode.dark),
                ],
              ),
      ),
    );
  }

  Widget _buildThemeListTile(
    BuildContext ctx,
    ThemeProvider themeProvider,
    bool isDark, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
  }) {
    final isSelected = themeProvider.themeMode == mode;
    return GestureDetector(
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(ctx);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(76) : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePostLogin() async {
    final profile = await _authService.getProfile();
    final isComplete = profile != null && (profile['full_name']?.toString().isNotEmpty ?? false);

    if (mounted) {
      await PermissionsUtil.requestStartupPermissions(context);
    }
    
    if (mounted) {
      await _checkAndShowThemeDialog();
    }
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, isComplete ? '/home' : '/profile-completion');
    }
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isEmailLoading = true);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        await _handlePostLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isEmailLoading = false);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (_) {
      setState(() => _error = 'Google sign-in failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Mesh gradient background
          if (isDark) ...[
            Positioned(
              top: -120,
              left: -120,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Theme.of(context).colorScheme.primary.withAlpha(38), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -120,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Theme.of(context).colorScheme.primary.withAlpha(26), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Brand header
                    GlassBox(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.bubble_chart, color: BubblesColors.primary, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('Bubbles',
                        style: GoogleFonts.manrope(
                          fontSize: 32, fontWeight: FontWeight.w800,
                          color: BubblesColors.textPrimaryDark, letterSpacing: -0.5,
                        )),
                    const SizedBox(height: 6),
                    Text('Refined connectivity for the modern age.',
                        style: GoogleFonts.manrope(
                          fontSize: 14, fontWeight: FontWeight.w400,
                          color: BubblesColors.textSecondaryDark, letterSpacing: 0.3,
                        )),
                    const SizedBox(height: 40),
                    // Card
                    GlassBox(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome Back',
                              style: GoogleFonts.manrope(
                                fontSize: 22, fontWeight: FontWeight.w700,
                                color: BubblesColors.textPrimaryDark,
                              )),
                          const SizedBox(height: 6),
                          Text('Enter your credentials to access your workspace.',
                              style: GoogleFonts.manrope(
                                fontSize: 13, fontWeight: FontWeight.w400,
                                color: BubblesColors.textSecondaryDark,
                              )),
                          const SizedBox(height: 28),
                          AppInput(
                            label: 'Email Address',
                            hint: 'name@example.com',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefix: Icon(Icons.mail_outline, size: 18,
                                color: BubblesColors.textMutedDark),
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passCtrl,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: _signIn,
                            prefix: Icon(Icons.lock_outline, size: 18,
                                color: BubblesColors.textMutedDark),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text('Forgot?',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              child: Text(_error!,
                                  style: TextStyle(color: BubblesColors.error, fontSize: 12)),
                            ),
                          ],
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Sign In',
                            onPressed: _signIn,
                            loading: _loading,
                            fullWidth: true,
                            trailingIcon: Icons.arrow_forward,
                          ),
                          const SizedBox(height: 24),
                          // Divider
                          Row(children: [
                            const Expanded(child: Divider(color: Color(0x14FFFFFF))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR CONTINUE WITH',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10, fontWeight: FontWeight.w600,
                                    color: BubblesColors.textMutedDark, letterSpacing: 1.5,
                                  )),
                            ),
                            const Expanded(child: Divider(color: Color(0x14FFFFFF))),
                          ]),
                          const SizedBox(height: 16),
                          // Google button
                          GestureDetector(
                            onTap: _signInWithGoogle,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: BubblesColors.glassDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: BubblesColors.glassBorderDark),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.g_mobiledata, color: BubblesColors.textPrimaryDark, size: 22),
                                  const SizedBox(width: 8),
                                  Text('Continue with Google',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14, fontWeight: FontWeight.w600,
                                        color: BubblesColors.textPrimaryDark,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: TextStyle(color: BubblesColors.textSecondaryDark, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bottom accent line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.primary.withAlpha(128),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
