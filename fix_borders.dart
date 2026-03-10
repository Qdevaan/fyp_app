import 'dart:io';

void main() {
  final file = File('lib/screens/consultant_screen.dart');
  String content = file.readAsStringSync().replaceAll('\r\n', '\n');

  final oldSnip = '''                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.glassBorder
                                        : AppColors.slate200,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 8,
                                      sigmaY: 8,
                                    ),
                                    child: Container(
                                      color: isDark
                                          ? AppColors.glassInput
                                          : Colors.white.withAlpha(200),
                                      child: TextField(''';

  final newSnip = '''                            Expanded(
                              child: Container(
                                foregroundDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: isDark ? AppColors.glassBorder : AppColors.slate200,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      color: isDark ? AppColors.glassInput : Colors.white.withAlpha(220),
                                      child: TextField(''';

  if (content.contains(oldSnip)) {
    content = content.replaceAll(oldSnip, newSnip);
    print("Replaced TextField layout to use foregroundDecoration and radius 24.0");
  } else {
    print("Could not find the TextField snippet. Retrying with regex...");
    final RegExp reg = RegExp(
      r'Expanded\(\s*child:\s*Container\(\s*decoration:\s*BoxDecoration\(\s*borderRadius:\s*BorderRadius\.circular\(\s*AppRadius\.full,\s*\),\s*border:\s*Border\.all\(\s*color:\s*isDark\s*\?\s*AppColors\.glassBorder\s*:\s*AppColors\.slate200,\s*width:\s*1,\s*\),\s*\),\s*child:\s*ClipRRect\(\s*borderRadius:\s*BorderRadius\.circular\(\s*AppRadius\.full,\s*\),\s*child:\s*BackdropFilter\(\s*filter:\s*ImageFilter\.blur\(\s*sigmaX:\s*8,\s*sigmaY:\s*8,\s*\),\s*child:\s*Container\(\s*color:\s*isDark\s*\?\s*AppColors\.glassInput\s*:\s*Colors\.white\.withAlpha\(200\),\s*child:\s*TextField\(',
      multiLine: true,
    );
    if (reg.hasMatch(content)) {
       content = content.replaceFirst(reg, newSnip);
       print("Replaced via regex!");
    } else {
       print("Regex failed too.");
    }
  }

  file.writeAsStringSync(content);
}
