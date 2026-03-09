import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Wingman', 'Consultant', 'Therapy'];

  final _sessions = const [
    _SessionData(
      icon: Icons.chat_bubble_outline, iconColor: BubblesColors.primary,
      title: 'Relationship Strategy', preview: 'Can you help me reply to this message about dinner?',
      time: '2m ago', type: 'Consultant',
    ),
    _SessionData(
      icon: Icons.work_outline, iconColor: Color(0xFF10B981),
      title: 'Career Advice', preview: 'Preparation for the upcoming performance review at TechCorp.',
      time: 'Yesterday', type: 'Consultant',
    ),
    _SessionData(
      icon: Icons.psychology_outlined, iconColor: Color(0xFFA855F7),
      title: 'Deep Focus Session', preview: 'Techniques for maintaining concentration.',
      time: 'Oct 24', type: 'Therapy',
    ),
    _SessionData(
      icon: Icons.lightbulb_outline, iconColor: Color(0xFFF59E0B),
      title: 'Ideation Workshop', preview: 'Brainstorming new features for the mobile app redesign.',
      time: 'Oct 22', type: 'Consultant',
    ),
    _SessionData(
      icon: Icons.forum_outlined, iconColor: BubblesColors.primary,
      title: 'Social Wingman', preview: 'Conversation starters for the networking event tonight.',
      time: 'Oct 20', type: 'Wingman',
    ),
    _SessionData(
      icon: Icons.favorite_outline, iconColor: Color(0xFFF43F5E),
      title: 'Date Night Planning', preview: 'Finding the best rooftop restaurants in the city center.',
      time: 'Oct 15', type: 'Wingman',
    ),
  ];

  List<_SessionData> get _filtered =>
      _filter == 'All' ? _sessions : _sessions.where((s) => s.type == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101e22), Color(0xFF0d2a33)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilters(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      bottomNavigationBar: BubblesBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: const BoxDecoration(
          color: BubblesColors.glassHeaderDark,
          border: Border(bottom: BorderSide(color: Color(0x1A13BDEC))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: BubblesColors.textPrimaryDark),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text('History', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: BubblesColors.textPrimaryDark,
              )),
            ),
            IconButton(
              icon: const Icon(Icons.sort, color: BubblesColors.textSecondaryDark),
              onPressed: () => _showSortSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final selected = f == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: selected ? BubblesColors.primary : BubblesColors.glassDark,
                border: Border.all(
                  color: selected ? BubblesColors.primary : BubblesColors.glassBorderDark,
                ),
              ),
              child: Text(f, style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: selected ? BubblesColors.bgDark : BubblesColors.textSecondaryDark,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    final data = _filtered;
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 56, color: BubblesColors.textMutedDark.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No sessions yet', style: GoogleFonts.manrope(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: BubblesColors.textSecondaryDark,
            )),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = data[i];
        return GestureDetector(
          onTap: () {},
          child: GlassBox(
            borderRadius: 14, padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: s.iconColor.withOpacity(0.15),
                    border: Border.all(color: s.iconColor.withOpacity(0.3)),
                  ),
                  child: Icon(s.icon, color: s.iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(s.title, style: GoogleFonts.manrope(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: BubblesColors.textPrimaryDark,
                            ), overflow: TextOverflow.ellipsis),
                          ),
                          Text(s.time, style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: BubblesColors.textMutedDark, letterSpacing: 0.5,
                          )),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(s.preview, style: TextStyle(
                        fontSize: 12, color: BubblesColors.textSecondaryDark,
                      ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: BubblesColors.textMutedDark, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: BubblesColors.glassHeaderDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: BubblesColors.glassBorderDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: BubblesColors.textMutedDark.withOpacity(0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            )),
            const SizedBox(height: 16),
            Text('Sort By', style: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: BubblesColors.textPrimaryDark,
            )),
            const SizedBox(height: 12),
            _SortTile('Newest First', true, () => Navigator.pop(context)),
            const SizedBox(height: 8),
            _SortTile('Oldest First', false, () => Navigator.pop(context)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortTile(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassBox(
        borderRadius: 12, padding: const EdgeInsets.all(14),
        bgColor: selected ? BubblesColors.glassPrimary : BubblesColors.glassDark,
        borderColor: selected ? BubblesColors.glassPrimaryBorder : BubblesColors.glassBorderDark,
        child: Row(
          children: [
            Expanded(child: Text(label, style: GoogleFonts.manrope(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: selected ? BubblesColors.primary : BubblesColors.textPrimaryDark,
            ))),
            if (selected) const Icon(Icons.check, color: BubblesColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SessionData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String preview;
  final String time;
  final String type;
  const _SessionData({
    required this.icon, required this.iconColor,
    required this.title, required this.preview,
    required this.time, required this.type,
  });
}
