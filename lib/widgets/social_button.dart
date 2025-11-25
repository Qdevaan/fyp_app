import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final IconData icon;

  const SocialButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: theme.colorScheme.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onSurface,
                  ),
                )
              else ...[
                Icon(icon, size: 20, color: theme.colorScheme.onSurface),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}