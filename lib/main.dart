import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/connection_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connections_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/profile_completion_screen.dart';
// import 'screens/consultant_screen.dart';
// import 'screens/sessions_screen.dart';
// import 'screens/new_session_screen.dart';
// import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';
// import 'screens/progress_screen.dart';
// import 'screens/notifications_screen.dart';
// import 'screens/voice_enrollment_screen.dart';
// import 'theme/theme_data.dart';

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

    return MultiProvider(
      providers: [
        // 1. Connection Service (Base)
        ChangeNotifierProvider(create: (context) => ConnectionService()),
        
        // 2. API Service (Depends on ConnectionService)
        ProxyProvider<ConnectionService, ApiService>(
          update: (context, connection, previous) => ApiService(connection),
        ),
      ],
      child: MaterialApp(
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
          '/connections': (context) => const ConnectionsScreen(),
          // '/new-session': (context) => const NewSessionScreen(),
          // '/consultant': (context) => const ConsultantScreen(),
          // '/sessions': (context) => const SessionsScreen(),
          // '/progress': (context) => const ProgressScreen(),
          // '/notifications': (context) => const NotificationsScreen(),
          // '/about': (context) => const AboutScreen(),
          '/settings': (context) => const SettingsScreen(),
          // '/enroll-voice': (context) => const VoiceEnrollmentScreen(),
        },
      ),
    );
  }
}

/// The Gatekeeper Widget
/// Dynamically switches between Loading, Login, Profile Setup, and Home.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While checking auth state, show splash screen or loader
        if (snapshot.connectionState == ConnectionState.waiting) {
            // You can return a Splash Screen here if you prefer
            return const Scaffold(body: Center(child: CircularProgressIndicator())); 
        }
        
        final session = snapshot.data?.session;

        if (session != null) {
            // User is logged in, check profile or go to home
            // For simplicity in this gate, we go to Home. 
            // HomeScreen handles profile check internally as per your existing logic.
          return const HomeScreen(); 
        } else {
          return const LoginScreen(); 
        }
      },
    );
  }
}