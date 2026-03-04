import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService.instance;
  bool _loading = false;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Consistent header
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.9),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Verify Email',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 1),

                    // Icon & Title
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_unread_rounded,
                            size: 64,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Verify your email',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We have sent a verification link to your email address. Please tap the link in the email to continue.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Buttons
                    Column(
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

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}