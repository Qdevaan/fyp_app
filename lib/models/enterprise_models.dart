class SubscriptionTier {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime updatedAt;

  SubscriptionTier({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    required this.updatedAt,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      status: json['status'],
      currentPeriodStart: DateTime.parse(json['current_period_start']),
      currentPeriodEnd: DateTime.parse(json['current_period_end']),
      cancelAtPeriodEnd: json['cancel_at_period_end'] ?? false,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Integration {
  final String id;
  final String userId;
  final String provider;
  final bool isActive;
  final String syncStatus;
  final DateTime? expiresAt;

  Integration({
    required this.id,
    required this.userId,
    required this.provider,
    this.isActive = true,
    this.syncStatus = 'ok',
    this.expiresAt,
  });

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      id: json['id'],
      userId: json['user_id'],
      provider: json['provider'],
      isActive: json['is_active'] ?? true,
      syncStatus: json['sync_status'] ?? 'ok',
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }
}

class TeamWorkspace {
  final String id;
  final String ownerId;
  final String workspaceName;
  final int maxMembers;
  final DateTime createdAt;

  TeamWorkspace({
    required this.id,
    required this.ownerId,
    required this.workspaceName,
    this.maxMembers = 5,
    required this.createdAt,
  });

  factory TeamWorkspace.fromJson(Map<String, dynamic> json) {
    return TeamWorkspace(
      id: json['id'],
      ownerId: json['owner_id'],
      workspaceName: json['workspace_name'],
      maxMembers: json['max_members'] ?? 5,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
