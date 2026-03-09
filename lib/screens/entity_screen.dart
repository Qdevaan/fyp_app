import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_input.dart';

class EntityScreen extends StatefulWidget {
  const EntityScreen({super.key});

  @override
  State<EntityScreen> createState() => _EntityScreenState();
}

class _EntityScreenState extends State<EntityScreen> {
  String _filter = 'All';
  final _searchCtrl = TextEditingController();
  final _filters = ['All', 'Person', 'Place', 'Org', 'Event', 'Object', 'Concept'];

  static const _entities = [
    _EntityData('Alex Chen', 'Person', 'Product Manager at TechCorp. Met at startup conf.', Icons.person_outline, Color(0xFF13bdec)),
    _EntityData('Sarah Johnson', 'Person', 'Relationship Coach. Referenced in session #14.', Icons.person_outline, Color(0xFF13bdec)),
    _EntityData('TechCorp HQ', 'Place', 'San Francisco office. Visited Oct 2024.', Icons.place_outlined, Color(0xFF10B981)),
    _EntityData('StartupConf 2024', 'Event', 'Annual networking event. Attended keynote.', Icons.event_outlined, Color(0xFFF59E0B)),
    _EntityData('OpenAI', 'Org', 'AI research company. Partnership discussions noted.', Icons.business_outlined, Color(0xFFA855F7)),
    _EntityData('Deep Work', 'Concept', 'Focus methodology by Cal Newport. Session strategy.', Icons.lightbulb_outline, Color(0xFFF43F5E)),
    _EntityData('Noise Cancelling Headphones', 'Object', 'Used in focus sessions. Sony WH-1000XM5.', Icons.headphones_outlined, Color(0xFFEC4899)),
    _EntityData('Brooklyn Coffee Shop', 'Place', 'Preferred work location on Fridays.', Icons.place_outlined, Color(0xFF10B981)),
  ];

  List<_EntityData> get _filtered {
    final query = _searchCtrl.text.toLowerCase();
    var list = _filter == 'All' ? _entities : _entities.where((e) => e.type == _filter).toList();
    if (query.isNotEmpty) {
      list = list.where((e) => e.name.toLowerCase().contains(query) || e.description.toLowerCase().contains(query)).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
            _buildSearch(),
            _buildFilters(),
            Expanded(child: _buildList()),
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
              child: Text('Knowledge Graph', style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: BubblesColors.textPrimaryDark,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: AppInput(
        controller: _searchCtrl,
        label: '',
        hint: 'Search entities…',
        prefix: const Icon(Icons.search, color: BubblesColors.textMutedDark, size: 20),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final sel = f == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: sel ? BubblesColors.primary : BubblesColors.glassDark,
                border: Border.all(
                  color: sel ? BubblesColors.primary : BubblesColors.glassBorderDark,
                ),
              ),
              child: Text(f, style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? BubblesColors.bgDark : BubblesColors.textSecondaryDark,
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
        child: Text('No entities found.', style: TextStyle(
          color: BubblesColors.textSecondaryDark, fontSize: 14,
        )),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final e = data[i];
        return GlassBox(
          borderRadius: 14, padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: e.color.withOpacity(0.15),
                  border: Border.all(color: e.color.withOpacity(0.3)),
                ),
                child: Icon(e.icon, color: e.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(e.name, style: GoogleFonts.manrope(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: BubblesColors.textPrimaryDark,
                        ))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: e.color.withOpacity(0.15),
                          ),
                          child: Text(e.type, style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: e.color,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(e.description, style: TextStyle(
                      fontSize: 11, color: BubblesColors.textSecondaryDark,
                    ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: BubblesColors.textMutedDark, size: 18),
            ],
          ),
        );
      },
    );
  }
}

class _EntityData {
  final String name, type, description;
  final IconData icon;
  final Color color;
  const _EntityData(this.name, this.type, this.description, this.icon, this.color);
}
