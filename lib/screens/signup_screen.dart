import 'dart:async';
import '../theme/design_tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/social_button.dart';
import '../widgets/app_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  double _passwordStrength = 0;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_updatePasswordStrength);
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
    _passCtrl.removeListener(_updatePasswordStrength);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final pw = _passCtrl.text;
    double score = 0;
    if (pw.length >= 6) score += 0.2;
    if (pw.length >= 10) score += 0.1;
    if (pw.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (pw.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (pw.contains(RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]{};:,.<>?/\\|`~]'))) score += 0.2;
    if (pw.length >= 14) score += 0.1;
    setState(() => _passwordStrength = score.clamp(0.0, 1.0));
  }

  String get _strengthLabel {
    if (_passwordStrength <= 0) return '';
    if (_passwordStrength < 0.3) return 'Weak';
    if (_passwordStrength < 0.6) return 'Fair';
    if (_passwordStrength < 0.8) return 'Good';
    return 'Strong';
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.3) return AppColors.error;
    if (_passwordStrength < 0.6) return AppColors.warning;
    if (_passwordStrength < 0.8) return AppColors.primary;
    return AppColors.success;
  }

  Future<void> _signupWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isEmailLoading = true);
    try {
      await _authService.signUpWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, '/verify-email');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _signupWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) setState(() => _isGoogleLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign up failed: $e')));
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Decorative Background Blobs
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withAlpha(38),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withAlpha(20),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),

                          // Header + Logo + Title
                          Column(
                            children: [
                              const AppLogo(size: 80),
                              const SizedBox(height: 16),
                              Text(
                                'Create Account',
                                style: GoogleFonts.manrope(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.slate900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Join your personal Wingman today.',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.slate400
                                      : AppColors.slate500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Form Fields
                          AppInput(
                            controller: _emailCtrl,
                            label: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            type: TextInputType.emailAddress,
                            hintText: 'Enter your email',
                            validator: (v) => v != null && v.contains('@')
                                ? null
                                : 'Invalid email',
                          ),
                          const SizedBox(height: 16),

                          AppInput(
                            controller: _passCtrl,
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            hintText: 'Enter your password',
                            obscure: true,
                            validator: (v) => v != null && v.length >= 6
                                ? null
                                : 'Min 6 characters',
                          ),
                          if (_passCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      backgroundColor: isDark
                                          ? AppColors.slate700
                                          : AppColors.slate200,
                                      color: _strengthColor,
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _strengthLabel,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _strengthColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),

                          AppInput(
                            controller: _confirmPassCtrl,
                            label: 'Confirm Password',
                            prefixIcon: Icons.lock_reset,
                            hintText: 'Re-enter your password',
                            obscure: true,
                            validator: (v) => v == _passCtrl.text
                                ? null
                                : 'Passwords do not match',
                          ),

                          const SizedBox(height: 32),

                          // Actions
                          AppButton(
                            label: 'Sign Up',
                            onTap: _signupWithEmail,
                            loading: _isEmailLoading,
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.manrope(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          SocialButton(
                            label: 'Continue with Google',
                            imagePath: 'assets/logos/google_logo.png',
                            onTap: _signupWithGoogle,
                            loading: _isGoogleLoading,
                          ),
                          const SizedBox(height: 20),
                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: GoogleFonts.manrope(
                                  color: isDark
                                      ? AppColors.slate300
                                      : AppColors.slate500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Log In',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Bottom spacing for keyboard/scroll
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
