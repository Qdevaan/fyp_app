import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/social_button.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        if (!_isEmailLoading && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _showThemeSelectionDialog() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Theme',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: Text('System Default', style: GoogleFonts.manrope()),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: Text('Light', style: GoogleFonts.manrope()),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: Text('Dark', style: GoogleFonts.manrope()),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isEmailLoading = true);
    try {
      await _authService.signInWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (mounted) {
        await _showThemeSelectionDialog();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
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
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await _authService.signInWithGoogle();
      // Loading state will be cleared by the auth listener on sign-in
      if (mounted) setState(() => _isGoogleLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign in failed: $e')));
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    colors: [AppColors.primary.withAlpha(38), Colors.transparent],
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
                    colors: [AppColors.primary.withAlpha(26), Colors.transparent],
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Header — Logo + Title
                    Column(
                      children: [
                        const AppLogo(size: 80),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.manrope(
                            fontSize: 36,
                            fontWeight: FontWeight.w200,
                            color: isDark ? Colors.white : AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your premium AI Wingman & Consultant',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Form Fields
                    AppInput(
                      controller: _emailCtrl,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      hintText: 'Enter your email',
                      validator: (v) =>
                          v != null && v.contains('@') ? null : 'Invalid email',
                    ),
                    const SizedBox(height: 18),

                    // Password with Forgot Password
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'PASSWORD',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: isDark ? AppColors.slate400 : AppColors.slate500,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppInput(
                          controller: _passCtrl,
                          label: '',
                          prefixIcon: Icons.lock_outline,
                          obscure: true,
                          hintText: 'Enter your password',
                          validator: (v) => v != null && v.length >= 6
                              ? null
                              : 'Min 6 characters',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Login Button — gradient primary
                    AppButton(
                      label: 'Log In',
                      icon: Icons.arrow_forward,
                      onTap: _loginWithEmail,
                      loading: _isEmailLoading,
                      filled: true,
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.glassBorder : AppColors.slate200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'Or continue with',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.glassBorder : AppColors.slate200,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social Buttons
                    SocialButton(
                      label: 'Continue with Google',
                      imagePath: 'assets/logos/google_logo.png',
                      onTap: _loginWithGoogle,
                      loading: _isGoogleLoading,
                    ),

                    const SizedBox(height: 28),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to Bubbles? ',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: AppColors.slate400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
                    AppColors.primary.withAlpha(128),
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
