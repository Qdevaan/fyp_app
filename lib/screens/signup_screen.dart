import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import 'verify_email_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  double _passwordStrength = 0;
  String _strengthLabel = '';

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_updateStrength);
  }

  void _updateStrength() {
    final p = _passCtrl.text;
    double s = 0;
    if (p.length >= 6) s += 0.25;
    if (p.length >= 10) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(p)) s += 0.25;
    String label = '';
    if (s <= 0.25) label = 'Weak';
    else if (s <= 0.5) label = 'Fair';
    else if (s <= 0.75) label = 'Good';
    else label = 'Strong';
    setState(() { _passwordStrength = s; _strengthLabel = p.isEmpty ? '' : label; });
  }

  Color get _strengthColor {
    if (_passwordStrength <= 0.25) return BubblesColors.error;
    if (_passwordStrength <= 0.5) return BubblesColors.warning;
    if (_passwordStrength <= 0.75) return const Color(0xFF6ECBF5);
    return BubblesColors.success;
  }

  Future<void> _signUp() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      if (res.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BgMesh(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleIconBtn(icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
                ]),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      GlassBox(
                        borderRadius: 16, width: 60, height: 60, padding: const EdgeInsets.all(14),
                        child: const Icon(Icons.bubble_chart, color: BubblesColors.primary, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text('Create Account',
                          style: GoogleFonts.manrope(
                            fontSize: 28, fontWeight: FontWeight.w800,
                            color: BubblesColors.textPrimaryDark, letterSpacing: -0.5,
                          )),
                      const SizedBox(height: 6),
                      Text('Join Bubbles to get started',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: BubblesColors.textSecondaryDark,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GlassBox(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppInput(
                        label: 'Email Address',
                        hint: 'name@example.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefix: Icon(Icons.mail_outline, size: 18, color: BubblesColors.textMutedDark),
                      ),
                      const SizedBox(height: 20),
                      AppInput(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        prefix: Icon(Icons.lock_outline, size: 18, color: BubblesColors.textMutedDark),
                      ),
                      if (_strengthLabel.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: _passwordStrength,
                                minHeight: 4,
                                backgroundColor: BubblesColors.glassDark,
                                valueColor: AlwaysStoppedAnimation(_strengthColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(_strengthLabel,
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: _strengthColor,
                              )),
                        ]),
                      ],
                      const SizedBox(height: 20),
                      AppInput(
                        label: 'Confirm Password',
                        hint: '••••••••',
                        controller: _confirmCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _signUp,
                        prefix: Icon(Icons.lock_outline, size: 18, color: BubblesColors.textMutedDark),
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
                          child: Text(_error!, style: TextStyle(color: BubblesColors.error, fontSize: 12)),
                        ),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Create Account',
                        onPressed: _signUp,
                        loading: _loading,
                        fullWidth: true,
                        trailingIcon: Icons.arrow_forward,
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        const Expanded(child: Divider(color: Color(0x14FFFFFF))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR',
                              style: GoogleFonts.manrope(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: BubblesColors.textMutedDark, letterSpacing: 1.5,
                              )),
                        ),
                        const Expanded(child: Divider(color: Color(0x14FFFFFF))),
                      ]),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {},
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
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Already have an account? ',
                          style: TextStyle(color: BubblesColors.textSecondaryDark, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Log In',
                            style: GoogleFonts.manrope(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: BubblesColors.primary,
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
