import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final bool filled;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.filled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height: 52,
          decoration: BoxDecoration(
            gradient: filled
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      const Color(0xFF1E88E5),
                    ],
                  )
                : null,
            color: filled ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: filled
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.grey.shade300,
                  ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: filled
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          icon,
                          size: 20,
                          color: filled
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
