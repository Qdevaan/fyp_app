import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';
import '../widgets/chat_bubble.dart';

enum _SortOrder { newestFirst, oldestFirst }

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  int _selectedFilter = 0; // 0=All, 1=Wingman, 2=Consultant
  _SortOrder _sortOrder = _SortOrder.newestFirst;

  void _openSortSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.slate600
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sort by',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    (
                      _SortOrder.newestFirst,
                      Icons.arrow_downward_rounded,
                      'Newest first',
                    ),
                    (
                      _SortOrder.oldestFirst,
                      Icons.arrow_upward_rounded,
                      'Oldest first',
                    ),
                  ].map((rec) {
                    final (order, icon, label) = rec;
                    final selected = _sortOrder == order;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        icon,
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.slate400
                                  : Colors.grey.shade500),
                        size: 20,
                      ),
                      title: Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.slate300
                                    : AppColors.slate700),
                        ),
                      ),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() => _sortOrder = order);
                        setModal(() {});
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'History',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : AppColors.slate900,
                        ),
                      ),
                    ),
                  ),
                  // Sort
                  IconButton(
                    tooltip: 'Sort',
                    onPressed: () => _openSortSheet(context, isDark),
                    icon: Icon(
                      Icons.sort_rounded,
                      color: _sortOrder != _SortOrder.newestFirst
                          ? primary
                          : (isDark
                                ? AppColors.slate300
                                : Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),

            // --- Filter Chips ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedFilter == 0,
                    onTap: () => setState(() => _selectedFilter = 0),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Wingman',
                    selected: _selectedFilter == 1,
                    onTap: () => setState(() => _selectedFilter = 1),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Consultant',
                    selected: _selectedFilter == 2,
                    onTap: () => setState(() => _selectedFilter = 2),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // --- Content ---
            Expanded(
              child: _selectedFilter == 2
                  ? ConsultantHistoryList(
                      searchQuery: '',
                      sortOrder: _sortOrder,
                    )
                  : _selectedFilter == 1
                  ? LiveSessionsList(searchQuery: '', sortOrder: _sortOrder)
                  : _CombinedList(searchQuery: '', sortOrder: _sortOrder),
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
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.tooltip,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.glassWhite : Colors.white),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.glassBorder : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? AppColors.slate300 : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}

// Combined list showing both types
class _CombinedList extends StatelessWidget {
  final String searchQuery;
  final _SortOrder sortOrder;
  const _CombinedList({required this.searchQuery, required this.sortOrder});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const _SectionHeader(title: 'Live Sessions'),
        const SizedBox(height: 4),
        LiveSessionsList(
          shrinkwrap: true,
          searchQuery: searchQuery,
          sortOrder: sortOrder,
        ),
        const SizedBox(height: 20),
        const _SectionHeader(title: 'Consultant Chats'),
        const SizedBox(height: 4),
        ConsultantHistoryList(
          shrinkwrap: true,
          searchQuery: searchQuery,
          sortOrder: sortOrder,
        ),
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
          color: isDark ? AppColors.slate400 : AppColors.slate500,
        ),
      ),
    );
  }
}

// --- TAB 1: LIVE SESSIONS LIST ---
class LiveSessionsList extends StatefulWidget {
  final bool shrinkwrap;
  final String searchQuery;
  final _SortOrder sortOrder;
  const LiveSessionsList({
    super.key,
    this.shrinkwrap = false,
    this.searchQuery = '',
    this.sortOrder = _SortOrder.newestFirst,
  });

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
          .map(
            (data) => List<Map<String, dynamic>>.from(
              data,
            ).where((s) => s['mode'] == 'live_wingman').toList(),
          );
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
        var sessions = snapshot.data ?? [];

        // Apply search
        if (widget.searchQuery.isNotEmpty) {
          sessions = sessions.where((s) {
            final title = (s['title'] ?? '').toString().toLowerCase();
            return title.contains(widget.searchQuery);
          }).toList();
        }

        // Apply sort
        sessions = List.from(sessions);
        switch (widget.sortOrder) {
          case _SortOrder.newestFirst:
            sessions.sort(
              (a, b) => (b['created_at'] as String).compareTo(
                a['created_at'] as String,
              ),
            );
          case _SortOrder.oldestFirst:
            sessions.sort(
              (a, b) => (a['created_at'] as String).compareTo(
                b['created_at'] as String,
              ),
            );
        }

        if (sessions.isEmpty) {
          return _buildEmptyState('No live sessions yet', Icons.mic_off);
        }

