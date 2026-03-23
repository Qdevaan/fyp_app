import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_event_models.dart';

class TaskEventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<TaskItem>> getTasks(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => TaskItem.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  Future<void> addTask(TaskItem task) async {
    try {
      await _supabase.from('tasks').insert(task.toJson());
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
}
