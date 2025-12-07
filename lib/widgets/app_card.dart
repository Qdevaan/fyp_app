import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'fade_slide_transition.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final GestureTapCallback? onTap;
  final Duration delay;

  const AppCard({
    super.key, 
    required this.child, 
    this.padding = const EdgeInsets.all(16), 
    this.onTap,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideTransition(
      delay: delay,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

