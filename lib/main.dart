import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_completion_screen.dart';

// Supabase Configuration
// TODO: For production, consider moving these to --dart-define or a .env file
const String SUPABASE_URL = 'https://czjwoqwbwtojlypbzupi.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6andvcXdid3Rvamx5cGJ6dXBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwMDMxODksImV4cCI6MjA3OTU3OTE4OX0.JXBfOGI_rVumZj9qBwxXguW_6hffjdvrhnly37K3kwM';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(const BubblesApp());
}

class BubblesApp extends StatelessWidget {
  const BubblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the seed color for consistent branding
    const seedColor = Colors.blueAccent;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bubbles',
      
      // Theme Mode: Follows system settings (Light/Dark)
      themeMode: ThemeMode.system,
      
      // Light Theme Configuration
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
      
      // Dark Theme Configuration
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

      // The AuthGate manages the root state (Splash -> Login -> App)
      home: const AuthGate(),
      
      // Routes for manual navigation
      routes: {
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
/// Dynamically switches between Loading, Login, Profile Setup, and Home.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = Supabase.instance.client;
  
  // State variables
  bool _isLoading = true;
  bool _isProfileComplete = false;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Check current session immediately on app start
    final initialSession = _supabase.auth.currentSession;
    
    if (initialSession != null) {
      _session = initialSession;
      // If we have a session, we must check if the profile is complete
      await _checkProfile(); 
    } else {
      // No session, stop loading so we can show LoginScreen
      if (mounted) {
        setState(() {
          _isLoading = false;
          _session = null;
        });
      }
    }

    // 2. Listen for auth changes (Login, Logout, Deep Links)
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (!mounted) return;

      setState(() => _session = session);

      if (session != null) {
        // If user just signed in, check their profile status
        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
          _checkProfile();
        } 
        // Note: We ignore tokenRefreshed events to prevent unnecessary reloads
      } else {
        // User logged out
        setState(() {
          _isLoading = false;
          _isProfileComplete = false;
        });
      }
    });
  }

  /// Checks if the user has a valid profile in the database.
  /// If not, forces them to the completion screen.
  Future<void> _checkProfile() async {
    if (!mounted) return;
    
    // Show splash while checking
    setState(() => _isLoading = true);

    try {
      // AuthService handles local caching now, so this is fast
      final profile = await AuthService.instance.getProfile();
      
      if (!mounted) return;

      // Logic: A profile is complete if it exists and has a Full Name
      bool isComplete = profile != null && 
                        profile['full_name'] != null && 
                        profile['full_name'].toString().isNotEmpty;

      setState(() {
        _isProfileComplete = isComplete;
        _isLoading = false;
      });
      
    } catch (e) {
      // If error (e.g. network issue), default to incomplete to be safe
      // or stop loading to let user retry via UI interactions
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProfileComplete = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. SHOW SPLASH SCREEN WHILE LOADING/CHECKING
    if (_isLoading) {
      return const SplashScreen();
    }

    // 2. Unauthenticated -> Login
    if (_session == null) {
      return const LoginScreen();
    }

    // 3. Authenticated but Incomplete Profile -> Setup
    if (!_isProfileComplete) {
      return const ProfileCompletionScreen();
    }

    // 4. Authenticated & Complete -> Home
    return const HomeScreen();
  }
}