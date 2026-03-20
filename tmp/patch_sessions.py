"""Appends _ThumbsFeedback and _StarRating widgets to sessions_screen.dart."""
SCREEN_PATH = r"d:\FYP\fyp_app\lib\screens\sessions_screen.dart"

APPEND = """
// ── Thumbs feedback widget ────────────────────────────────────────────────────
class _ThumbsFeedback extends StatelessWidget {
  final String logId;
  final int? currentValue; // 1 = up, -1 = down, null = unrated
  final ValueChanged<int> onFeedback;

  const _ThumbsFeedback({
    required this.logId,
    required this.currentValue,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            currentValue == 1 ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 18,
          ),
          color: currentValue == 1 ? Colors.green : cs.onSurface.withOpacity(0.5),
          onPressed: () => onFeedback(1),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          icon: Icon(
            currentValue == -1 ? Icons.thumb_down : Icons.thumb_down_outlined,
            size: 18,
          ),
          color: currentValue == -1 ? Colors.red : cs.onSurface.withOpacity(0.5),
          onPressed: () => onFeedback(-1),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

// ── Star rating widget ────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final String logId;
  final String sessionId;
  final int? initialValue; // 1–5
  final ValueChanged<int> onRate;

  const _StarRating({
    required this.logId,
    required this.sessionId,
    required this.initialValue,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starVal = i + 1;
        final filled = initialValue != null && starVal <= initialValue!;
        return GestureDetector(
          onTap: () => onRate(starVal),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 20,
              color: filled ? Colors.amber : Colors.amber.withOpacity(0.4),
            ),
          ),
        );
      }),
    );
  }
}
"""

with open(SCREEN_PATH, "r", encoding="utf-8") as f:
    content = f.read()

if "_ThumbsFeedback" in content:
    print("Already patched, skipping.")
else:
    with open(SCREEN_PATH, "a", encoding="utf-8") as f:
        f.write(APPEND)
    print("SUCCESS: helper widgets appended")
