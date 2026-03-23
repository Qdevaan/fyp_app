import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../utils/permissions_util.dart';
import '../widgets/glass_morphism.dart';

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

  Future<void> _startInitialization() async {
    try {
      // Short delay to let the UI render first
      await Future.delayed(AppDurations.normal);

      if (mounted) {
        setState(() {
          _progress = 0.3;
          _loadingText = 'Loading...';
        });
      }

      if (mounted) {
        setState(() {
          _progress = 0.6;
          _loadingText = 'Connecting...';
        });
      }
      
      try {
        await _checkConnectivity();
      } catch (e) {
        debugPrint('Connectivity error: $e');
      }

      if (mounted) {
        setState(() {
          _progress = 0.8;
        });
      }
      
      try {
        await _determineAuthState();
      } catch (e) {
        debugPrint('Auth error: $e');
        _targetRoute = '/login';
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      _targetRoute ??= '/login';
    } finally {
      if (mounted) {
        setState(() {
          _progress = 1.0;
        });
        
        // Failsafe in case animation callback doesn't fire
        Future.delayed(AppDurations.normal, () {
          if (mounted && !_hasNavigated) {
            _onLoadingComplete();
          }
        });
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final hasConnection = !results.contains(ConnectivityResult.none);

    if (!hasConnection && mounted) {
      await _showSettingsDialog(
        title: 'No Connectivity',
        message:
            'Internet is not available. Please enable Wi-Fi or mobile data.',
      );
    }
  }

  Future<void> _determineAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final profile = await AuthService.instance.getProfile();
      final isComplete = profile != null && (profile['full_name']?.toString().isNotEmpty ?? false);

      if (mounted) {
        await PermissionsUtil.requestStartupPermissions(context);
      }

      _targetRoute = isComplete ? '/home' : '/profile-completion';
    } else {
      _targetRoute = '/login';
    }

    // Simulate extra loading time for visual effect (optional)
    await Future.delayed(AppDurations.normal);
  }

  void _onLoadingComplete() {
    if (!mounted || _targetRoute == null || _hasNavigated) return;

    _hasNavigated = true;
    // Once the bar finishes filling to 1.0, navigate
    Navigator.of(context).pushReplacementNamed(_targetRoute!);
  }

  Future<void> _showSettingsDialog({
    required String title,
    required String message,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GlassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(51)),
                        ),
                        child: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.slate400 : AppColors.slate500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await openAppSettings();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(38),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: Text(
                          'Open Settings',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Mesh gradient background
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
              ),
            ),
          ],
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with glow
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withAlpha(38),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Image.asset(logoPath, width: 112, height: 112),
                ),
                const SizedBox(height: 32),
                Text(
                  'BUBBLES',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 8,
                    color: isDark ? Colors.white : AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: _progress),
                      duration: AppDurations.normal,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 3,
                          backgroundColor: isDark
                              ? AppColors.glassBorder
                              : AppColors.slate200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                      onEnd: () {
                        if (_progress >= 1.0) {
                          _onLoadingComplete();
                        }
                      },
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
