import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';

class AiInsightsDashboardScreen extends StatelessWidget {
  const AiInsightsDashboardScreen({super.key});

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
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(),
                    const SizedBox(height: 20),
                    _buildLabel('AI OBSERVATIONS'),
                    const SizedBox(height: 10),
                    _buildObservations(),
                    const SizedBox(height: 20),
                    _buildLabel('SKILL PROGRESSION'),
                    const SizedBox(height: 10),
                    _buildSkills(),
                    const SizedBox(height: 20),
                    _buildLabel('ACTIVITY HEATMAP'),
                    const SizedBox(height: 10),
                    _buildHeatmap(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              child: Text('AI Insights', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: BubblesColors.textPrimaryDark,
              )),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: BubblesColors.glassPrimary,
                border: Border.all(color: BubblesColors.glassPrimaryBorder),
              ),
              child: const Text('This Month', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: BubblesColors.primary,
              )),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    letterSpacing: 1.2, color: BubblesColors.textMutedDark,
  ));

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _StatTile('24', 'Sessions', const Color(0xFF13bdec))),
        const SizedBox(width: 10),
        Expanded(child: _StatTile('89%', 'Satisfaction', const Color(0xFF10B981))),
        const SizedBox(width: 10),
        Expanded(child: _StatTile('12h', 'Total Time', const Color(0xFFA855F7))),
      ],
    );
  }

  Widget _buildObservations() {
    const obs = [
      (Icons.psychology_outlined, 'You show strong empathetic listening in social scenarios.', Color(0xFF13bdec)),
      (Icons.trending_up, 'Your confidence in conflict resolution improved by 34% this month.', Color(0xFF10B981)),
      (Icons.warning_amber_outlined, 'You tend to avoid direct questions. Try being more assertive.', Color(0xFFF59E0B)),
    ];

    return Column(
      children: obs.map((o) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassBox(
          borderRadius: 14, padding: const EdgeInsets.all(14),
          bgColor: o.$3.withOpacity(0.06),
          borderColor: o.$3.withOpacity(0.2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: o.$3.withOpacity(0.15),
                ),
                child: Icon(o.$1, color: o.$3, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(o.$2, style: TextStyle(
                fontSize: 12, color: BubblesColors.textPrimaryDark, height: 1.5,
              ))),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSkills() {
    const skills = [
      ('Active Listening', 0.82, Color(0xFF13bdec)),
      ('Conflict Resolution', 0.65, Color(0xFF10B981)),
      ('Public Speaking', 0.48, Color(0xFFF59E0B)),
      ('Empathy', 0.91, Color(0xFFA855F7)),
      ('Networking', 0.57, Color(0xFFEC4899)),
    ];

    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(16),
      child: Column(
        children: skills.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(s.$1, style: GoogleFonts.manrope(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: BubblesColors.textPrimaryDark,
                  ))),
                  Text('${(s.$2 * 100).round()}%', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: s.$3,
                  )),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: s.$2,
                  minHeight: 6,
                  backgroundColor: s.$3.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(s.$3),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHeatmap() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const weeks = 4;
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((d) => Text(d, style: TextStyle(
              fontSize: 10, color: BubblesColors.textMutedDark, fontWeight: FontWeight.w600,
            ))).toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(weeks, (w) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (d) {
                final intensity = (((w * 7 + d) * 37) % 5) / 4.0;
                return Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: BubblesColors.primary.withOpacity(intensity * 0.7 + 0.05),
                  ),
                );
              }),
            ),
          )),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatTile(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: 14, padding: const EdgeInsets.symmetric(vertical: 16),
      bgColor: color.withOpacity(0.07),
      borderColor: color.withOpacity(0.25),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.manrope(
            fontSize: 22, fontWeight: FontWeight.w800, color: color,
          )),
          Text(label, style: TextStyle(
            fontSize: 10, color: BubblesColors.textSecondaryDark,
          )),
        ],
      ),
    );
  }
}
