import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../theme/design_tokens.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService.instance;
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
    _animController.dispose();
    super.dispose();
  }

  void _checkVerification() async {
    // Reload user to get latest metadata
    try {
      // Note: Supabase user reload might be needed depending on implementation, 
      // but accessing the property triggers a check on the current instance.
      // Ideally, you might want to call _authService.refreshSession() if available.
      
      if (_authService.isEmailVerified) {
        Navigator.of(context).pushNamedAndRemoveUntil('/profile-completion', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email not verified yet. Please check your inbox.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
       // handle error
    }
  }

  void _resendEmail() async {
    setState(() => _loading = true);
    try {
      final user = _authService.currentUser;
      if (user != null && user.email != null) {
        await _authService.signUpWithEmail(user.email!, ''); // Trigger resend link
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Verification email sent!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              
              // Icon & Title
              _FadeSlide(
                controller: _animController,
                interval: const Interval(0.0, 0.4, curve: Curves.easeOut),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Verify your email',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We have sent a verification link to your email address. Please tap the link in the email to continue.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Buttons
              _FadeSlide(
                controller: _animController,
                interval: const Interval(0.2, 0.6, curve: Curves.easeOut),
                child: Column(
                  children: [
                    AppButton(
                      label: 'I have verified it',
                      onTap: _checkVerification,
                      loading: _loading,
                      filled: true,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Resend Email',
                      onTap: _resendEmail,
                      loading: _loading,
                      filled: false,
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
            ],
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