import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ============================================================
//  Bubbles Shared Widgets
// ============================================================

/// Glassmorphism container — core UI surface
class GlassBox extends StatelessWidget {
  final Widget child;
  final Color? bgColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;

  const GlassBox({
    super.key,
    required this.child,
    this.bgColor,
    this.borderColor,
    this.borderRadius = 16,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = bgColor ?? (isDark ? BubblesColors.glassDark : BubblesColors.glassLight);
    final border = borderColor ?? (isDark ? BubblesColors.glassBorderDark : BubblesColors.glassBorderLight);

    final box = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: box);
    }
    return box;
  }
}

/// Primary-tinted glass
class GlassPrimaryBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassPrimaryBox({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      bgColor: BubblesColors.glassPrimary,
      borderColor: BubblesColors.glassPrimaryBorder,
      borderRadius: borderRadius,
      padding: padding,
      onTap: onTap,
      shadow: [
        BoxShadow(
          color: BubblesColors.primary.withOpacity(0.12),
          blurRadius: 30,
          spreadRadius: 0,
        ),
      ],
      child: child,
    );
  }
}

/// Full-screen mesh gradient background
class BgMesh extends StatelessWidget {
  final Widget child;
  const BgMesh({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? BubblesColors.bgDark : BubblesColors.bgLight,
      ),
      child: Stack(
        children: [
          // Top-left primary orb
          Positioned(
            top: -120, left: -120,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    BubblesColors.primary.withOpacity(isDark ? 0.13 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Top-right indigo orb
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(isDark ? 0.15 : 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-right teal orb
          Positioned(
            bottom: -100, right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    BubblesColors.primary.withOpacity(isDark ? 0.08 : 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Glass App Bar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBorder;

  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBorder = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? BubblesColors.glassHeaderDark : BubblesColors.glassLight,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: isDark ? BubblesColors.glassHeaderBorderDark : BubblesColors.glassBorderLight,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              if (leading != null) leading!
              else if (Navigator.canPop(context))
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              const SizedBox(width: 4),
              Expanded(
                child: titleWidget ??
                    Text(
                      title ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation bar
class BubblesBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BubblesBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat'),
    (Icons.history_outlined, Icons.history, 'History'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? BubblesColors.glassHeaderDark : BubblesColors.glassLight,
        border: Border(
          top: BorderSide(
            color: isDark ? BubblesColors.glassBorderDark : BubblesColors.glassBorderLight,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? item.$2 : item.$1,
                        color: selected ? BubblesColors.primary
                            : (isDark ? BubblesColors.textMutedDark : BubblesColors.textMutedLight),
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: selected ? BubblesColors.primary
                              : (isDark ? BubblesColors.textMutedDark : BubblesColors.textMutedLight),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Status badge (connected / disconnected / connecting)
enum ConnectionStatus { connected, connecting, disconnected }

class StatusBadge extends StatefulWidget {
  final ConnectionStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String label;

    switch (widget.status) {
      case ConnectionStatus.connected:
        dotColor = BubblesColors.success;
        label = 'Connected';
        break;
      case ConnectionStatus.connecting:
        dotColor = BubblesColors.warning;
        label = 'Connecting…';
        break;
      case ConnectionStatus.disconnected:
        dotColor = BubblesColors.error;
        label = 'Disconnected';
        break;
    }

    return GlassBox(
      borderRadius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withOpacity(0.5 * _ctrl.value),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: dotColor, letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
