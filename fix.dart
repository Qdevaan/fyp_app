import 'dart:io';

void main() {
  final file = File('lib/screens/consultant_screen.dart');
  String content = file.readAsStringSync();

  if (!content.contains("import '../widgets/mesh_gradient_background.dart';")) {
    content = content.replaceAll(
      "import '../widgets/glass_morphism.dart';",
      "import '../widgets/glass_morphism.dart';\nimport '../widgets/mesh_gradient_background.dart';"
    );
  }

  final scaffoldOld = '''      return Consumer<ConsultantProvider>(
        builder: (context, chat, _) {
          return Scaffold(
            key: _scaffoldKey,''';
  final scaffoldNew = '''      return Consumer<ConsultantProvider>(
        builder: (context, chat, _) {
          return MeshGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              key: _scaffoldKey,''';
  content = content.replaceAll(scaffoldOld, scaffoldNew);

  final endOld = '''                ),
              ],
            ),
          ),
        );
      },
    );
  }
}''';
  final endNew = '''                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}''';
  if (content.contains(endOld)) {
    content = content.replaceAll(endOld, endNew);
    print("Replaced Scaffold wrap!");
  } else {
    print("Could not find end of file.");
  }


  final inputOld = '''                // -- INPUT AREA --
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
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
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

  final inputNew = '''                // -- INPUT AREA --
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
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: isDark ? AppColors.glassBorder : Colors.white.withAlpha(150),
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
                                        : Colors.black.withAlpha(10),
                                    child: TextField(''';

  if (content.contains(inputOld)) {
    content = content.replaceAll(inputOld, inputNew);
    print("Replaced input top!");
  } else {
    print("Could not find input block!");
  }

  final textfieldCloseOld = '''                          ),
                        ),
                      ),
                      const SizedBox(width: 10),''';
  final textfieldCloseNew = '''                            ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),''';

  if (content.contains(textfieldCloseOld)) {
    content = content.replaceAll(textfieldCloseOld, textfieldCloseNew);
    print("Replaced text field close!");
  } else {
    print("Could not find text field close!");
  }

  file.writeAsStringSync(content);
}
