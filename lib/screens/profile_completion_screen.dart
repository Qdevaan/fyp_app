import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import 'home_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameCtrl.text.trim()}));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (_) {
      setState(() => _error = 'Failed to save profile. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BgMesh(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete Profile',
                    style: GoogleFonts.manrope(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: BubblesColors.textPrimaryDark, letterSpacing: -0.5,
                    )),
                const SizedBox(height: 6),
                Text('Tell us a bit about yourself to personalize your experience.',
                    style: GoogleFonts.manrope(
                      fontSize: 13, color: BubblesColors.textSecondaryDark, height: 1.5,
                    )),
                const SizedBox(height: 32),
                // Avatar picker
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      children: [
                        Container(
                          width: 110, height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BubblesColors.glassDark,
                            border: Border.all(
                              color: BubblesColors.primary.withOpacity(0.4), width: 2),
                          ),
                          child: const Icon(Icons.person, color: BubblesColors.textMutedDark, size: 48),
                        ),
                        Positioned(
                          right: 0, bottom: 0,
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BubblesColors.primary,
                              border: Border.all(color: BubblesColors.bgDark, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: BubblesColors.bgDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GlassBox(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      AppInput(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        prefix: Icon(Icons.person_outline, size: 18, color: BubblesColors.textMutedDark),
                      ),
                      const SizedBox(height: 20),
                      AppInput(
                        label: 'Date of Birth',
                        hint: 'Select date',
                        prefix: Icon(Icons.calendar_today_outlined, size: 18, color: BubblesColors.textMutedDark),
                      ),
                      const SizedBox(height: 20),
                      AppInput(
                        label: 'Country',
                        hint: 'Select country',
                        prefix: Icon(Icons.language, size: 18, color: BubblesColors.textMutedDark),
                      ),
                    ],
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
                    child: Text(_error!, style: TextStyle(color: BubblesColors.error, fontSize: 12)),
                  ),
                ],
                const SizedBox(height: 28),
                AppButton(
                  label: 'Save & Continue',
                  onPressed: _save,
                  loading: _loading,
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen())),
                    child: Text('Skip for now',
                        style: GoogleFonts.manrope(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: BubblesColors.textSecondaryDark,
                        )),
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
