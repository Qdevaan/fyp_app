import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Fetch profile using the existing service method
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

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = _profile?['full_name'] ?? 'Guest';
    final avatarUrl = _profile?['avatar_url'] ?? user?.userMetadata?['avatar_url'];

    return Scaffold(
      // 1. Add the AppDrawer
      drawer: AppDrawer(
        currentUser: user,
        userData: _profile,
        onLogout: _logout,
      ),
      appBar: AppBar(
        title: const Text(
          "Bubbles",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // 2. Replace leading icon with Profile Avatar that opens Drawer
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              borderRadius: BorderRadius.circular(50),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant)
                    : null,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Section
                  Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. Feature Cards (Navigation)
                  _buildFeatureCard(
                    context,
                    title: "Live Wingman",
                    subtitle: "Real-time conversation assistance",
                    icon: Icons.mic_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    route: '/new-session',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: "Consultant AI",
                    subtitle: "Ask questions about past chats",
                    icon: Icons.smart_toy_rounded,
                    color: Colors.deepPurpleAccent,
                    route: '/consultant',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: "History",
                    subtitle: "View past session logs",
                    icon: Icons.history_rounded,
                    color: Colors.orangeAccent,
                    route: '/sessions',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}