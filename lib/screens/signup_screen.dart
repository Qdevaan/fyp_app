import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/social_button.dart';
// ignore: unused_import
import '../theme/design_tokens.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  bool _loading = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signupWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    try {
      await _authService.signUpWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.pushNamed(context, '/verify-email');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        )
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signupWithGoogle() async {
    setState(() => _loading = true);
    try {
      await _authService.signInWithGoogle();
      // AuthGate will handle navigation
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign up failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Header Section
                _FadeSlide(
                  controller: _animController,
                  interval: const Interval(0.0, 0.4, curve: Curves.easeOut),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.bubble_chart, size: 32, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create Account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join your personal Wingman today.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Form Section
                _FadeSlide(
                  controller: _animController,
                  interval: const Interval(0.2, 0.6, curve: Curves.easeOut),
                  child: Column(
                    children: [
                      AppInput(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        type: TextInputType.emailAddress,
                        validator: (v) => v != null && v.contains('@') ? null : 'Invalid email',
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _passCtrl,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscure: true,
                        validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _confirmPassCtrl,
                        label: 'Confirm Password',
                        prefixIcon: Icons.lock_reset,
                        obscure: true,
                        validator: (v) => v == _passCtrl.text ? null : 'Passwords do not match',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons Section
                _FadeSlide(
                  controller: _animController,
                  interval: const Interval(0.4, 0.8, curve: Curves.easeOut),
                  child: Column(
                    children: [
                      AppButton(
                        label: 'Sign Up',
                        onTap: _signupWithEmail,
                        loading: _loading,
                        filled: true,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SocialButton(
                        label: 'Continue with Google',
                        icon: Icons.g_mobiledata, // Or use a custom SVG asset
                        onTap: _signupWithGoogle,
                        loading: _loading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer Section
                _FadeSlide(
                  controller: _animController,
                  interval: const Interval(0.6, 1.0, curve: Curves.easeOut),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Go back to login
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom spacing for scroll
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for Staggered Animations
class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;

  const _FadeSlide({
    required this.controller,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: interval),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: controller, curve: interval),
        ),
        child: child,
      ),
    );
  }
}