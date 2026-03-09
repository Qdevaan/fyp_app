import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/app_input.dart';

class SearchDiscoveryScreen extends StatefulWidget {
  const SearchDiscoveryScreen({super.key});

  @override
  State<SearchDiscoveryScreen> createState() => _SearchDiscoveryScreenState();
}

class _SearchDiscoveryScreenState extends State<SearchDiscoveryScreen> {
  final _searchCtrl = TextEditingController();
  bool _hasQuery = false;

  final _suggestions = const ['Conversation starters', 'Networking tips', 'Conflict resolution', 'Job interview prep', 'First date ideas'];
  final _categories = const [
    _Category('Social Skills', Icons.people_outline, Color(0xFF13bdec)),
    _Category('Career', Icons.work_outline, Color(0xFF10B981)),
    _Category('Relationships', Icons.favorite_outline, Color(0xFFF43F5E)),
    _Category('Productivity', Icons.bolt_outlined, Color(0xFFF59E0B)),
    _Category('Mindset', Icons.psychology_outlined, Color(0xFFA855F7)),
    _Category('Health', Icons.self_improvement_outlined, Color(0xFF06B6D4)),
  ];

  final _results = const [
    _Result('How to start a conversation at a networking event', 'Social Skills', '3 min read'),
    _Result('The science of active listening for professionals', 'Career', '5 min read'),
    _Result('Breaking the ice: 15 conversation starters that work', 'Social Skills', '4 min read'),
  ];

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_hasQuery) ...[
                      Text('CATEGORIES', style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 1.2, color: BubblesColors.textMutedDark,
                      )),
                      const SizedBox(height: 12),
                      _buildCategories(),
                      const SizedBox(height: 24),
                      Text('TRENDING', style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 1.2, color: BubblesColors.textMutedDark,
                      )),
                      const SizedBox(height: 12),
                      ..._suggestions.map((s) => _SuggestionTile(s, () {
                        _searchCtrl.text = s;
                        setState(() => _hasQuery = true);
                      })),
                    ] else ...[
                      Text('RESULTS', style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 1.2, color: BubblesColors.textMutedDark,
                      )),
                      const SizedBox(height: 12),
                      ..._results.map((r) => _ResultCard(r)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext ctx) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
        decoration: const BoxDecoration(
          color: BubblesColors.glassHeaderDark,
          border: Border(bottom: BorderSide(color: Color(0x1A13BDEC))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: BubblesColors.textPrimaryDark),
              onPressed: () => Navigator.pop(ctx),
            ),
            Expanded(
              child: AppInput(
                controller: _searchCtrl,
                label: '',
                hint: 'Search topics, sessions…',
                prefix: const Icon(Icons.search, color: BubblesColors.textMutedDark, size: 20),
                onChanged: (v) => setState(() => _hasQuery = v.trim().isNotEmpty),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: _categories.map((c) => GestureDetector(
        onTap: () {
          _searchCtrl.text = c.name;
          setState(() => _hasQuery = true);
        },
        child: GlassBox(
          borderRadius: 14, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(c.icon, color: c.color, size: 18),
              const SizedBox(width: 8),
              Text(c.name, style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: BubblesColors.textPrimaryDark,
              )),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionTile(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassBox(
          borderRadius: 12, padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: BubblesColors.primary, size: 16),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: TextStyle(
                fontSize: 13, color: BubblesColors.textPrimaryDark,
              ))),
              const Icon(Icons.north_east, color: BubblesColors.textMutedDark, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _Result result;
  const _ResultCard(this.result);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassBox(
        borderRadius: 14, padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.title, style: GoogleFonts.manrope(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: BubblesColors.textPrimaryDark,
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: BubblesColors.glassPrimary,
                    border: Border.all(color: BubblesColors.glassPrimaryBorder),
                  ),
                  child: Text(result.category, style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: BubblesColors.primary,
                  )),
                ),
                const SizedBox(width: 10),
                Text(result.readTime, style: TextStyle(
                  fontSize: 10, color: BubblesColors.textMutedDark,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final IconData icon;
  final Color color;
  const _Category(this.name, this.icon, this.color);
}

class _Result {
  final String title, category, readTime;
  const _Result(this.title, this.category, this.readTime);
}
