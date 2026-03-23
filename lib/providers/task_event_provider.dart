import 'package:flutter/material.dart';
import '../models/task_event_models.dart';
import '../services/task_event_service.dart';

class TaskEventProvider with ChangeNotifier {
  final TaskEventService _service = TaskEventService();

  List<TaskItem> _tasks = [];
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<TaskItem> get tasks => _tasks;
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _service.getTasks(userId);
      _notifications = await _service.getNotifications(userId);
    } catch (e) {
      print('Failed to load tasks and notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(TaskItem task) async {
    await _service.addTask(task);
    _tasks.insert(0, task);
    notifyListeners();
  }
}
