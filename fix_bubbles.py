import re

# 1. Fix chat_bubble.dart 
with open('lib/widgets/chat_bubble.dart', 'r', encoding='utf-8') as f:
    chat_bubble = f.read()

# Make the bgColor a little bit more transparent
chat_bubble =  chat_bubble.replace('''import 'package:flutter/material.dart';''', '''import 'dart:ui';\nimport 'package:flutter/material.dart';''')

original_chat_bubble_container = '''      child: Container(
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
        ),'''

new_chat_bubble_container = '''      child: Container(
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
              ),'''

chat_bubble = chat_bubble.replace(original_chat_bubble_container, new_chat_bubble_container)

chat_bubble = chat_bubble.replace('''              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),''', '''              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        ),
        ),''')

chat_bubble = chat_bubble.replace('''              color: AppColors.textPrimary,
            ),
          ),
        ),''', '''              color: AppColors.textPrimary,
            ),
          ),
        ),
        ),
        ),''')


with open('lib/widgets/chat_bubble.dart', 'w', encoding='utf-8') as f:
    f.write(chat_bubble)


# 2. Fix consultant_widgets.dart
with open('lib/widgets/consultant/consultant_widgets.dart', 'r', encoding='utf-8') as f:
    consultant = f.read()

consultant = consultant.replace('''import 'package:flutter/material.dart';''', '''import 'dart:ui';\nimport 'package:flutter/material.dart';''')

user_bubble_orig = '''              Container(
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
                ),'''

user_bubble_new = '''              Container(
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
                      ),'''

consultant = consultant.replace(user_bubble_orig, user_bubble_new)

# Add closing tags for user bubble
consultant = consultant.replace('''                ),
              ],
            ),
          ),
        ],
      );''', '''                ),
                ),
                ),
              ],
            ),
          ),
        ],
      );''', 1) 

ai_bubble_orig = '''              Container(
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
                ),'''

ai_bubble_new = '''              Container(
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
                      ),'''
consultant = consultant.replace(ai_bubble_orig, ai_bubble_new)

# Add closing tags for ai bubble
consultant = consultant.replace('''                  ),
                ),
                // Timestamp''', '''                  ),
                ),
                ),
                ),
                // Timestamp''', 1)

with open('lib/widgets/consultant/consultant_widgets.dart', 'w', encoding='utf-8') as f:
    f.write(consultant)
