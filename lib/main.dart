import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_completion_screen.dart';

// TODO: Replace with your actual Supabase project values
const String SUPABASE_URL = 'https://czjwoqwbwtojlypbzupi.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6andvcXdid3Rvamx5cGJ6dXBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwMDMxODksImV4cCI6MjA3OTU3OTE4OX0.JXBfOGI_rVumZj9qBwxXguW_6hffjdvrhnly37K3kwM';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    // authCallbackUrlHostname is removed in v2; deep linking is handled by the platform config
  );

  runApp(const BubblesApp());
}

class BubblesApp extends StatelessWidget {
  const BubblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a seed color for the system accent
    const seedColor = Colors.blueAccent;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bubbles',
      
      // Theme Mode: System (follows device settings)
      themeMode: ThemeMode.system,
      
      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
        ),
      ),
      
      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
        ),
      ),

      // Routing
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/profile-completion': (context) => const ProfileCompletionScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

/// The Gatekeeper Widget
/// Decides where to send the user based on Auth State and Profile Data.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // 1. Listen for Auth State Changes (Login, Logout, etc.)
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (session != null) {
        // User is authenticated, check their profile
        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
          _checkProfileAndRedirect();
        }
      } else {
        // No session, stop loading and show LoginScreen (via build)
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _checkProfileAndRedirect() async {
    // If we are already loading, keep it that way. 
    // If not, set it to true to show the spinner while we fetch data.
    if (mounted) setState(() => _isLoading = true);

    try {
      // 2. Fetch Profile Data
      final profile = await AuthService.instance.getProfile();

      if (!mounted) return;

      if (profile != null && profile['full_name'] != null && profile['full_name'].toString().isNotEmpty) {
        // Profile exists and is complete -> Go to Home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Profile missing or incomplete -> Go to Completion
        // Note: We use pushReplacementNamed to prevent going back to the loading screen
        Navigator.of(context).pushReplacementNamed('/profile-completion');
      }
    } catch (e) {
      // If error (e.g. network), default to Home or show error.
      // For now, let's assume if we can't fetch profile, we might need to retry or go to home.
      // But safest is to go to completion to fix data.
      Navigator.of(context).pushReplacementNamed('/profile-completion');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // If not loading and no navigation happened, it means we aren't logged in.
    return const LoginScreen();
  }
}