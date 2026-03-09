import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _team = [
    _TeamMember('Ayan Khan', 'Full Stack Lead', 'Flutter & Backend', 'AK', Color(0xFF13bdec)),
    _TeamMember('Sara Malik', 'AI Engineer', 'NLP & Voice Models', 'SM', Color(0xFF10B981)),
    _TeamMember('Omar Tariq', 'UI/UX Designer', 'Design System & Stitch', 'OT', Color(0xFFA855F7)),
    _TeamMember('Hira Noor', 'Data Scientist', 'Analytics & Insights', 'HN', Color(0xFFF59E0B)),
  ];

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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 180,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: BubblesColors.textPrimaryDark),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text('About Bubbles', style: GoogleFonts.manrope(
                  fontSize: 16, fontWeight: FontWeight.w700,
                )),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Color(0xFF0D4A5E), Color(0xFF101e22)],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF13bdec), Color(0xFF0ea5d0)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: BubblesColors.primary.withOpacity(0.4),
                                  blurRadius: 24, spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.bubble_chart, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMissionCard(),
                  const SizedBox(height: 24),
                  _buildVersionCard(),
                  const SizedBox(height: 24),
                  _SectionLabel('MEET THE TEAM'),
                  const SizedBox(height: 12),
                  ..._team.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TeamCard(m),
                  )),
                  const SizedBox(height: 24),
                  _buildAffiliationCard(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    return GlassPrimaryBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: BubblesColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('Our Mission', style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: BubblesColors.primary, letterSpacing: 0.5,
              )),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Bubbles is an AI-powered voice assistant designed to provide real-time social coaching, helping you navigate conversations with confidence.',
            style: TextStyle(fontSize: 13, color: BubblesColors.textPrimaryDark, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard() {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _VersionRow('App Version', '1.0.0-beta'),
          const SizedBox(height: 10),
          _VersionRow('Build', '2024.10.28'),
          const SizedBox(height: 10),
          _VersionRow('Platform', 'Flutter 3.x'),
          const SizedBox(height: 10),
          _VersionRow('Backend', 'Supabase + Python'),
        ],
      ),
    );
  }

  Widget _buildAffiliationCard() {
    return GlassBox(
      borderRadius: 16, padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AFFILIATION', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 1.2, color: BubblesColors.textMutedDark,
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: BubblesColors.glassDark,
                  border: Border.all(color: BubblesColors.glassBorderDark),
                ),
                child: const Icon(Icons.school_outlined, color: BubblesColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Final Year Project — Department of Computer Science',
                  style: TextStyle(fontSize: 13, color: BubblesColors.textPrimaryDark, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final _TeamMember member;
  const _TeamCard(this.member);

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: 14, padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: member.color.withOpacity(0.2),
            child: Text(member.initials, style: GoogleFonts.manrope(
              fontSize: 14, fontWeight: FontWeight.w800, color: member.color,
            )),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: BubblesColors.textPrimaryDark,
                )),
                Text(member.role, style: TextStyle(
                  fontSize: 11, color: member.color,
                )),
                Text(member.specialty, style: TextStyle(
                  fontSize: 10, color: BubblesColors.textMutedDark,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    letterSpacing: 1.2, color: BubblesColors.textMutedDark,
  ));
}

class _VersionRow extends StatelessWidget {
  final String label, value;
  const _VersionRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: 100, child: Text(label, style: TextStyle(
        fontSize: 12, color: BubblesColors.textSecondaryDark,
      ))),
      Text(value, style: GoogleFonts.manrope(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: BubblesColors.textPrimaryDark,
      )),
    ],
  );
}

class _TeamMember {
  final String name, role, specialty, initials;
  final Color color;
  const _TeamMember(this.name, this.role, this.specialty, this.initials, this.color);
}
