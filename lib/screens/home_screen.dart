import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_button.dart';
import 'consultant_screen.dart';
import 'session_history_screen.dart';
import 'settings_screen.dart';
import 'new_session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIdx = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _userName {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta?['full_name']?.toString().split(' ').first ?? 'there';
  }

  void _onNavTap(int i) {
    if (i == _navIdx) return;
    switch (i) {
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConsultantScreen()));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SessionHistoryScreen()));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      default:
        setState(() => _navIdx = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BubblesColors.bgDark,
      body: BgMesh(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BubblesBottomNav(currentIndex: 0, onTap: _onNavTap),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BubblesColors.glassDark,
                border: Border.all(color: BubblesColors.primary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.person, color: BubblesColors.textSecondaryDark, size: 22),
            ),
          ),
          const Spacer(),
          // Notifications
          GestureDetector(
            onTap: () => _showNotifications(),
            child: GlassBox(
              borderRadius: 999, width: 42, height: 42,
              child: const Icon(Icons.notifications_outlined, color: BubblesColors.textSecondaryDark, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Greeting
          Text(
            '$_greeting,',
            style: GoogleFonts.manrope(
              fontSize: 14, fontWeight: FontWeight.w400,
              color: BubblesColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$_userName.',
                  style: GoogleFonts.manrope(
                    fontSize: 32, fontWeight: FontWeight.w800,
                    color: BubblesColors.primary, letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('Take a moment for yourself.',
              style: GoogleFonts.manrope(
                fontSize: 15, color: BubblesColors.textSecondaryDark,
              )),
          const SizedBox(height: 32),
          // Quick Actions label
          Text('QUICK ACTIONS',
              style: GoogleFonts.manrope(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: BubblesColors.textMutedDark, letterSpacing: 1.5,
              )),
          const SizedBox(height: 14),
          // Start Session card
          GlassBox(
            borderRadius: 16,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Wingman Session',
                          style: GoogleFonts.manrope(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: BubblesColors.textPrimaryDark,
                          )),
                      const SizedBox(height: 4),
                      Text('Real-time conversation coaching',
                          style: GoogleFonts.manrope(
                            fontSize: 13, color: BubblesColors.textSecondaryDark,
                          )),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewSessionScreen())),
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BubblesColors.primary,
                            boxShadow: [
                              BoxShadow(color: BubblesColors.primary.withOpacity(0.4), blurRadius: 12),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow, color: BubblesColors.bgDark, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 90, height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [BubblesColors.primary.withOpacity(0.3), BubblesColors.primaryDark.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.graphic_eq, color: BubblesColors.primary, size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Small tiles grid
          Row(
            children: [
              Expanded(
                child: GlassBox(
                  borderRadius: 16, padding: const EdgeInsets.all(18),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ConsultantScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: BubblesColors.primary.withOpacity(0.15),
                        ),
                        child: const Icon(Icons.psychology_outlined, color: BubblesColors.primary, size: 22),
                      ),
                      const SizedBox(height: 12),
                      Text('AI Consult',
                          style: GoogleFonts.manrope(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: BubblesColors.textPrimaryDark,
                          )),
                      Text('Strategy chat', style: TextStyle(fontSize: 11, color: BubblesColors.textMutedDark)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassBox(
                  borderRadius: 16, padding: const EdgeInsets.all(18),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SessionHistoryScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0x1A64748B),
                        ),
                        child: const Icon(Icons.history, color: BubblesColors.textSecondaryDark, size: 22),
                      ),
                      const SizedBox(height: 12),
                      Text('History',
                          style: GoogleFonts.manrope(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: BubblesColors.textPrimaryDark,
                          )),
                      Text('Past sessions', style: TextStyle(fontSize: 11, color: BubblesColors.textMutedDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress section
          Text('YOUR PROGRESS',
              style: GoogleFonts.manrope(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: BubblesColors.textMutedDark, letterSpacing: 1.5,
              )),
          const SizedBox(height: 12),
          GlassBox(
            borderRadius: 14, padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: 0.67,
                          minHeight: 6,
                          backgroundColor: BubblesColors.glassDark,
                          valueColor: const AlwaysStoppedAnimation(BubblesColors.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('4 of 6 daily goals reached',
                          style: TextStyle(fontSize: 12, color: BubblesColors.textMutedDark)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text('67%',
                    style: GoogleFonts.manrope(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: BubblesColors.primary,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsSheet(),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: BubblesColors.glassHeaderDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: BubblesColors.glassBorderDark)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: BubblesColors.textMutedDark.withOpacity(0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Notifications',
                    style: GoogleFonts.manrope(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: BubblesColors.textPrimaryDark,
                    )),
                const Spacer(),
                Text('Clear All',
                    style: TextStyle(fontSize: 13, color: BubblesColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _NotifTile(
                  icon: Icons.bubble_chart,
                  iconColor: BubblesColors.primary,
                  title: 'New AI Insight',
                  subtitle: 'Your weekly communication analysis is ready.',
                  time: '2m ago',
                ),
                _NotifTile(
                  icon: Icons.check_circle_outline,
                  iconColor: BubblesColors.success,
                  title: 'Session Complete',
                  subtitle: 'Great work on your networking session!',
                  time: '1h ago',
                ),
                _NotifTile(
                  icon: Icons.update,
                  iconColor: BubblesColors.warning,
                  title: 'App Updated',
                  subtitle: 'Bubbles v2.4 is now installed.',
                  time: 'Yesterday',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotifTile({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle, required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassBox(
        borderRadius: 14, padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: iconColor.withOpacity(0.15),
                border: Border.all(color: iconColor.withOpacity(0.3)),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.manrope(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: BubblesColors.textPrimaryDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: BubblesColors.textSecondaryDark)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: BubblesColors.textMutedDark, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}
