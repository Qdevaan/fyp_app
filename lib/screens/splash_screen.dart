import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  String _loadingText = 'Loading...';
  String? _targetRoute;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // Short delay to let the UI render first
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _progress = 0.3;
        _loadingText = 'Loading...';
      });
    }
    await _requestStartupPermissions();

    if (mounted) {
      setState(() {
        _progress = 0.6;
        _loadingText = 'Connecting...';
      });
    }
    await _checkConnectivity();

    if (mounted) {
      setState(() {
        _progress = 0.8;
      });
    }
    await _determineAuthState();

    if (mounted) {
      setState(() {
        _progress = 1.0;
      });
    }
  }

  Future<void> _requestStartupPermissions() async {
    final permissionsToRequest = <Permission>[
      Permission.microphone,
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.videos,
      Permission.location,
      Permission.locationAlways,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ];

    final deniedPermissions = <Permission>[];

    for (final permission in permissionsToRequest) {
      final status = await permission.status;
      if (status.isDenied || status.isRestricted || status.isLimited) {
        deniedPermissions.add(permission);
      }
    }

    if (deniedPermissions.isNotEmpty) {
      final result = await deniedPermissions.request();
      final hasPermanentlyDenied = result.values.any((status) => status.isPermanentlyDenied);

      if (hasPermanentlyDenied && mounted) {
        await _showSettingsDialog(
          title: 'Permissions Required',
          message:
              'Some required permissions are permanently denied. Please allow Camera, Microphone, Storage, Location, and Bluetooth in app settings.',
        );
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final hasConnection = !results.contains(ConnectivityResult.none);

    if (!hasConnection && mounted) {
      await _showSettingsDialog(
        title: 'No Connectivity',
        message: 'Internet is not available. Please enable Wi-Fi or mobile data.',
      );
    }
  }

  Future<void> _determineAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;
    _targetRoute = session != null ? '/home' : '/login';

    // Simulate extra loading time for visual effect (optional)
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _onLoadingComplete() {
    if (!mounted || _targetRoute == null || _hasNavigated) return;
    
    _hasNavigated = true;
    // Once the bar finishes filling to 1.0, navigate
    Navigator.of(context).pushReplacementNamed(_targetRoute!);
  }

  Future<void> _showSettingsDialog({
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logoPath = isDarkMode
        ? 'assets/logos/logo_dark.png'
        : 'assets/logos/logo_light.png';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              logoPath,
              width: 112,
              height: 112,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: _progress),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                    );
                  },
                  onEnd: () {
                    if (_progress == 1.0) {
                      _onLoadingComplete();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _loadingText,
                key: ValueKey<String>(_loadingText),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
