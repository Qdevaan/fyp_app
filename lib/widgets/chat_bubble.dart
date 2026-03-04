import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

/// A reusable chat bubble widget used across screens:
/// LiveWingman, Consultant, and Session Detail.
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? speakerLabel;
  final Widget? contentWidget;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.speakerLabel,
    this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser
              ? (isDark ? Colors.transparent : Colors.transparent)
              : (isDark ? AppColors.bubbleDark : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 18 : 4),
            topRight: Radius.circular(isUser ? 4 : 18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          border: isUser
              ? Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && speakerLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  speakerLabel!,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            contentWidget ??
                Text(
                  text,
                  style: GoogleFonts.manrope(
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

