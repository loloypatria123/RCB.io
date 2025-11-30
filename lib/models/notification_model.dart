enum NotificationType {
  scheduleAdded,
  scheduleUpdated,
  scheduleReminder,
  scheduleCompleted,
  alert,
  reportReply,
  reportResolved,
}

class UserNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? scheduleId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  UserNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.scheduleId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  /// Convert UserNotification to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'scheduleId': scheduleId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create UserNotification from Firestore JSON
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      scheduleId: json['scheduleId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      metadata: json['metadata'],
    );
  }

  /// Parse type string to enum
  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'scheduleAdded':
        return NotificationType.scheduleAdded;
      case 'scheduleUpdated':
        return NotificationType.scheduleUpdated;
      case 'scheduleReminder':
        return NotificationType.scheduleReminder;
      case 'scheduleCompleted':
        return NotificationType.scheduleCompleted;
      case 'alert':
        return NotificationType.alert;
      case 'reportReply':
        return NotificationType.reportReply;
      case 'reportResolved':
        return NotificationType.reportResolved;
      default:
        return NotificationType.scheduleAdded;
    }
  }

  /// Create a copy with updated fields
  UserNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? scheduleId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduleId: scheduleId ?? this.scheduleId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
