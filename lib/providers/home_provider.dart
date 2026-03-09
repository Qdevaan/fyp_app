import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

/// Dedicated state manager for the HomeScreen.
/// Extracts data fetching (events, highlights, profile) and
/// Realtime subscription out of the widget.
class HomeProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  bool _loading = true;
  bool get loading => _loading;

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> get events => List.unmodifiable(_events);

  List<Map<String, dynamic>> _highlights = [];
  List<Map<String, dynamic>> get highlights => List.unmodifiable(_highlights);

  bool _insightsLoaded = false;
  bool get insightsLoaded => _insightsLoaded;

  int _unreadNotifications = 0;
  int get unreadNotifications => _unreadNotifications;

  RealtimeChannel? _highlightsChannel;

  void init() {
    loadProfile();
    loadInsights();
    subscribeToHighlights();
  }

  void clearUnread() {
    _unreadNotifications = 0;
    notifyListeners();
  }

  Future<void> clearAllHighlights() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await _supabase
        .from('highlights')
        .update({'is_dismissed': true})
        .eq('user_id', user.id)
        .eq('is_dismissed', false);
    _highlights.clear();
    notifyListeners();
  }

  void subscribeToHighlights() {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    _highlightsChannel = _supabase
        .channel('home_highlights_${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'highlights',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            final record = Map<String, dynamic>.from(payload.newRecord);
            _highlights.insert(0, record);
            _unreadNotifications++;
            notifyListeners();
          },
        )
        .subscribe();
  }

  Future<void> loadProfile() async {
    final data = await AuthService.instance.getProfile();
    _profile = data;
    _loading = false;
    notifyListeners();
  }

  Future<void> loadInsights() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final eventsRes = await _supabase
          .from('events')
          .select('title, due_text, description, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      final highlightsRes = await _supabase
          .from('highlights')
          .select('title, body, highlight_type, created_at')
          .eq('user_id', user.id)
          .eq('is_resolved', false)
          .order('created_at', ascending: false)
          .limit(5);

      _events = List<Map<String, dynamic>>.from(eventsRes);
      _highlights = List<Map<String, dynamic>>.from(highlightsRes);
      _insightsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading insights: $e');
      _insightsLoaded = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _highlightsChannel?.unsubscribe();
    super.dispose();
  }
}
