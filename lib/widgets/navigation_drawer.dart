import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';

class BubblesNavigationDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onNavigate;

  const BubblesNavigationDrawer({
    super.key,
    this.currentIndex = 0,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'User') as String;
    final email = user?.email ?? '';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF101e22), Color(0xFF0d313b)],
          ),
          border: Border(right: BorderSide(color: Color(0x1A13BDEC))),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildUserHeader(name, email, avatarUrl, context),
              const Divider(color: BubblesColors.glassBorderDark),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.home_outlined,
                      label: 'Home',
                      index: 0,
                      current: currentIndex == 0,
                      onTap: () => _navigate(context, 0),
                    ),
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'AI Consultant',
                      index: 1,
                      current: currentIndex == 1,
                      onTap: () => _navigate(context, 1),
                    ),
                    _DrawerItem(
                      icon: Icons.history_outlined,
                      label: 'Sessions',
                      index: 2,
                      current: currentIndex == 2,
                      onTap: () => _navigate(context, 2),
                    ),
                    _DrawerItem(
                      icon: Icons.cable_outlined,
                      label: 'Connections',
                      index: 3,
                      current: currentIndex == 3,
                      onTap: () => _navigate(context, 3),
                    ),
                    _DrawerItem(
                      icon: Icons.insights_outlined,
                      label: 'AI Insights',
                      index: 5,
                      current: currentIndex == 5,
                      onTap: () => _navigate(context, 5),
                    ),
                    _DrawerItem(
                      icon: Icons.account_tree_outlined,
                      label: 'Knowledge Graph',
                      index: 6,
                      current: currentIndex == 6,
                      onTap: () => _navigate(context, 6),
                    ),
                    _DrawerItem(
                      icon: Icons.search,
                      label: 'Search',
                      index: 7,
                      current: currentIndex == 7,
                      onTap: () => _navigate(context, 7),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Divider(color: BubblesColors.glassBorderDark),
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      index: 8,
                      current: currentIndex == 8,
                      onTap: () => _navigate(context, 8),
                    ),
                    _DrawerItem(
                      icon: Icons.info_outline,
                      label: 'About',
                      index: 9,
                      current: currentIndex == 9,
                      onTap: () => _navigate(context, 9),
                    ),
                  ],
                ),
              ),
              _buildVersion(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(String name, String email, String? avatarUrl, BuildContext ctx) {
    return GestureDetector(
      onTap: () => _navigate(ctx, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: BubblesColors.primary.withOpacity(0.2),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: GoogleFonts.manrope(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: BubblesColors.primary,
                      ))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.manrope(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: BubblesColors.textPrimaryDark,
                  )),
                  Text(email, style: TextStyle(
                    fontSize: 11, color: BubblesColors.textSecondaryDark,
                  ), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: BubblesColors.textMutedDark, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Bubbles v1.0.0-beta', style: TextStyle(
        fontSize: 10, color: BubblesColors.textMutedDark,
      )),
    );
  }

  void _navigate(BuildContext context, int index) {
    Navigator.of(context).pop();
    onNavigate?.call(index);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool current;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon, required this.label, required this.index,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon,
        color: current ? BubblesColors.primary : BubblesColors.textSecondaryDark,
        size: 22,
      ),
      title: Text(label, style: GoogleFonts.manrope(
        fontSize: 14, fontWeight: current ? FontWeight.w700 : FontWeight.w500,
        color: current ? BubblesColors.primary : BubblesColors.textPrimaryDark,
      )),
      tileColor: current ? BubblesColors.glassPrimary : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
