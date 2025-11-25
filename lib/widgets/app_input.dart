import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AppInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType type;
  final bool obscure;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    this.type = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _isObscure = false;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure,
      validator: widget.validator,
      keyboardType: widget.type,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20) : null,
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}