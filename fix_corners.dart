import 'dart:io';

void main() {
  final file = File('lib/screens/consultant_screen.dart');
  String content = file.readAsStringSync();
  
  final oldSnip = '''                            Expanded(
                              child: Container(
                                foregroundDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.glassBorder
                                        : AppColors.slate200,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 8,
                                      sigmaY: 8,
                                    ),
                                    child: Container(
                                      color: isDark
                                          ? AppColors.glassInput
                                          : Colors.white.withAlpha(220),
                                      child: TextField(''';

  final newSnip = '''                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: isDark ? AppColors.glassBorder : AppColors.slate300,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22.5),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      color: isDark ? AppColors.glassInput : Colors.white.withAlpha(220),
                                      child: TextField(''';

  // Normalize matching format but use Regex for safety
  final RegExp rgx = RegExp(r'Expanded\(\s*child:\s*Container\(\s*foregroundDecoration:\s*BoxDecoration\(\s*borderRadius:\s*BorderRadius\.circular\(24\.0\),\s*border:\s*Border\.all\(\s*color:\s*isDark\s*\?\s*AppColors\.glassBorder\s*:\s*AppColors\.slate200,\s*width:\s*1,\s*\),\s*\),\s*child:\s*ClipRRect\(\s*borderRadius:\s*BorderRadius\.circular\(24\.0\),\s*child:\s*BackdropFilter\(\s*filter:\s*ImageFilter\.blur\(\s*sigmaX:\s*8,\s*sigmaY:\s*8,\s*\),\s*child:\s*Container\(\s*color:\s*isDark\s*\?\s*AppColors\.glassInput\s*:\s*Colors\.white\.withAlpha\(220\),\s*child:\s*TextField\(', multiLine: true);
  
  if (rgx.hasMatch(content)) {
      content = content.replaceFirst(rgx, newSnip);
      file.writeAsStringSync(content);
      print("SUCCESS: Input Area fixed with padding offset");
  } else {
      print("FAIL: Could not match regex for input area");
  }
}
