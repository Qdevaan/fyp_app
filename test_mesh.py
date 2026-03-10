import sys

with open('lib/screens/consultant_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add MeshGradientBackground import if missing
if "import '../widgets/mesh_gradient_background.dart';" not in content:
    content = content.replace("import '../widgets/glass_morphism.dart';", "import '../widgets/glass_morphism.dart';\nimport '../widgets/mesh_gradient_background.dart';")

# 2. Wrap Scaffold with MeshGradientBackground
scaffold_old = '''      return Consumer<ConsultantProvider>(
        builder: (context, chat, _) {
          return Scaffold(
            key: _scaffoldKey,'''
scaffold_new = '''      return Consumer<ConsultantProvider>(
        builder: (context, chat, _) {
          return MeshGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              key: _scaffoldKey,'''
if scaffold_old in content:
    content = content.replace(scaffold_old, scaffold_new)

# 3. Add the closing tag for MeshGradientBackground at the end
end_old = '''                ),
              ],
            ),
          ),
        );
      },
    );
  }
}'''
end_new = '''                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}'''
# Check if the end_old exists. If not, maybe indentation is different.
if end_old in content:
    print("Found end_old exactly.")
    content = content.replace(end_old, end_new)
else:
    print("Could not find end_old!")

# 4. Modify the Input Area
input_old = '''                // -- INPUT AREA --
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
                          child: TextField('''

input_new = '''                // -- INPUT AREA --
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
                                    child: TextField('''

if input_old in content:
    print("Found input_old exactly.")
    content = content.replace(input_old, input_new)
else:
    print("Could not find input_old!")

# 5. Add closing tags for the Input Area and TextField
textfield_close_old = '''                          ),
                        ),
                      ),
                      const SizedBox(width: 10),'''
textfield_close_new = '''                            ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),'''

if textfield_close_old in content:
    print("Found textfield_close_old exactly.")
    content = content.replace(textfield_close_old, textfield_close_new)
else:
    print("Wait, could not find textfield_close_old!")

input_area_close_old = '''                        ),
                      ),
                    ],
                  ),
                ),'''
# This might conflict with the end_old structure. 
# Let's write the file to verify
with open('lib/screens/consultant_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Script complete.")
