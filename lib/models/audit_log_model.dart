import 'package:flutter/material.dart';

enum AuditAction {
  // Schedule actions
  scheduleCreated,
  scheduleUpdated,
  scheduleDeleted,
  scheduleCancelled,
  scheduleCompleted,
  
  // User management actions
  userAccountCreated,
  userAccountUpdated,
  userAccountDeleted,
  userStatusChanged,
  userRoleChanged,
  userNotified,
  userLoggedIn,
  userLoggedOut,
  userPasswordChanged,
  
  // Admin actions
  adminLoggedIn,
  adminLoggedOut,
  adminPasswordChanged,
  adminCreatedUser,
  adminUpdatedUser,
  adminDeletedUser,
  adminAccessedReports,
  adminAccessedLogs,
  adminExportedData,
  
  // Report actions
  reportCreated,
  reportViewed,
  reportResolved,
  reportArchived,
  reportReplied,
  
  // Robot actions
  robotConnected,
  robotDisconnected,
  robotCleaningStarted,
  robotCleaningCompleted,
  robotDisposalPerformed,
  robotSensorWarning,
  robotConnectivityIssue,
  
  // System actions
  systemError,
  systemWarning,
  configurationChanged,
}

/// Risk level for audit actions
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

class AuditLog {
  final String id;
  final String actorId;
  final String actorEmail;
  final String actorName;
  final String actorType; // 'admin', 'user', 'robot', 'system'
  final AuditAction action;
  final String description;
  final String? scheduleId;
  final String? affectedUserId;
  final String? affectedResourceId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String category; // 'user_actions', 'admin_actions', 'robot_actions', etc.
  
  // Enhanced fields for professional tracking
  final String? ipAddress;
  final String? userAgent;
  final String? sessionId;
  final RiskLevel riskLevel;
  final Map<String, dynamic>? changesBefore; // Before values for updates
  final Map<String, dynamic>? changesAfter; // After values for updates
  final int? executionTimeMs; // Time taken to execute action
  final bool success; // Whether action was successful
  final String? errorMessage; // Error message if action failed

  AuditLog({
    required this.id,
    required this.actorId,
    required this.actorEmail,
    required this.actorName,
    required this.actorType,
    required this.action,
    required this.description,
    this.scheduleId,
    this.affectedUserId,
    this.affectedResourceId,
    required this.timestamp,
    this.metadata,
    required this.category,
    this.ipAddress,
    this.userAgent,
    this.sessionId,
    this.riskLevel = RiskLevel.low,
    this.changesBefore,
    this.changesAfter,
    this.executionTimeMs,
    this.success = true,
    this.errorMessage,
  });

