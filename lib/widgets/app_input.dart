import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

// ============================================================
//  Bubbles Glass Input
// ============================================================

class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool enabled;
  final int? maxLines;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefix,
    this.suffix,
    this.errorText,
    this.onChanged,
    this.onEditingComplete,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _focused = false;
  late bool _obscure;
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _node = FocusNode()..addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    Color borderColor;
    if (hasError) {
      borderColor = BubblesColors.error.withOpacity(0.6);
    } else if (_focused) {
      borderColor = BubblesColors.primary.withOpacity(0.6);
    } else {
      borderColor = isDark ? BubblesColors.glassBorderDark : const Color(0x14000000);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: isDark ? BubblesColors.textMutedDark : BubblesColors.textMutedLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? BubblesColors.glassDark : BubblesColors.glassLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: (hasError ? BubblesColors.error : BubblesColors.primary)
                          .withOpacity(0.12),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                const SizedBox(width: 12),
                widget.prefix!,
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscure,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  focusNode: _node,
                  enabled: widget.enabled,
                  maxLines: _obscure ? 1 : widget.maxLines,
                  onChanged: widget.onChanged,
                  onEditingComplete: widget.onEditingComplete,
                  style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w500,
                    color: isDark ? BubblesColors.textPrimaryDark : BubblesColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 15, fontWeight: FontWeight.w400,
                      color: isDark ? BubblesColors.textMutedDark : BubblesColors.textMutedLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(
                color: isDark ? AppColors.glassBorder : AppColors.slate200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: BubblesColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
