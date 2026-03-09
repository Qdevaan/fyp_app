import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _progressValue;

  String _status = 'Initializing...';
  final _statuses = [
    'Initializing...',
    'Connecting...',
    'Loading assets...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)));
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _progressCtrl.forward();
      _cycleStatus();
    });
    _progressCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _navigate();
    });
  }

  void _cycleStatus() {
    for (int i = 0; i < _statuses.length; i++) {
      Future.delayed(Duration(milliseconds: 600 * i), () {
        if (mounted) setState(() => _status = _statuses[i]);
      });
    }
  }

  void _navigate() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BgMesh(
        child: SafeArea(
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _LogoDisc(),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Status + progress
                AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) => Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _status,
                          key: ValueKey(_status),
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: BubblesColors.textPrimaryDark,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'BUBBLE ENGINE v2.0',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: BubblesColors.primary.withOpacity(0.7),
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Column(
                          children: [
                            GlassBox(
                              borderRadius: 999,
                              height: 6,
                              child: FractionallySizedBox(
                                widthFactor: _progressValue.value,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: const LinearGradient(
                                      colors: [BubblesColors.primary, Color(0xFF818CF8), Color(0xFF14B8A6)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: BubblesColors.primary.withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(_progressValue.value * 100).round()}% COMPLETE',
                                  style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500,
                                    color: BubblesColors.textMutedDark, letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'VERIFYING...',
                                  style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500,
                                    color: BubblesColors.textMutedDark, letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                // Secure connection badge
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: GlassBox(
                    borderRadius: 999,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2DD4BF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure Connection Established',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500,
                            color: BubblesColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoDisc extends StatefulWidget {
  @override
  State<_LogoDisc> createState() => _LogoDiscState();
}

class _LogoDiscState extends State<_LogoDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathCtrl;
  late Animation<double> _breathScale;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _breathScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _breathCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathCtrl,
      builder: (_, __) => Transform.scale(
        scale: _breathScale.value,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BubblesColors.primary.withOpacity(0.12),
              ),
            ),
            // Glass disc
            GlassBox(
              width: 120, height: 120,
              borderRadius: 999,
              child: Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BubblesColors.primary.withOpacity(0.2),
                    border: Border.all(color: BubblesColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.bubble_chart,
                    color: BubblesColors.primary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
