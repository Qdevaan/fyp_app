import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Always use logo_light as per redesign request
    const logoAsset = 'assets/logos/logo_light.png';
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(50), // Squircle-ish
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              logoAsset,
              width: 120, // Smaller than container to fit inside
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        )
        .animate()
        .scale(duration: 600.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 400.ms),
      ),
    );
  }
}