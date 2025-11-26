import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Widget _buildConnectionBadge(ConnectionStatus status) {
    Color color;
    String text;
    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.greenAccent;
        text = "Online";
        break;
      case ConnectionStatus.connecting:
        color = Colors.orangeAccent;
        text = "Checking...";
        break;
      default:
        color = Colors.redAccent;
        text = "Offline";
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = userData?['full_name'] ?? currentUser?.userMetadata?['full_name'] ?? 'Guest';
    final email = currentUser?.email ?? '';
    final photoUrl = userData?['avatar_url'] ?? currentUser?.userMetadata?['avatar_url'];

    return Consumer<ConnectionService>(
      builder: (context, conn, _) {
        return Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email),
                    _buildConnectionBadge(conn.status),
                  ],
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 24)) : null,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.mic_rounded),
                title: const Text('Live Wingman'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/new-session');
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_rounded),
                title: const Text('Consultant'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/consultant');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.link_rounded),
                title: const Text('Connections'),
                subtitle: Text(conn.isConnected ? "Connected" : "Setup Server"),
                trailing: conn.isConnected 
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 16) 
                    : const Icon(Icons.warning, color: Colors.orange, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/connections');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: onLogout,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }
}