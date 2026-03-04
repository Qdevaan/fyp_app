import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/design_tokens.dart';
import '../services/connection_service.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final User? currentUser;
  final Map<String, dynamic>? userData;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.currentUser,
    required this.userData,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = userData?['full_name'] ?? currentUser?.userMetadata?['full_name'] ?? 'Guest';
    final email = currentUser?.email ?? '';
    final photoUrl = userData?['avatar_url'] ?? currentUser?.userMetadata?['avatar_url'];

    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Consumer<ConnectionService>(
            builder: (context, conn, _) => _buildHeader(context, name, email, photoUrl, conn.status, isDark),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _DrawerItem(icon: Icons.home_rounded, label: 'Home', isDark: isDark, onTap: () => Navigator.pop(context)),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.mic_rounded,
                  label: 'Live Wingman',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/new-session');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.forum_rounded,
                  label: 'Consultant',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/consultant');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sessions');
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200, height: 1),
                ),
                Consumer<ConnectionService>(
                  builder: (context, conn, _) => _DrawerItem(
                    icon: Icons.link_rounded,
                    label: 'Connections',
                    isDark: isDark,
                    trailing: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: conn.isConnected ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/connections');
                    },
                  ),
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
          _buildFooter(context, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email, String? photoUrl, ConnectionStatus status, bool isDark) {
    Color statusColor;
    String statusText;
    switch (status) {
      case ConnectionStatus.connected:
        statusColor = AppColors.success;
        statusText = "Online";
        break;
      case ConnectionStatus.connecting:
        statusColor = AppColors.warning;
        statusText = "Connecting...";
        break;
      default:
        statusColor = AppColors.error;
        statusText = "Offline";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: photoUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F172A), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.manrope(fontSize: 13, color: Colors.white60),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.manrope(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: GestureDetector(
        onTap: onLogout,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.error.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Logout',
                style: GoogleFonts.manrope(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
