import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../services/auth_service.dart';
import '../services/connection_service.dart';
import '../services/voice_assistant_service.dart';
import '../providers/theme_provider.dart';

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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            Navigator.pushNamed(context, '/connections');
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

            _buildSectionHeader(theme, title: 'Appearance'),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return _SettingsTile(
                  context: context,
                  icon: Icons.color_lens_outlined,
                  title: 'Accent Color',
                  subtitle: 'Choose your preferred accent color',
                  trailing: CircleAvatar(
                    backgroundColor: themeProvider.seedColor,
                    radius: 12,
                  ),
                  onTap: () => _showColorPicker(context, themeProvider),
                );
              },
            ),
            
            const Divider(height: 32),

            // ── Voice Assistant Section ──
            _buildSectionHeader(theme, title: 'Voice Assistant'),
            Consumer<VoiceAssistantService>(
              builder: (context, voice, _) {
                return Column(
                  children: [
                    // Wake Word Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListTile(
                        leading: Icon(
                          voice.isWakeWordEnabled ? Icons.hearing_rounded : Icons.hearing_disabled_rounded,
                          color: theme.colorScheme.secondary,
                        ),
                        title: const Text('"Hey Bubbles" Wake Word', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          voice.isWakeWordEnabled ? 'Always listening for wake word' : 'Tap mic to activate',
                          style: TextStyle(color: theme.textTheme.bodySmall?.color),
                        ),
                        trailing: Switch(
                          value: voice.isWakeWordEnabled,
                          onChanged: (val) => voice.setWakeWordEnabled(val),
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Voice Mode Picker
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                            child: Text(
                              'Voice Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _buildVoiceModeCard(
                                context, voice,
                                mode: VoiceMode.male,
                                icon: Icons.man_rounded,
                                label: 'Male',
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 10),
                              _buildVoiceModeCard(
                                context, voice,
                                mode: VoiceMode.female,
                                icon: Icons.woman_rounded,
                                label: 'Female',
                                color: Colors.pinkAccent,
                              ),
                              const SizedBox(width: 10),
                              _buildVoiceModeCard(
                                context, voice,
                                mode: VoiceMode.neutral,
                                icon: Icons.smart_toy_rounded,
                                label: 'Jarvis',
                                color: Colors.tealAccent.shade700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
              icon: Icons.record_voice_over_outlined,
              title: 'Update Voice Print',
              subtitle: 'Re-record your voice for identification',
              onTap: () => _showComingSoon(context, 'Voice enrollment'),
            ),
            _SettingsTile(
              context: context,
              icon: Icons.link_outlined,
              title: 'Connection Settings',
              subtitle: 'Manage PC server connection', // Updated subtitle
              onTap: () => Navigator.pushNamed(context, '/connections'),
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
            const SizedBox(height: 32),
          ],
        ),
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

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Accent Color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Colors.blueAccent,
                Colors.redAccent,
                Colors.greenAccent,
                Colors.orangeAccent,
                Colors.purpleAccent,
                Colors.tealAccent,
                Colors.pinkAccent,
                Colors.amberAccent,
                Colors.indigoAccent,
                Colors.grey,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    themeProvider.setThemeColor(color);
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 20,
                    child: themeProvider.seedColor.value == color.value
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVoiceModeCard(
    BuildContext context,
    VoiceAssistantService voice, {
    required VoiceMode mode,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = voice.voiceMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => voice.setVoiceMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? color.withOpacity(0.15)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? color : theme.colorScheme.onSurfaceVariant, size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle_rounded, color: color, size: 16),
                ),
            ],
          ),
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
  final Widget? trailing;

  const _SettingsTile({
    required this.context,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
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
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }
}