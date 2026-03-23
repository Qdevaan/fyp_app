class TaskItem {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final String status;
  final String? category;
  final String? sourceSessionId;
  final DateTime? completedAt;
  final DateTime createdAt;

  TaskItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'pending',
    this.category,
    this.sourceSessionId,
    this.completedAt,
    required this.createdAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      category: json['category'],
      sourceSessionId: json['source_session_id'],
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'status': status,
      'category': category,
      'source_session_id': sourceSessionId,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String? body;
  final String? notifType;
  final String? actionUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    this.body,
    this.notifType,
    this.actionUrl,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      body: json['body'],
      notifType: json['notif_type'],
      actionUrl: json['action_url'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'notif_type': notifType,
      'action_url': actionUrl,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
