import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';
import '../widgets/chat_bubble.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  int _selectedFilter = 0; // 0=All, 1=Wingman, 2=Consultant

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'History',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.filter_list, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // --- Filter Chips ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _FilterChip(label: 'All', selected: _selectedFilter == 0, onTap: () => setState(() => _selectedFilter = 0), isDark: isDark),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Wingman', selected: _selectedFilter == 1, onTap: () => setState(() => _selectedFilter = 1), isDark: isDark),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Consultant', selected: _selectedFilter == 2, onTap: () => setState(() => _selectedFilter = 2), isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- Content ---
            Expanded(
              child: _selectedFilter == 2
                  ? const ConsultantHistoryList()
                  : _selectedFilter == 1
                      ? const LiveSessionsList()
                      : const _CombinedList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  const _FilterChip({required this.label, required this.selected, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}

// Combined list showing both types
class _CombinedList extends StatelessWidget {
  const _CombinedList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        _SectionHeader(title: 'Live Sessions'),
        SizedBox(height: 4),
        LiveSessionsList(shrinkwrap: true),
        SizedBox(height: 20),
        _SectionHeader(title: 'Consultant Chats'),
        SizedBox(height: 4),
        ConsultantHistoryList(shrinkwrap: true),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }
}

// --- TAB 1: LIVE SESSIONS LIST ---
class LiveSessionsList extends StatefulWidget {
  final bool shrinkwrap;
  const LiveSessionsList({super.key, this.shrinkwrap = false});

  @override
  State<LiveSessionsList> createState() => _LiveSessionsListState();
}

class _LiveSessionsListState extends State<LiveSessionsList> {
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _sessionsStream;

  @override
  void initState() {
    super.initState();
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _sessionsStream = _supabase
          .from('sessions')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map((data) => List<Map<String, dynamic>>.from(data));
    } else {
      _sessionsStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sessionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data ?? [];

        if (sessions.isEmpty) {
          return _buildEmptyState("No live sessions yet", Icons.mic_off);
        }

        return ListView.builder(
          shrinkWrap: widget.shrinkwrap,
          physics: widget.shrinkwrap ? const NeverScrollableScrollPhysics() : null,
          padding: widget.shrinkwrap ? EdgeInsets.zero : const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final date = DateTime.parse(session['created_at']).toLocal();
            final formattedDate = DateFormat('MMM d, h:mm a').format(date);
            final title = session['title'] ?? 'Conversation';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionDetailPage(sessionId: session['id'], title: title),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.mic, color: Theme.of(context).colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Wingman', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                                ),
                                const SizedBox(width: 8),
                                Text(formattedDate, style: GoogleFonts.manrope(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- TAB 2: CONSULTANT HISTORY LIST ---
class ConsultantHistoryList extends StatefulWidget {
  final bool shrinkwrap;
  const ConsultantHistoryList({super.key, this.shrinkwrap = false});

  @override
  State<ConsultantHistoryList> createState() => _ConsultantHistoryListState();
}

class _ConsultantHistoryListState extends State<ConsultantHistoryList> {
  final _supabase = Supabase.instance.client;
  late final Future<List<Map<String, dynamic>>> _logsFuture;

  @override
  void initState() {
    super.initState();
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _logsFuture = _supabase
          .from('consultant_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .then((data) => List<Map<String, dynamic>>.from(data));
    } else {
      _logsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _logsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return _buildEmptyState("No consultant chats yet", Icons.chat_bubble_outline);
        }

        return ListView.builder(
          shrinkWrap: widget.shrinkwrap,
          physics: widget.shrinkwrap ? const NeverScrollableScrollPhysics() : null,
          padding: widget.shrinkwrap ? EdgeInsets.zero : const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final date = DateTime.parse(log['created_at']).toLocal();
            final formattedDate = DateFormat('MMM d, h:mm a').format(date);
            final question = log['question'] ?? "Unknown Question";
            final answer = log['answer'] ?? "";

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                ),
                child: ExpansionTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.smart_toy, color: Colors.purple, size: 22),
                  ),
                  title: Text(
                    question,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Consultant', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.purple)),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(formattedDate, style: GoogleFonts.manrope(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Question:", style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(question, style: GoogleFonts.manrope(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 12),
                          Text("AI Answer:", style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(answer, style: GoogleFonts.manrope(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- HELPER: EMPTY STATE ---
Widget _buildEmptyState(String message, IconData icon) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 15,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// --- SUB-SCREEN: LIVE SESSION DETAIL ---
class SessionDetailPage extends StatefulWidget {
  final String sessionId;
  final String title;

  const SessionDetailPage({super.key, required this.sessionId, required this.title});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late final Future<List<Map<String, dynamic>>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = Supabase.instance.client
        .from('session_logs')
        .select()
        .eq('session_id', widget.sessionId)
        .order('created_at', ascending: true)
        .then((data) => List<Map<String, dynamic>>.from(data));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _logsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final logs = snapshot.data ?? [];

                  if (logs.isEmpty) {
                    return Center(
                      child: Text("No logs found.", style: GoogleFonts.manrope(color: AppColors.textMuted)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final role = log['role']?.toString().toLowerCase() ?? 'unknown';
                      bool isUser = role == 'user';
                      bool isOther = role == 'other';

                      return Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          ChatBubble(
                            text: log['content'],
                            isUser: isUser,
                            speakerLabel: isUser ? null : (isOther ? "Other" : "System"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                            child: Text(
                              isUser ? "You" : (isOther ? "Other" : "System"),
                              style: GoogleFonts.manrope(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
