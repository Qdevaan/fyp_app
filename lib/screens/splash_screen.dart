import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect system theme for correct logo
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isDarkMode 
                  ? 'assets/images/logo_light.png' 
                  : 'assets/images/logo_dark.png',
              width: 120,
              height: 120,
              errorBuilder: (c, o, s) => const Icon(Icons.bubble_chart, size: 100, color: Colors.blueAccent),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              strokeWidth: 3, 
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}