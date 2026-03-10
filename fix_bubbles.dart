import 'dart:io';

void main() {
  final f = File('lib/widgets/consultant/consultant_widgets.dart');
  String text = f.readAsStringSync().replaceAll('\r\n', '\n');

  // Convert AiBubble normal box to glass box
  final aiOld = '''              Container(
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

  final aiNew = '''              Container(
                padding: const EdgeInsets.all(1), // Outer padding pushes inner background fully inside border
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : AppColors.slate300,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark.withAlpha(160)
                            : Colors.white.withAlpha(220),
                      ),''';

  if (text.contains(aiOld)) {
      text = text.replaceAll(aiOld, aiNew);
      print("AiBubble opening fixed");
      
      // Fix AiBubble closing brackets
      final aiEnd = '''                  ),
                ),
                // Timestamp''';
      final aiEndNew = '''                  ),
                ),
                ),
                ),
                // Timestamp''';
      text = text.replaceAll(aiEnd, aiEndNew);
  } else {
      print("AiBubble old snippet not found");
  }

  final userOld = '''              Container(
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

  final userNew = '''              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Colors.white.withAlpha(isDark ? 50 : 80),
                    width: 1.5,
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
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(3),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
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
                        color: primary.withAlpha(isDark ? 160 : 200),
                      ),''';
                      
  if (text.contains(userOld)) {
      text = text.replaceAll(userOld, userNew);
      print("UserBubble opening fixed");
      
      final userEnd = '''                ),
              ],
            ),
          ),
        ],
      );''';
      final userEndNew = '''                ),
                ),
                ),
              ],
            ),
          ),
        ],
      );''';
      text = text.replaceAll(userEnd, userEndNew);
  } else {
      print("UserBubble old snippet not found");
  }

  if (!text.contains("import 'dart:ui';")) {
     text = text.replaceAll("import 'package:flutter/material.dart';", "import 'dart:ui';\nimport 'package:flutter/material.dart';");
  }

  f.writeAsStringSync(text);
}
