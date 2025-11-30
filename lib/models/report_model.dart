enum ReportStatus { open, inProgress, resolved, archived }

enum ReportCategory {
  robotStuck,
  navigationProblem,
  cleaningError,
  appIssue,
  batteryIssue,
  sensorError,
  other
}

class Report {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final List<ReportReply> replies;
  final bool archived;

  Report({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.title,
    required this.description,
    required this.category,
    this.status = ReportStatus.open,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.replies = const [],
    this.archived = false,
  });

  /// Convert Report to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'archived': archived,
    };
  }

  /// Create Report from Firestore JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userName: json['userName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: _parseCategory(json['category']),
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((reply) => ReportReply.fromJson(reply))
              .toList() ??
          [],
      archived: json['archived'] ?? false,
    );
  }

  /// Parse category string to enum
  static ReportCategory _parseCategory(String? category) {
    switch (category) {
      case 'robotStuck':
        return ReportCategory.robotStuck;
      case 'navigationProblem':
        return ReportCategory.navigationProblem;
      case 'cleaningError':
        return ReportCategory.cleaningError;
      case 'appIssue':
        return ReportCategory.appIssue;
      case 'batteryIssue':
        return ReportCategory.batteryIssue;
      case 'sensorError':
        return ReportCategory.sensorError;
      default:
        return ReportCategory.other;
    }
  }

  /// Parse status string to enum
  static ReportStatus _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'archived':
        return ReportStatus.archived;
      default:
        return ReportStatus.open;
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case ReportCategory.robotStuck:
        return 'Robot Stuck';
      case ReportCategory.navigationProblem:
        return 'Navigation Problem';
      case ReportCategory.cleaningError:
        return 'Cleaning Error';
      case ReportCategory.appIssue:
        return 'App Issue';
      case ReportCategory.batteryIssue:
        return 'Battery Issue';
      case ReportCategory.sensorError:
        return 'Sensor Error';
      case ReportCategory.other:
        return 'Other';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case ReportStatus.open:
        return 'Open';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.archived:
        return 'Archived';
    }
  }

  /// Create a copy with updated fields
  Report copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? title,
    String? description,
    ReportCategory? category,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    List<ReportReply>? replies,
    bool? archived,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      replies: replies ?? this.replies,
      archived: archived ?? this.archived,
    );
  }
}

class ReportReply {
  final String id;
  final String adminId;
  final String adminName;
  final String adminEmail;
  final String message;
  final DateTime createdAt;

  ReportReply({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.adminEmail,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'adminName': adminName,
      'adminEmail': adminEmail,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportReply.fromJson(Map<String, dynamic> json) {
    return ReportReply(
      id: json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      adminName: json['adminName'] ?? '',
      adminEmail: json['adminEmail'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

