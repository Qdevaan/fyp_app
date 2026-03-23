import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

// ============================================================
//  Bubbles App Button
// ============================================================

enum AppButtonVariant { filled, outlined, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    return Opacity(
      opacity: disabled && !loading ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: Container(
          height: height ?? 52,
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: _decoration(),
          alignment: Alignment.center,
          child: loading
              ? _DotLoader(color: _textColor())
              : Row(
                  mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: 18, color: _textColor()),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textColor(),
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: 18, color: _textColor()),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Color _textColor() {
    switch (variant) {
      case AppButtonVariant.filled:
        return BubblesColors.bgDark;
      case AppButtonVariant.outlined:
        return BubblesColors.primary;
      case AppButtonVariant.ghost:
        return BubblesColors.primary;
      case AppButtonVariant.danger:
        return BubblesColors.error;
    }
  }

  BoxDecoration _decoration() {
    switch (variant) {
      case AppButtonVariant.filled:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [BubblesColors.primary, BubblesColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: BubblesColors.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AppButtonVariant.outlined:
        return BoxDecoration(
          color: BubblesColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BubblesColors.primary.withOpacity(0.4)),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(borderRadius: BorderRadius.circular(999));
      case AppButtonVariant.danger:
        return BoxDecoration(
          color: BubblesColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BubblesColors.error.withOpacity(0.35)),
        );
    }
  }
}

/// 3-dot animated loader
class _DotLoader extends StatefulWidget {
  final Color color;
  const _DotLoader({required this.color});

  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final v = Interval(i * 0.25, i * 0.25 + 0.5, curve: Curves.easeInOut)
                .transform(_ctrl.value);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8 + v * 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
            );
          },
        );
      }),
    );
  }
}

/// Small circle icon button
class CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool filled;
  final double size;

  const CircleIconBtn({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.filled = false,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!filled) {
      // Outline / glass-pill style
      return Semantics(
        button: true,
        label: label,
        enabled: !loading,
        child: GestureDetector(
          onTap: loading ? null : onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassWhite : Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: loading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: isDark ? Colors.white : AppColors.slate700,
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
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.slate200 : AppColors.slate700,
                              ),
                            ),
                            if (icon != null) ...[
                              const SizedBox(width: 8),
                              Icon(icon, size: 18, color: isDark ? AppColors.slate200 : AppColors.slate700),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Filled — gradient primary with glow
    return Semantics(
      button: true,
      label: label,
      enabled: !loading,
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withAlpha(200)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(51),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
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
                          color: Colors.white,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, size: 18, color: Colors.white),
                      ],
                    ],
                  ),
          ),
        ),
        child: Icon(icon, size: size * 0.45, color: filled ? BubblesColors.bgDark : ic),
      ),
    );
  }
}
