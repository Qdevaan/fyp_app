import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../services/connection_service.dart';
import '../services/voice_assistant_service.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  // Live insights loaded from Supabase
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _highlights = [];
  bool _insightsLoaded = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadInsights();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VoiceAssistantService>(context, listen: false).activate();
    });
  }

  Future<void> _loadProfile() async {
    final data = await AuthService.instance.getProfile();
    if (mounted) {
      setState(() {
        _profile = data;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Future<void> _loadInsights() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final eventsRes = await _supabase
          .from('events')
          .select('title, due_text, description, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      final highlightsRes = await _supabase
          .from('highlights')
          .select('title, body, highlight_type, created_at')
          .eq('user_id', user.id)
          .eq('is_resolved', false)
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _events = List<Map<String, dynamic>>.from(eventsRes);
          _highlights = List<Map<String, dynamic>>.from(highlightsRes);
          _insightsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading insights: $e');
      if (mounted) setState(() => _insightsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = _profile?['full_name'] ?? 'Guest';
    final firstName = name.toString().split(' ').first;
    final avatarUrl = _profile?['avatar_url'] ?? user?.userMetadata?['avatar_url'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // drawer: AppDrawer(
      //   currentUser: user,
      //   userData: _profile,
      //   onLogout: _logout,
      // ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FIXED HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/settings'), // Disabled drawer, go to settings instead
                            child: Consumer<ConnectionService>(
                              builder: (context, conn, _) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: avatarUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: avatarUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) => Container(color: AppColors.surfaceDark),
                                              )
                                            : Container(
                                                color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                                                child: Icon(Icons.person, color: isDark ? Colors.white54 : Colors.grey),
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: conn.isConnected ? AppColors.success : AppColors.error,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        Text(
                          'Bubbles',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Notifications coming soon!"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: Stack(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                                ),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- SCROLLABLE CONTENT ---
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // --- GREETING ---
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: GoogleFonts.manrope(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    height: 1.2,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [Theme.of(context).colorScheme.primary, const Color(0xFF93C5FD)],
                                  ).createShader(bounds),
                                  child: Text(
                                    '$firstName.',
                                    style: GoogleFonts.manrope(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // --- HERO CARD: LIVE WINGMAN ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Consumer<ConnectionService>(
                      builder: (context, connectionService, child) {
                        final isConnected = connectionService.isConnected;
                        return GestureDetector(
                          onTap: () {
                            if (isConnected) {
                              Navigator.pushNamed(context, '/new-session');
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  final isDark = Theme.of(context).brightness == Brightness.dark;
                                  return AlertDialog(
                                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Not Connected',
                                            style: GoogleFonts.manrope(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      'You are not connected to the server. Would you like to connect now?',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        height: 1.5,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          Navigator.pushNamed(context, '/connections');
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Connect',
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              if (isConnected) _PulseDot() else Icon(Icons.circle, color: Colors.redAccent, size: 8),
                                              const SizedBox(width: 8),
                                              Text(
                                                isConnected ? 'STATUS: ACTIVE' : 'STATUS: DISCONNECTED',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: isConnected ? Theme.of(context).colorScheme.primary : Colors.redAccent,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Live Wingman',
                                        style: GoogleFonts.manrope(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.mic, color: Colors.white, size: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Ready to listen. I\'ll provide real-time cues discreetly through your connected device.',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFCBD5E1),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.record_voice_over, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Start Session',
                                            style: GoogleFonts.manrope(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/settings'),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      child: const Icon(Icons.settings, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

                // --- QUICK ACTIONS ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quick Actions',
                          style: GoogleFonts.manrope(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.forum,
                            iconColor: const Color(0xFF818CF8),
                            iconBg: const Color(0xFF818CF8).withOpacity(0.2),
                            title: 'Consultant AI',
                            subtitle: 'Strategy & advice',
                            onTap: () => Navigator.pushNamed(context, '/consultant'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.auto_awesome,
                            iconColor: const Color(0xFF34D399),
                            iconBg: const Color(0xFF34D399).withOpacity(0.2),
                            title: 'History',
                            subtitle: 'Past sessions',
                            onTap: () => Navigator.pushNamed(context, '/sessions'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.hub_rounded,
                            iconColor: const Color(0xFFA78BFA),
                            iconBg: const Color(0xFFA78BFA).withOpacity(0.2),
                            title: 'Knowledge',
                            subtitle: 'People & entities',
                            onTap: () => Navigator.pushNamed(context, '/entities'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.settings_input_component_rounded,
                            iconColor: const Color(0xFF60A5FA),
                            iconBg: const Color(0xFF60A5FA).withOpacity(0.2),
                            title: 'Server',
                            subtitle: 'Connect & scan',
                            onTap: () => Navigator.pushNamed(context, '/connections'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- RECENT INSIGHTS ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Insights',
                          style: GoogleFonts.manrope(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (_insightsLoaded && (_events.isNotEmpty || _highlights.isNotEmpty))
                          GestureDetector(
                            onTap: _loadInsights,
                            child: Icon(Icons.refresh, size: 18,
                                color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
                          ),
                      ],
                    ),
                  ),
                ),

                // Show skeleton / empty state while loading
                if (!_insightsLoaded)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  )
                else if (_events.isEmpty && _highlights.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: _InsightCard(
                        accentColor: Theme.of(context).colorScheme.primary,
                        title: 'No insights yet',
                        badge: 'Waiting',
                        description: 'Start a Wingman session to generate personalized insights, events, and highlights.',
                        isDark: isDark,
                      ),
                    ),
                  )
                else ...[
                  // Events
                  ..._events.map((ev) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: _InsightCard(
                        accentColor: const Color(0xFFF59E0B),
                        title: ev['title'] as String? ?? 'Event',
                        badge: ev['due_text'] as String? ?? 'Event',
                        description: ev['description'] as String? ?? '',
                        isDark: isDark,
                        icon: Icons.event_rounded,
                      ),
                    ),
                  )),
                  // Highlights / conflicts
                  ..._highlights.map((hl) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: _InsightCard(
                        accentColor: const Color(0xFFEF4444),
                        title: hl['title'] as String? ?? 'Highlight',
                        badge: hl['highlight_type'] as String? ?? 'Note',
                        description: hl['body'] as String? ?? '',
                        isDark: isDark,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                  )),
                ],

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// --- WIDGETS ---

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.7, end: 0.0).animate(_controller),
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 2.0).animate(_controller),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String badge;
  final String description;
  final bool isDark;
  final IconData? icon;

  const _InsightCard({
    required this.accentColor,
    required this.title,
    required this.badge,
    required this.description,
    required this.isDark,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[Icon(icon, size: 16, color: accentColor), const SizedBox(width: 6)],
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                badge,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
