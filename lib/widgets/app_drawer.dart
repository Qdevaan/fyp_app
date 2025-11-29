import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/connection_service.dart';
import '../services/auth_service.dart';
import '../theme/design_tokens.dart';

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
    final theme = Theme.of(context);
    final name = userData?['full_name'] ?? currentUser?.userMetadata?['full_name'] ?? 'Guest';
    final email = currentUser?.email ?? '';
    final photoUrl = userData?['avatar_url'] ?? currentUser?.userMetadata?['avatar_url'];

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          Consumer<ConnectionService>(
            builder: (context, conn, _) => _buildHeader(context, name, email, photoUrl, conn.status),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              children: [
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                _DrawerItem(
                  icon: Icons.mic_rounded,
                  label: 'Live Wingman',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/new-session');
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                _DrawerItem(
                  icon: Icons.chat_rounded,
                  label: 'Consultant',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/consultant');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Divider(height: 1),
                ),
                const SizedBox(height: AppSpacing.md),
                Consumer<ConnectionService>(
                  builder: (context, conn, _) => _DrawerItem(
                    icon: Icons.link_rounded,
                    label: 'Connections',
                    subtitle: conn.isConnected ? "Connected" : "Setup Server",
                    trailing: conn.isConnected 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 16) 
                        : const Icon(Icons.warning, color: Colors.orange, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/connections');
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email, String? photoUrl, ConnectionStatus status) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final foregroundColor = appBarTheme.foregroundColor ?? Colors.white;
    
    Color statusColor;
    String statusText;
    switch (status) {
      case ConnectionStatus.connected:
        statusColor = Colors.greenAccent;
        statusText = "Online";
        break;
      case ConnectionStatus.connecting:
        statusColor = Colors.orangeAccent;
        statusText = "Connecting...";
        break;
      default:
        statusColor = Colors.redAccent;
        statusText = "Offline";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 60, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: appBarTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: foregroundColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                  backgroundColor: foregroundColor.withOpacity(0.2),
                  child: photoUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: foregroundColor,
                          ),
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
                    border: Border.all(color: appBarTheme.backgroundColor ?? theme.primaryColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: foregroundColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foregroundColor.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
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