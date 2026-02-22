import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

class AppInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final TextInputType type;
  final bool obscure;
  final String? Function(String?)? validator;
  final String? hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;

  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.type = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPassword = widget.obscure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.type,
          obscureText: isPassword ? _hidden : false,
          validator: widget.validator,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style: GoogleFonts.manrope(
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter ${widget.label.toLowerCase()}',
            hintStyle: GoogleFonts.manrope(
              fontSize: 15,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                  )
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : (widget.suffixIcon != null
                    ? Icon(
                        widget.suffixIcon,
                        size: 20,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                      )
                    : null),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}