        return ListView.builder(
          shrinkWrap: widget.shrinkwrap,
          physics: widget.shrinkwrap
              ? const NeverScrollableScrollPhysics()
              : null,
          padding: widget.shrinkwrap
              ? EdgeInsets.zero
              : const EdgeInsets.all(16),
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
                      builder: (_) => GenericSessionDetail(
                        isConsultant: false,
                        sessionId: session['id'],
                        title: title,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.glassWhite : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    border: Border.all(
                      color: isDark
                          ? AppColors.glassBorder
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(51),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.mic,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.slate900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(38),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Wingman',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.slate400
                                        : AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppColors.slate500
                            : Colors.grey.shade400,
                        size: 20,
                      ),
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
  final String searchQuery;
  final _SortOrder sortOrder;
  const ConsultantHistoryList({
    super.key,
    this.shrinkwrap = false,
    this.searchQuery = '',
    this.sortOrder = _SortOrder.newestFirst,
  });

  @override
  State<ConsultantHistoryList> createState() => _ConsultantHistoryListState();
}

class _ConsultantHistoryListState extends State<ConsultantHistoryList> {
  final _supabase = Supabase.instance.client;
  late final Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _sessionsFuture = _supabase
          .from('sessions')
          .select()
          .eq('user_id', userId)
          .eq('mode', 'consultant')
          .order('created_at', ascending: false)
          .limit(50)
          .then((data) => List<Map<String, dynamic>>.from(data));
    } else {
      _sessionsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var sessions = snapshot.data ?? [];

        // Apply search
        if (widget.searchQuery.isNotEmpty) {
          sessions = sessions.where((s) {
            final title = (s['title'] ?? '').toString().toLowerCase();
            return title.contains(widget.searchQuery);
          }).toList();
        }

        // Apply sort
        sessions = List.from(sessions);
        switch (widget.sortOrder) {
          case _SortOrder.newestFirst:
            sessions.sort(
              (a, b) => (b['created_at'] as String).compareTo(
                a['created_at'] as String,
              ),
            );
          case _SortOrder.oldestFirst:
            sessions.sort(
              (a, b) => (a['created_at'] as String).compareTo(
                b['created_at'] as String,
              ),
            );
        }

        if (sessions.isEmpty) {
          return _buildEmptyState(
            'No consultant chats yet',
            Icons.chat_bubble_outline,
          );
        }

        return ListView.builder(
          shrinkWrap: widget.shrinkwrap,
          physics: widget.shrinkwrap
              ? const NeverScrollableScrollPhysics()
              : null,
          padding: widget.shrinkwrap
              ? EdgeInsets.zero
              : const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final date = DateTime.parse(session['created_at']).toLocal();
            final formattedDate = DateFormat('MMM d, h:mm a').format(date);
            final title = session['title'] ?? 'Consultant Chat';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GenericSessionDetail(
                        isConsultant: true,
                        sessionId: session['id'],
                        title: title,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.glassWhite : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    border: Border.all(
                      color: isDark
                          ? AppColors.glassBorder
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(38),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.psychology_outlined,
                          color: Colors.purple,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.slate900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withAlpha(38),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Consultant',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.slate400
                                        : AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppColors.slate500
                            : Colors.grey.shade400,
                        size: 20,
                      ),
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

// --- HELPER: EMPTY STATE ---
Widget _buildEmptyState(String message, IconData icon) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 52,
              color: isDark ? AppColors.slate700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 15,
                color: isDark
                    ? AppColors.slate400
                    : AppColors.slate500,
              ),
            ),
          ],
        ),
      );
    },
  );
}

// --- SUB-SCREEN: CONSULTANT SESSION DETAIL ---

class GenericSessionDetail extends StatefulWidget {
  final String sessionId;
  final String title;
  final bool isConsultant;

  const GenericSessionDetail({
    super.key,
    required this.sessionId,
    required this.title,
    required this.isConsultant,
  });

  @override
  State<GenericSessionDetail> createState() => _GenericSessionDetailState();
}

class _GenericSessionDetailState extends State<GenericSessionDetail> {
  late final Future<List<Map<String, dynamic>>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = Supabase.instance.client
        .from(widget.isConsultant ? 'consultant_logs' : 'session_logs')
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
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppColors.slate900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
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
                      child: Text(
                        "No records found.",
                        style: GoogleFonts.manrope(color: AppColors.textMuted),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];

                      if (widget.isConsultant) {
                        final question = log['question']?.toString() ?? '';
                        final answer = log['answer']?.toString() ?? '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (question.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ChatBubble(text: question, isUser: true),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 4,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'You',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (answer.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ChatBubble(
                                    text: answer,
                                    isUser: false,
                                    speakerLabel: 'Consultant AI',
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'Consultant AI',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      } else {
                        final role =
                            log['role']?.toString().toLowerCase() ?? 'unknown';
                        bool isUser = role == 'user';
                        bool isOther = role == 'other';
                        return Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            ChatBubble(
                              text: log['content'],
                              isUser: isUser,
                              speakerLabel: isUser
                                  ? null
                                  : (isOther ? "Other" : "System"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 4,
                                bottom: 8,
                              ),
                              child: Text(
                                isUser ? "You" : (isOther ? "Other" : "System"),
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
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
