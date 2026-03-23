class Session {
  final String id;
  final String userId;
  final String? title;
  final String? summary;
  final String sessionType;
  final String? deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final bool isStarred;
  final double? sentimentScore;
  final int tokenUsagePrompt;
  final int tokenUsageCompletion;
  final double totalCostUsd;
  final DateTime createdAt;

  Session({
    required this.id,
    required this.userId,
    this.title,
    this.summary,
    this.sessionType = 'general',
    this.deviceId,
    required this.startTime,
    this.endTime,
    this.status = 'active',
    this.isStarred = false,
    this.sentimentScore,
    this.tokenUsagePrompt = 0,
    this.tokenUsageCompletion = 0,
    this.totalCostUsd = 0.0,
    required this.createdAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      summary: json['summary'],
      sessionType: json['session_type'] ?? 'general',
      deviceId: json['device_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      status: json['status'] ?? 'active',
      isStarred: json['is_starred'] ?? false,
      sentimentScore: json['sentiment_score']?.toDouble(),
      tokenUsagePrompt: json['token_usage_prompt'] ?? 0,
      tokenUsageCompletion: json['token_usage_completion'] ?? 0,
      totalCostUsd: (json['total_cost_usd'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'summary': summary,
      'session_type': sessionType,
      'device_id': deviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'is_starred': isStarred,
      'sentiment_score': sentimentScore,
      'token_usage_prompt': tokenUsagePrompt,
      'token_usage_completion': tokenUsageCompletion,
      'total_cost_usd': totalCostUsd,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SessionLog {
  final String id;
  final String sessionId;
  final int turnIndex;
  final String role;
  final String? content;
  final String? contentHtml;
  final String? modelUsed;
  final int? latencyMs;
  final int? tokensUsed;
  final String? finishReason;
  final bool hasError;
  final String? errorMessage;
  final DateTime createdAt;

  SessionLog({
    required this.id,
    required this.sessionId,
    required this.turnIndex,
    required this.role,
    this.content,
    this.contentHtml,
    this.modelUsed,
    this.latencyMs,
    this.tokensUsed,
    this.finishReason,
    this.hasError = false,
    this.errorMessage,
    required this.createdAt,
  });

  factory SessionLog.fromJson(Map<String, dynamic> json) => SessionLog(
        id: json['id'],
        sessionId: json['session_id'],
        turnIndex: json['turn_index'],
        role: json['role'],
        content: json['content'],
        contentHtml: json['content_html'],
        modelUsed: json['model_used'],
        latencyMs: json['latency_ms'],
        tokensUsed: json['tokens_used'],
        finishReason: json['finish_reason'],
        hasError: json['has_error'] ?? false,
        errorMessage: json['error_message'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'turn_index': turnIndex,
        'role': role,
        'content': content,
        'content_html': contentHtml,
        'model_used': modelUsed,
        'latency_ms': latencyMs,
        'tokens_used': tokensUsed,
        'finish_reason': finishReason,
        'has_error': hasError,
        'error_message': errorMessage,
        'created_at': createdAt.toIso8601String(),
      };
}
