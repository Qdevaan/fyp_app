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
      final email = Supabase.instance.client.auth.currentUser?.email ?? '';
      await Supabase.instance.client.auth.resend(type: OtpType.email, email: email);
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
      body: BgMesh(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated mail icon disc
                SizedBox(
                  width: 160, height: 160,
                  child: AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, __) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Expanding ring
                          Opacity(
                            opacity: (1.0 - _ringCtrl.value).clamp(0.0, 1.0),
                            child: Container(
                              width: 120 + 40 * _ringCtrl.value,
                              height: 120 + 40 * _ringCtrl.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: BubblesColors.primary.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          GlassBox(
                            width: 100, height: 100, borderRadius: 999,
                            child: Icon(Icons.mail_outline, color: BubblesColors.primary, size: 48),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Text('Check your inbox',
                    style: GoogleFonts.manrope(
                      fontSize: 26, fontWeight: FontWeight.w700,
                      color: BubblesColors.textPrimaryDark, letterSpacing: -0.3,
                    )),
                const SizedBox(height: 12),
                Text(
                  "We've sent a verification link to your email address. Please check your inbox and click the link to verify your account.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14, fontWeight: FontWeight.w400,
                    color: BubblesColors.textSecondaryDark, height: 1.5,
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
          ),
        ),
      ),
    );
  }
}
