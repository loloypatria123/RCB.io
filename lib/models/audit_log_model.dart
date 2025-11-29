enum AuditAction {
  scheduleCreated,
  scheduleUpdated,
  scheduleDeleted,
  scheduleCancelled,
  scheduleCompleted,
  userNotified,
}

class AuditLog {
  final String id;
  final String adminId;
  final String adminEmail;
  final String adminName;
  final AuditAction action;
  final String description;
  final String? scheduleId;
  final String? affectedUserId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AuditLog({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.adminName,
    required this.action,
    required this.description,
    this.scheduleId,
    this.affectedUserId,
    required this.timestamp,
    this.metadata,
  });

  /// Convert AuditLog to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'adminEmail': adminEmail,
      'adminName': adminName,
      'action': action.toString().split('.').last,
      'description': description,
      'scheduleId': scheduleId,
      'affectedUserId': affectedUserId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create AuditLog from Firestore JSON
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      adminEmail: json['adminEmail'] ?? '',
      adminName: json['adminName'] ?? '',
      action: _parseAction(json['action']),
      description: json['description'] ?? '',
      scheduleId: json['scheduleId'],
      affectedUserId: json['affectedUserId'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  /// Parse action string to enum
  static AuditAction _parseAction(String? action) {
    switch (action) {
      case 'scheduleCreated':
        return AuditAction.scheduleCreated;
      case 'scheduleUpdated':
        return AuditAction.scheduleUpdated;
      case 'scheduleDeleted':
        return AuditAction.scheduleDeleted;
      case 'scheduleCancelled':
        return AuditAction.scheduleCancelled;
      case 'scheduleCompleted':
        return AuditAction.scheduleCompleted;
      case 'userNotified':
        return AuditAction.userNotified;
      default:
        return AuditAction.scheduleCreated;
    }
  }

  /// Get human-readable action text
  String getActionText() {
    switch (action) {
      case AuditAction.scheduleCreated:
        return 'Created Schedule';
      case AuditAction.scheduleUpdated:
        return 'Updated Schedule';
      case AuditAction.scheduleDeleted:
        return 'Deleted Schedule';
      case AuditAction.scheduleCancelled:
        return 'Cancelled Schedule';
      case AuditAction.scheduleCompleted:
        return 'Completed Schedule';
      case AuditAction.userNotified:
        return 'Notified User';
    }
  }
}
