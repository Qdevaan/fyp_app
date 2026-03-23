import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringCtrl;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() { _ringCtrl.dispose(); super.dispose(); }

  Future<void> _checkVerification() async {
    await Supabase.instance.client.auth.refreshSession();
    final user = Supabase.instance.client.auth.currentUser;
    if (!mounted) return;
    if (user?.emailConfirmedAt != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: BubblesColors.glassDark,
          content: Text('Email not verified yet. Please check your inbox.',
              style: TextStyle(color: BubblesColors.textPrimaryDark)),
        ),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final user = _authService.currentUser;
      if (user != null && user.email != null) {
        await _authService.resendVerificationEmail(user.email!);
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
            behavior: SnackBarBehavior.floating,
            backgroundColor: BubblesColors.success.withOpacity(0.2),
            content: Text('Verification email sent!',
                style: TextStyle(color: BubblesColors.success)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend email.')));
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
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
                const SizedBox(height: 40),
                AppButton(
                  label: "I've Verified It",
                  onPressed: _checkVerification,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Resend Email',
                  onPressed: _resend,
                  loading: _resending,
                  variant: AppButtonVariant.outlined,
                  fullWidth: true,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
                  child: Text('Back to Login',
                      style: GoogleFonts.manrope(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: BubblesColors.textSecondaryDark,
                      )),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
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
                            color: isDark
                                ? AppColors.glassWhite
                                : Theme.of(context).colorScheme.primary.withAlpha(26),
                            shape: BoxShape.circle,
                            border: isDark
                                ? Border.all(color: AppColors.glassBorder)
                                : null,
                          ),
                          child: Icon(
                            Icons.mark_email_unread_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Verify your email',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 28,
                            fontWeight: FontWeight.w200,
                            color: isDark
                                ? Colors.white
                                : AppColors.slate900,
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
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.slate500,
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
