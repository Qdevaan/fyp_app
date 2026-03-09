import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'verify_email_screen.dart';

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
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      if (res.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
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
      body: BgMesh(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
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
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: BubblesColors.primary, letterSpacing: 0.5,
                                  )),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: BubblesColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: BubblesColors.error.withOpacity(0.3)),
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
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignupScreen())),
                          child: Text('Create an account',
                              style: GoogleFonts.manrope(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: BubblesColors.primary,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
