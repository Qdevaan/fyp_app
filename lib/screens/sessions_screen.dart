import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: "Live Sessions"),
            Tab(text: "Consultant Chat"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiveSessionsList(),
          ConsultantHistoryList(),
        ],
      ),
    );
  }
}

// --- TAB 1: LIVE SESSIONS LIST ---
class LiveSessionsList extends StatefulWidget {
  const LiveSessionsList({super.key});

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
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final date = DateTime.parse(session['created_at']).toLocal();
            final formattedDate = DateFormat('MMM d, h:mm a').format(date);
            final title = session['title'] ?? 'Conversation';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: ListTile(
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formattedDate),
                trailing: const Icon(Icons.chevron_right),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.record_voice_over, color: Theme.of(context).colorScheme.primary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionDetailPage(
                        sessionId: session['id'],
                        title: title,
                      ),
                    ),
                  );
                },
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
  const ConsultantHistoryList({super.key});

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
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final date = DateTime.parse(log['created_at']).toLocal();
            final formattedDate = DateFormat('MMM d, h:mm a').format(date);
            final question = log['question'] ?? "Unknown Question";
            final answer = log['answer'] ?? "";

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.tertiary),
                ),
                title: Text(
                  question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(formattedDate),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Question:", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        Text(question, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 10),
                        Text("AI Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        Text(answer, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  )
                ],
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
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
      ],
    ),
  );
}

// --- SUB-SCREEN: LIVE SESSION DETAIL ---
class SessionDetailPage extends StatefulWidget {
  final String sessionId;
  final String title;

  const SessionDetailPage({
    super.key,
    required this.sessionId,
    required this.title,
  });

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(child: Text("No logs found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final role = log['role'];
              bool isUser = role == 'User';
              bool isOther = role == 'Other';
              
              // Style based on role
              Color bubbleColor = Theme.of(context).colorScheme.surfaceContainer;
              Color textColor = Theme.of(context).colorScheme.onSurface;
              Alignment align = Alignment.centerLeft;
              
              if (isUser) {
                bubbleColor = Theme.of(context).colorScheme.primary;
                textColor = Colors.white;
                align = Alignment.centerRight;
              } else if (isOther) {
                bubbleColor = Theme.of(context).colorScheme.surfaceContainer;
                align = Alignment.centerLeft;
              } else {
                // AI Suggestion logs?
                bubbleColor = Theme.of(context).colorScheme.secondaryContainer;
              }

              return Align(
                alignment: align,
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: Text(
                        log['content'],
                        style: TextStyle(color: textColor, fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                      child: Text(
                        isUser ? "You" : (isOther ? "Other" : "System"),
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}