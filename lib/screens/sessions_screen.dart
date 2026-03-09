import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';

/// Sessions overview (active + past) — shown as bottom nav index 2.
class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF101e22), Color(0xFF0d2a33)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
      bottomNavigationBar: BubblesBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i != 2) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: BubblesColors.glassHeaderDark,
          border: Border(bottom: BorderSide(color: Color(0x1A13BDEC))),
        ),
        child: Text('Sessions', style: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: BubblesColors.textPrimaryDark,
        )),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('START NEW'),
          const SizedBox(height: 10),
          _buildQuickStart(context),
          const SizedBox(height: 24),
          _buildLabel('RECENT'),
          const SizedBox(height: 10),
          _buildRecentList(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    letterSpacing: 1.2, color: BubblesColors.textMutedDark,
  ));

  Widget _buildQuickStart(BuildContext ctx) {
    return Row(
      children: [
        Expanded(child: _QuickCard(
          icon: Icons.mic,
          label: 'Live Wingman',
          description: 'Real-time coaching',
          color: BubblesColors.primary,
          onTap: () {},
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickCard(
          icon: Icons.chat_bubble_outline,
          label: 'AI Consult',
          description: 'Chat with your coach',
          color: const Color(0xFF10B981),
          onTap: () {},
        )),
      ],
    );
  }

  Widget _buildRecentList() {
    const sessions = [
      ('Relationship Strategy', 'Consultant', '2m ago', Icons.chat_bubble_outline, Color(0xFF13bdec)),
      ('Career Advice', 'Consultant', 'Yesterday', Icons.work_outline, Color(0xFF10B981)),
      ('Deep Focus Session', 'Therapy', 'Oct 24', Icons.psychology_outlined, Color(0xFFA855F7)),
      ('Social Wingman', 'Wingman', 'Oct 20', Icons.people_outline, Color(0xFF13bdec)),
    ];

    return Column(
      children: sessions.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassBox(
          borderRadius: 14, padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: s.$5.withOpacity(0.15),
                  border: Border.all(color: s.$5.withOpacity(0.3)),
                ),
                child: Icon(s.$4, color: s.$5, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$1, style: GoogleFonts.manrope(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: BubblesColors.textPrimaryDark,
                    )),
                    Text(s.$2, style: TextStyle(
                      fontSize: 11, color: s.$5,
                    )),
                  ],
                ),
              ),
              Text(s.$3, style: TextStyle(
                fontSize: 10, color: BubblesColors.textMutedDark,
              )),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: BubblesColors.textMutedDark, size: 18),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label, description;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon, required this.label, required this.description,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassBox(
        borderRadius: 16,
        bgColor: color.withOpacity(0.08),
        borderColor: color.withOpacity(0.3),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label, style: GoogleFonts.manrope(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: BubblesColors.textPrimaryDark,
            )),
            Text(description, style: TextStyle(
              fontSize: 10, color: BubblesColors.textSecondaryDark,
            )),
          ],
        ),
      ),
    );
  }
}
