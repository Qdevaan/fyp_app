import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/connection_service.dart';
import 'connections_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await AuthService.instance.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // --- CONNECTION STATUS HEADER ---
          Consumer<ConnectionService>(
            builder: (context, conn, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: conn.isConnected ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: conn.isConnected ? Colors.green : Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(conn.isConnected ? Icons.cloud_done : Icons.cloud_off, 
                         color: conn.isConnected ? Colors.green : Colors.orange, size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(conn.isConnected ? "Brain Connected" : "Brain Disconnected", 
                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (!conn.isConnected)
                            const Text("Connect to Colab to use AI features.", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    if (!conn.isConnected)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConnectionsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12)
                        ),
                        child: const Text("Connect"),
                      )
                  ],
                ),
              );
            }
          ),

          const Divider(height: 32),

          _buildSectionHeader(theme, title: 'Account'),
          _SettingsTile(
            context: context,
            icon: Icons.person_outline,
            title: 'Profile Settings',
            subtitle: 'Update your name, photo, and details',
            onTap: () => Navigator.pushNamed(context, '/profile-completion'),
          ),
          // --- 1. Add Voice Enrollment Tile ---
          _SettingsTile(
            context: context,
            icon: Icons.record_voice_over_outlined, // Appropriate icon
            title: 'Update Voice Print',
            subtitle: 'Re-record your voice for identification',
            onTap: () {
              // Navigate to the enrollment screen, possibly passing an argument
              Navigator.pushNamed(
                context,
                '/enroll-voice',
                arguments: {'isUpdate': true},
              );
            },
          ),
          _SettingsTile(
            context: context,
            icon: Icons.link_outlined,
            title: 'Connection Settings',
            subtitle: 'Manage PC server connection', // Updated subtitle
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectionsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, title: 'General'),
          _SettingsTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Customize your alert preferences',
            onTap: () => _showComingSoon(context, 'Notification settings'),
          ),
          _SettingsTile(
            context: context,
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            subtitle: 'Manage how your data is used',
            onTap: () => _showComingSoon(context, 'Privacy screen'),
          ),
          _SettingsTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Find answers and get help',
            onTap: () => _showComingSoon(context, 'Help screen'),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isLoggingOut
                ? const Center(child: CircularProgressIndicator())
                : TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      foregroundColor: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.errorContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _logout,
                  ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The $feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, {required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.context,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.secondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: theme.textTheme.bodySmall?.color),
      ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}