  /// Convert AuditLog to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actorId': actorId,
      'actorEmail': actorEmail,
      'actorName': actorName,
      'actorType': actorType,
      'action': action.toString().split('.').last,
      'description': description,
      'scheduleId': scheduleId,
      'affectedUserId': affectedUserId,
      'affectedResourceId': affectedResourceId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'category': category,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'sessionId': sessionId,
      'riskLevel': riskLevel.toString().split('.').last,
      'changesBefore': changesBefore,
      'changesAfter': changesAfter,
      'executionTimeMs': executionTimeMs,
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  /// Create AuditLog from Firestore JSON
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] ?? '',
      actorId: json['actorId'] ?? json['adminId'] ?? '',
      actorEmail: json['actorEmail'] ?? json['adminEmail'] ?? '',
      actorName: json['actorName'] ?? json['adminName'] ?? '',
      actorType: json['actorType'] ?? 'system',
      action: _parseAction(json['action']),
      description: json['description'] ?? '',
      scheduleId: json['scheduleId'],
      affectedUserId: json['affectedUserId'],
      affectedResourceId: json['affectedResourceId'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      metadata: json['metadata'],
      category: json['category'] ?? _inferCategory(json['action']),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      sessionId: json['sessionId'],
      riskLevel: _parseRiskLevel(json['riskLevel']),
      changesBefore: json['changesBefore'],
      changesAfter: json['changesAfter'],
      executionTimeMs: json['executionTimeMs'],
      success: json['success'] ?? true,
      errorMessage: json['errorMessage'],
    );
  }

  /// Parse action string to enum
  static AuditAction _parseAction(String? action) {
    switch (action) {
      // Schedule actions
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
      
      // User management actions
      case 'userAccountCreated':
        return AuditAction.userAccountCreated;
      case 'userAccountUpdated':
        return AuditAction.userAccountUpdated;
      case 'userAccountDeleted':
        return AuditAction.userAccountDeleted;
      case 'userStatusChanged':
        return AuditAction.userStatusChanged;
      case 'userRoleChanged':
        return AuditAction.userRoleChanged;
      case 'userNotified':
        return AuditAction.userNotified;
      case 'userLoggedIn':
        return AuditAction.userLoggedIn;
      case 'userLoggedOut':
        return AuditAction.userLoggedOut;
      case 'userPasswordChanged':
        return AuditAction.userPasswordChanged;
      
      // Admin actions
      case 'adminLoggedIn':
        return AuditAction.adminLoggedIn;
      case 'adminLoggedOut':
        return AuditAction.adminLoggedOut;
      case 'adminPasswordChanged':
        return AuditAction.adminPasswordChanged;
      case 'adminCreatedUser':
        return AuditAction.adminCreatedUser;
      case 'adminUpdatedUser':
        return AuditAction.adminUpdatedUser;
      case 'adminDeletedUser':
        return AuditAction.adminDeletedUser;
      case 'adminAccessedReports':
        return AuditAction.adminAccessedReports;
      case 'adminAccessedLogs':
        return AuditAction.adminAccessedLogs;
      case 'adminExportedData':
        return AuditAction.adminExportedData;
      
      // Report actions
      case 'reportCreated':
        return AuditAction.reportCreated;
      case 'reportViewed':
        return AuditAction.reportViewed;
      case 'reportResolved':
        return AuditAction.reportResolved;
      case 'reportArchived':
        return AuditAction.reportArchived;
      case 'reportReplied':
        return AuditAction.reportReplied;
      
      // Robot actions
      case 'robotConnected':
        return AuditAction.robotConnected;
      case 'robotDisconnected':
        return AuditAction.robotDisconnected;
      case 'robotCleaningStarted':
        return AuditAction.robotCleaningStarted;
      case 'robotCleaningCompleted':
        return AuditAction.robotCleaningCompleted;
      case 'robotDisposalPerformed':
        return AuditAction.robotDisposalPerformed;
      case 'robotSensorWarning':
        return AuditAction.robotSensorWarning;
      case 'robotConnectivityIssue':
        return AuditAction.robotConnectivityIssue;
      
      // System actions
      case 'systemError':
        return AuditAction.systemError;
      case 'systemWarning':
        return AuditAction.systemWarning;
      case 'configurationChanged':
        return AuditAction.configurationChanged;
      
      default:
        return AuditAction.systemWarning;
    }
  }

  /// Infer category from action
  static String _inferCategory(String? action) {
    if (action == null) return 'system_logs';
    
    if (action.startsWith('user')) return 'user_actions';
    if (action.startsWith('admin')) return 'admin_actions';
    if (action.startsWith('robot')) {
      if (action.contains('Cleaning')) return 'cleaning_logs';
      if (action.contains('Disposal')) return 'disposal_logs';
      if (action.contains('Sensor')) return 'sensor_warnings';
      if (action.contains('Connectivity')) return 'connectivity_issues';
      return 'robot_actions';
    }
    if (action.startsWith('schedule')) return 'admin_actions';
    if (action.startsWith('report')) return 'admin_actions';
    if (action.startsWith('system')) return 'system_errors';
    
    return 'system_logs';
  }

  /// Parse risk level from string
  static RiskLevel _parseRiskLevel(String? level) {
    switch (level) {
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      case 'critical':
        return RiskLevel.critical;
      default:
        return RiskLevel.low;
    }
  }

  /// Get risk level color
  Color getRiskColor() {
    switch (riskLevel) {
      case RiskLevel.low:
        return const Color(0xFF00FF88); // Green
      case RiskLevel.medium:
        return const Color(0xFF00D9FF); // Cyan
      case RiskLevel.high:
        return const Color(0xFFFF6B35); // Orange
      case RiskLevel.critical:
        return const Color(0xFFFF3333); // Red
    }
  }

  /// Get risk level text
  String getRiskText() {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }

  /// Automatically determine risk level based on action
  static RiskLevel determineRiskLevel(AuditAction action) {
    switch (action) {
      // Critical risk actions
      case AuditAction.adminDeletedUser:
      case AuditAction.userAccountDeleted:
      case AuditAction.scheduleDeleted:
        return RiskLevel.critical;

      // High risk actions
      case AuditAction.adminCreatedUser:
      case AuditAction.userRoleChanged:
      case AuditAction.userStatusChanged:
      case AuditAction.adminPasswordChanged:
      case AuditAction.userPasswordChanged:
      case AuditAction.configurationChanged:
        return RiskLevel.high;

      // Medium risk actions
      case AuditAction.adminUpdatedUser:
      case AuditAction.scheduleCreated:
      case AuditAction.scheduleUpdated:
      case AuditAction.adminExportedData:
      case AuditAction.reportArchived:
        return RiskLevel.medium;

      // Low risk actions (default)
      default:
        return RiskLevel.low;
    }
  }

  /// Get human-readable action text
  String getActionText() {
    switch (action) {
      // Schedule actions
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
      
      // User management actions
      case AuditAction.userAccountCreated:
        return 'Created User Account';
      case AuditAction.userAccountUpdated:
        return 'Updated User Account';
      case AuditAction.userAccountDeleted:
        return 'Deleted User Account';
      case AuditAction.userStatusChanged:
        return 'Changed User Status';
      case AuditAction.userRoleChanged:
        return 'Changed User Role';
      case AuditAction.userNotified:
        return 'Notified User';
      case AuditAction.userLoggedIn:
        return 'User Logged In';
      case AuditAction.userLoggedOut:
        return 'User Logged Out';
      case AuditAction.userPasswordChanged:
        return 'User Changed Password';
      
      // Admin actions
      case AuditAction.adminLoggedIn:
        return 'Admin Logged In';
      case AuditAction.adminLoggedOut:
        return 'Admin Logged Out';
      case AuditAction.adminPasswordChanged:
        return 'Admin Changed Password';
      case AuditAction.adminCreatedUser:
        return 'Admin Created User';
      case AuditAction.adminUpdatedUser:
        return 'Admin Updated User';
      case AuditAction.adminDeletedUser:
        return 'Admin Deleted User';
      case AuditAction.adminAccessedReports:
        return 'Admin Accessed Reports';
      case AuditAction.adminAccessedLogs:
        return 'Admin Accessed Logs';
      case AuditAction.adminExportedData:
        return 'Admin Exported Data';
      
      // Report actions
      case AuditAction.reportCreated:
        return 'Created Report';
      case AuditAction.reportViewed:
        return 'Viewed Report';
      case AuditAction.reportResolved:
        return 'Resolved Report';
      case AuditAction.reportArchived:
        return 'Archived Report';
      case AuditAction.reportReplied:
        return 'Replied to Report';
      
      // Robot actions
      case AuditAction.robotConnected:
        return 'Robot Connected';
      case AuditAction.robotDisconnected:
        return 'Robot Disconnected';
      case AuditAction.robotCleaningStarted:
        return 'Robot Cleaning Started';
      case AuditAction.robotCleaningCompleted:
        return 'Robot Cleaning Completed';
      case AuditAction.robotDisposalPerformed:
        return 'Robot Disposal Performed';
      case AuditAction.robotSensorWarning:
        return 'Robot Sensor Warning';
      case AuditAction.robotConnectivityIssue:
        return 'Robot Connectivity Issue';
      
      // System actions
      case AuditAction.systemError:
        return 'System Error';
      case AuditAction.systemWarning:
        return 'System Warning';
      case AuditAction.configurationChanged:
        return 'Configuration Changed';
    }
  }
}
