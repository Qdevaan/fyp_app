import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final String? imagePath;
  final IconData? icon;
  final VoidCallback onTap;
  final bool loading;

  const SocialButton({
    super.key,
    required this.label,
    this.imagePath,
    this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != null)
                Image.asset(imagePath!, height: 22, width: 22)
              else if (icon != null)
                Icon(icon, size: 22, color: isDark ? Colors.white : Colors.black87),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}