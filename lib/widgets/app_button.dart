import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool filled;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine content color based on fill state
    final contentColor = filled ? Colors.white : theme.colorScheme.primary;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: filled ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: filled ? null : Border.all(color: theme.colorScheme.primary, width: 1.3),
      ),
      width: double.infinity,
      height: 54, // Fixed height prevents resizing during transition
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: loading ? null : onTap,
          child: Center(
            // AnimatedSwitcher creates the smooth fade/scale transition
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: loading
                  ? SizedBox(
                      key: const ValueKey('loader'),
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                      ),
                    )
                  : Text(
                      label,
                      key: const ValueKey('label'),
                      style: TextStyle(
                        color: contentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}