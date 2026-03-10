import 'dart:io';

void main() {
  final file = File('lib/screens/consultant_screen.dart');
  String content = file.readAsStringSync().replaceAll('\r\n', '\n');

  // Replace background container for Input Area to make it glass
  final inputWrapperOld = '''                // -- INPUT AREA --
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppColors.glassBorder
                            : AppColors.slate200,
                      ),
                    ),
                  ),''';
  final inputWrapperNew = '''                // -- INPUT AREA --
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark.withAlpha(200)
                            : Colors.white.withAlpha(220),
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? AppColors.glassBorder
                                : Colors.white.withAlpha(255),
                          ),
                        ),
                      ),''';
  if (content.contains(inputWrapperOld)) {
    content = content.replaceAll(inputWrapperOld, inputWrapperNew);
    print("Made input wrapper glass");
  } else {
    print("Input area NOT FOUND");
  }

  // Adding the missing 2 closing brackets for the input wrapper
  final inputWrapperCloseOld = '''                        ),
                      ),
                    ],
                  ),
                ),''';
  final inputWrapperCloseNew = '''                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),''';
  if (content.contains(inputWrapperCloseOld)) {
    content = content.replaceAll(inputWrapperCloseOld, inputWrapperCloseNew);
    print("Closed input wrapper");
  } else {
    print("Input close NOT FOUND");
  }

  // Replace the TextField container to be glass with exactly 1 border
  final textFieldOld = '''                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.glassInput
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.glassBorder
                                    : Colors.transparent,
                              ),
                            ),
                            child: TextField(''';
  final textFieldNew = '''                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: isDark ? AppColors.glassBorder : AppColors.slate200,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  color: isDark
                                      ? AppColors.glassInput
                                      : Colors.white.withAlpha(200),
                                  child: TextField(''';
  if (content.contains(textFieldOld)) {
    content = content.replaceAll(textFieldOld, textFieldNew);
    print("Made TextField glass");
  } else {
    print("TextField NOT FOUND");
  }

  // Adding the missing 2 closing brackets for the TextField
  final textFieldCloseOld = '''                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),''';
  final textFieldCloseNew = '''                            ),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),''';
  if (content.contains(textFieldCloseOld)) {
    content = content.replaceAll(textFieldCloseOld, textFieldCloseNew);
    print("Closed TextField glass widgets");
  } else {
    print("TextField Close NOT FOUND");
  }

  file.writeAsStringSync(content);
}
