import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/connection_service.dart';
import 'services/api_service.dart';
import 'services/livekit_service.dart';
import 'services/deepgram_service.dart';
import 'services/voice_assistant_service.dart';
import 'providers/theme_provider.dart';
import 'widgets/voice_overlay.dart';
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
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase using environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

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
        // FIX: Reuse previous instance instead of creating new one on every update
        ChangeNotifierProxyProvider<ApiService, LiveKitService>(
          create: (context) => LiveKitService(Provider.of<ApiService>(context, listen: false)),
          update: (context, api, previous) => previous!..updateApiService(api),
        ),

        // 4. Theme Provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // 5. Deepgram Service
        ChangeNotifierProvider(create: (context) => DeepgramService()),

        // 6. Voice Assistant Service
        ChangeNotifierProxyProvider<ConnectionService, VoiceAssistantService>(
          create: (context) => VoiceAssistantService(
            Provider.of<ConnectionService>(context, listen: false),
          ),
          update: (context, connection, previous) => previous!,
        ),
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

            // Global builder: adds VoiceOverlay on all routes except /settings
            builder: (context, child) {
              return _VoiceOverlayWrapper(child: child ?? const SizedBox());
            },
            
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
              '/about': (context) => const AboutScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Wrapper that adds VoiceOverlay on top of all screens except settings & auth.
class _VoiceOverlayWrapper extends StatelessWidget {
  final Widget child;
  const _VoiceOverlayWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // The overlay manages its own visibility; it hides during settings
        const VoiceOverlay(),
      ],
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