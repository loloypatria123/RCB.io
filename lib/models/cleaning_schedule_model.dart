enum ScheduleStatus { scheduled, inProgress, completed, cancelled }

class CleaningSchedule {
  final String id;
  final String adminId;
  final String? assignedUserId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ScheduleStatus status;
  final String? notes;
  final int? estimatedDuration; // in minutes

  CleaningSchedule({
    required this.id,
    required this.adminId,
    this.assignedUserId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.notes,
    this.estimatedDuration,
  });

  /// Convert CleaningSchedule to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'assignedUserId': assignedUserId,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'estimatedDuration': estimatedDuration,
    };
  }

  /// Create CleaningSchedule from Firestore JSON
  factory CleaningSchedule.fromJson(Map<String, dynamic> json) {
    return CleaningSchedule(
      id: json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      assignedUserId: json['assignedUserId'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : DateTime.now(),
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      status: _parseStatus(json['status']),
      notes: json['notes'],
      estimatedDuration: json['estimatedDuration'],
    );
  }

  /// Parse status string to enum
  static ScheduleStatus _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return ScheduleStatus.inProgress;
      case 'completed':
        return ScheduleStatus.completed;
      case 'cancelled':
        return ScheduleStatus.cancelled;
      default:
        return ScheduleStatus.scheduled;
    }
  }

  /// Create a copy with updated fields
  CleaningSchedule copyWith({
    String? id,
    String? adminId,
    String? assignedUserId,
    String? title,
    String? description,
    DateTime? scheduledDate,
    DateTime? scheduledTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    ScheduleStatus? status,
    String? notes,
    int? estimatedDuration,
  }) {
    return CleaningSchedule(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }

  /// Check if schedule is for today
  bool isForToday() {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }
}
