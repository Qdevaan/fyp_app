import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/connection_service.dart';
import 'services/api_service.dart';
import 'services/livekit_service.dart';
import 'services/deepgram_service.dart';
import 'services/voice_assistant_service.dart';
import 'services/wake_word_service.dart';
import 'providers/theme_provider.dart';
import 'providers/consultant_provider.dart';
import 'providers/session_provider.dart';
import 'providers/home_provider.dart';
import 'widgets/voice_overlay.dart';
import 'screens/splash_screen.dart';
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
import 'screens/entity_screen.dart';
import 'screens/session_history_screen.dart';
import 'screens/ai_insights_dashboard_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/expanded_user_profile_screen.dart';
import 'screens/search_discovery_screen.dart';
import 'widgets/auth_guard.dart';
import 'routes/app_routes.dart';

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
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
          create: (context) =>
              LiveKitService(Provider.of<ApiService>(context, listen: false)),
          update: (context, api, previous) => previous!..updateApiService(api),
        ),

        // 4. Theme Provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // 5. Deepgram Service
        ChangeNotifierProvider(create: (context) => DeepgramService()),

        // 6. Wake Word Service (Porcupine)
        ChangeNotifierProvider(create: (context) => WakeWordService()),

        // 7. Voice Assistant Service (depends on Connection + WakeWord)
        ChangeNotifierProxyProvider2<
          ConnectionService,
          WakeWordService,
          VoiceAssistantService
        >(
          create: (context) => VoiceAssistantService(
            Provider.of<ConnectionService>(context, listen: false),
            Provider.of<WakeWordService>(context, listen: false),
          ),
          update: (context, connection, wakeWord, previous) => previous!,
        ),

        // 8. Consultant Provider (chat state)
        ChangeNotifierProvider(create: (_) => ConsultantProvider()),

        // 9. Session Provider (live wingman state)
        ChangeNotifierProvider(create: (_) => SessionProvider()),

        // 10. Home Provider (home screen data)
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: BubblesApp.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Bubbles',

            // Theme Mode: Follows stored settings (System/Light/Dark)
            themeMode: themeProvider.themeMode,

            // Light Theme Configuration
            theme: themeProvider.lightTheme,

            // Dark Theme Configuration
            darkTheme: themeProvider.darkTheme,

            // The root screen
            home: const SplashScreen(),

            // Global builder: adds VoiceOverlay on all routes except /settings
            builder: (context, child) {
              return _VoiceOverlayWrapper(child: child ?? const SizedBox());
            },

            // Custom routes with animations for specific ones
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.settings) {
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SettingsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0); // Slide from left
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                );
              } else if (settings.name == AppRoutes.entities) {
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const EntityScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // Slide from right
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                );
              }
              return null; // Let the 'routes' map handle the rest
            },

            // Routes for manual navigation
            routes: {
              AppRoutes.login: (context) =>
                  const AuthGuard(requireAuth: false, child: LoginScreen()),
              AppRoutes.signup: (context) =>
                  const AuthGuard(requireAuth: false, child: SignupScreen()),
              AppRoutes.verifyEmail: (context) => const AuthGuard(
                requireAuth: false,
                child: VerifyEmailScreen(),
              ),
              AppRoutes.profileCompletion: (context) =>
                  const AuthGuard(child: ProfileCompletionScreen()),
              AppRoutes.home: (context) => const AuthGuard(child: HomeScreen()),
              AppRoutes.connections: (context) =>
                  const AuthGuard(child: ConnectionsScreen()),
              AppRoutes.newSession: (context) =>
                  const AuthGuard(child: NewSessionScreen()),
              AppRoutes.consultant: (context) =>
                  const AuthGuard(child: ConsultantScreen()),
              AppRoutes.sessions: (context) =>
                  const AuthGuard(child: SessionsScreen()),
              AppRoutes.about: (context) =>
                  const AuthGuard(child: AboutScreen()),
              AppRoutes.sessionHistory: (context) =>
                  const AuthGuard(child: SessionHistoryScreen()),
              AppRoutes.aiInsights: (context) =>
                  const AuthGuard(child: AiInsightsDashboardScreen()),
              AppRoutes.subscription: (context) =>
                  const AuthGuard(child: SubscriptionScreen()),
              AppRoutes.profile: (context) =>
                  const AuthGuard(child: ExpandedUserProfileScreen()),
              AppRoutes.search: (context) =>
                  const AuthGuard(child: SearchDiscoveryScreen()),
            },
          );
        },
      ),
    );
  }
}

/// Wrapper that adds VoiceOverlay on top of all screens when voice is active.
class _VoiceOverlayWrapper extends StatelessWidget {
  final Widget child;
  const _VoiceOverlayWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceAssistantService>();
    final stateStr = (() {
      switch (voice.state) {
        case VoiceAssistantState.processing: return 'thinking';
        case VoiceAssistantState.speaking: return 'speaking';
        default: return 'listening';
      }
    })();
    return Stack(
      children: [
        child,
        if (voice.isOverlayVisible)
          Positioned.fill(
            child: VoiceOverlay(
              state: stateStr,
              transcript: voice.partialText.isNotEmpty ? voice.partialText : null,
              response: voice.lastResponse.isNotEmpty ? voice.lastResponse : null,
              onDismiss: voice.hideOverlay,
            ),
          ),
      ],
    );
  }
}

/// The Gatekeeper Widget
/// Dynamically switches between Login and Home based on auth state.
