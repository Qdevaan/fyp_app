import re

with open('lib/screens/consultant_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Scaffold with MeshGradientBackground
content = content.replace('      return Scaffold(', '      return MeshGradientBackground(\n        child: Scaffold(\n          backgroundColor: Colors.transparent,')

# Wait, closing parenthesis for MeshGradientBackground
# Find the exact end of the widget tree builder
end_str = '''          ),
        );
      },
    );
  }
}'''
end_replacement = '''          ),
          ),
        );
      },
    );
  }
}'''
content = content.replace(end_str, end_replacement)

# Replace the input area container with Glass variation
original_input = '''                // -- INPUT AREA --
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
                              color: isDark ? AppColors.glassBorder : Colors.transparent,
                            ),
                          ),
                          child: TextField('''

new_input = '''                // -- INPUT AREA --
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
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.glassInput
                                          : Colors.black.withAlpha(10),
                                    ),
                                    child: TextField('''

content = content.replace(original_input, new_input)

# Next, fix the closing tags that we added (ClipRRect & BackdropFilter on the top container -> 2 extra closing braces)
# And the inner container -> we replaced Container with Container > ClipRRect > BackdropFilter > Container (2 extra closing braces).
# Oh actually, let's just do a regex replace to catch the end of the Expanded and the end of the Input Area.
# Since we just added ClipRRect and BackdropFilter to TextField's wrapper:
# we can just write the whole block out. I'll just find the exact string.

# Wait, TextField block is closed by ), ), ), const SizedBox(width: 10),. Let's just do string replacement:
original_textfield_close = '''                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),'''

new_textfield_close = '''                            ),
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),'''

content = content.replace(original_textfield_close, new_textfield_close)

# And now close the entire Input Area block:
original_input_area_close = '''                        ),
                      ),
                    ],
                  ),
                ),'''

new_input_area_close = '''                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),'''

# It occurs at the very end of the builder before ], ), ), );
# Let's just be careful:
content = content.replace(original_input_area_close, new_input_area_close)


with open('lib/screens/consultant_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
