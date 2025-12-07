import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/connection_service.dart';
import 'services/api_service.dart';
import 'services/livekit_service.dart';
import 'services/deepgram_service.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connections_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/profile_completion_screen.dart';
import 'screens/consultant_screen.dart';
import 'screens/sessions_screen.dart';
import 'screens/new_session_screen.dart';
import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';
// import 'screens/progress_screen.dart';
// import 'screens/notifications_screen.dart';
// import 'screens/voice_enrollment_screen.dart';
import 'screens/splash_screen.dart';
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
    return MultiProvider(
      providers: [
        // 1. Connection Service (Base)
        ChangeNotifierProvider(create: (context) => ConnectionService()),
        
        // 2. API Service (Depends on ConnectionService)
        ProxyProvider<ConnectionService, ApiService>(
          update: (context, connection, previous) => ApiService(connection),
        ),

        // 3. LiveKit Service (Depends on ApiService)
        ChangeNotifierProxyProvider<ApiService, LiveKitService>(
          create: (context) => LiveKitService(Provider.of<ApiService>(context, listen: false)),
          update: (context, api, previous) => LiveKitService(api),
        ),

        // 4. Theme Provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // 5. Deepgram Service
        ChangeNotifierProvider(create: (context) => DeepgramService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bubbles',
            
            // Theme Mode: Follows system settings (Light/Dark)
            themeMode: ThemeMode.system,
            
            // Light Theme Configuration
            theme: themeProvider.lightTheme.copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                },
              ),
            ),
            
            // Dark Theme Configuration
            darkTheme: themeProvider.darkTheme.copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                },
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
              '/new-session': (context) => const NewSessionScreen(),
              '/consultant': (context) => const ConsultantScreen(),
              '/sessions': (context) => const SessionsScreen(),
              // '/progress': (context) => const ProgressScreen(),
              // '/notifications': (context) => const NotificationsScreen(),
              '/about': (context) => const AboutScreen(),
              '/settings': (context) => const SettingsScreen(),
              // '/enroll-voice': (context) => const VoiceEnrollmentScreen(),
            },
          );
        },
      ),
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
  bool _minSplashPassed = false;

  @override
  void initState() {
    super.initState();
    // Ensure splash screen is visible for at least 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _minSplashPassed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show splash screen if:
        // 1. Minimum time hasn't passed OR
        // 2. Auth state is still loading
        if (!_minSplashPassed || snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); 
        }
        
        final session = snapshot.data?.session;

        if (session != null) {
          return const HomeScreen(); 
        } else {
          return const LoginScreen(); 
        }
      },
    );
  }
}