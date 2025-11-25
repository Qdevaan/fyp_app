
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool filled;

  const AppButton({super.key, required this.label, this.onTap, this.loading = false, this.filled = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: filled ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: filled ? null : Border.all(color: theme.colorScheme.primary, width: 1.3),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: loading ? null : onTap,
        child: Center(
          child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(label, style: TextStyle(color: filled ? Colors.white : theme.colorScheme.primary, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

