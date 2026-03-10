import 'dart:io';

void main() {
  final cb = File('lib/widgets/chat_bubble.dart');
  String c1 = cb.readAsStringSync();

  if (!c1.contains("import 'dart:ui';")) {
    c1 = c1.replaceAll(
      "import 'package:flutter/material.dart';",
      "import 'dart:ui';\nimport 'package:flutter/material.dart';"
    );
  }

  // Same trick: outer container border, inner ClipRRect
  final cbOld = '''      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 18 : 4),
            topRight: Radius.circular(isUser ? 4 : 18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          border: Border.all(color: borderColor, width: 1),
        ),''';
  final cbNew = '''      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 18 : 4),
            topRight: Radius.circular(isUser ? 4 : 18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 18 : 4),
            topRight: Radius.circular(isUser ? 4 : 18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
              ),''';
              
  c1 = c1.replaceAll(cbOld, cbNew);

  final cbCloseOnPrimary = '''              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),''';
  final cbCloseOnPrimaryNew = '''              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        ),
        ),''';
  c1 = c1.replaceAll(cbCloseOnPrimary, cbCloseOnPrimaryNew);

  final cbCloseTextPrimary = '''              color: AppColors.textPrimary,
            ),
          ),
        ),''';
  final cbCloseTextPrimaryNew = '''              color: AppColors.textPrimary,
            ),
          ),
        ),
        ),
        ),''';
  c1 = c1.replaceAll(cbCloseTextPrimary, cbCloseTextPrimaryNew);

  cb.writeAsStringSync(c1);
  print("ChatBubble updated");


  final cw = File('lib/widgets/consultant/consultant_widgets.dart');
  String c2 = cw.readAsStringSync();
  if (!c2.contains("import 'dart:ui';")) {
    c2 = c2.replaceAll(
      "import 'package:flutter/material.dart';",
      "import 'dart:ui';\nimport 'package:flutter/material.dart';"
    );
  }

  // UserBubble
  final ubOld = '''              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(3),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),''';
  final ubNew = '''              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(3),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Colors.white.withAlpha(isDark ? 30 : 60),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(3),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withAlpha(isDark ? 160 : 200), // Glassy primary
                      ),''';
  c2 = c2.replaceAll(ubOld, ubNew);

  // Close UserBubble
  final ubClose = '''                ),
              ],
            ),
          ),
        ],
      );''';
  final ubCloseNew = '''                ),
                ),
                ),
              ],
            ),
          ),
        ],
      );''';
  c2 = c2.replaceAll(ubClose, ubCloseNew);


  // AiBubble
  final aibOld = '''              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: isDark
                        ? AppColors.glassBorder
                        : AppColors.slate200,
                  ),
                ),''';
  final aibNew = '''              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: isDark
                        ? AppColors.glassBorder
                        : Colors.white.withAlpha(255),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.glassWhite
                            : Colors.white.withAlpha(200),
                      ),''';
  c2 = c2.replaceAll(aibOld, aibNew);

  // Close AiBubble
  final aibClose = '''                  ),
                ),
                // Timestamp''';
  final aibCloseNew = '''                  ),
                ),
                ),
                ),
                // Timestamp''';
  c2 = c2.replaceAll(aibClose, aibCloseNew);

  cw.writeAsStringSync(c2);
  print("ConsultantBubbles updated");
}
