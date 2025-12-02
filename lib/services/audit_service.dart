import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';
import 'dart:math' show Random;

class AuditService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Session tracking
  static String? _currentSessionId;
  static DateTime? _sessionStartTime;

  /// Initialize or get current session ID
  static String _getSessionId() {
    if (_currentSessionId == null || _sessionStartTime == null ||
        DateTime.now().difference(_sessionStartTime!).inHours > 8) {
      _currentSessionId = _generateSessionId();
      _sessionStartTime = DateTime.now();
    }
    return _currentSessionId!;
  }

  /// Generate a unique session ID
  static String _generateSessionId() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomStr = List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
    return 'sess_${timestamp}_$randomStr';
  }

  /// Log an action to the audit trail (Enhanced with professional features)
  static Future<void> log({
    required AuditAction action,
    required String description,
    String? actorId,
    String? actorEmail,
    String? actorName,
    String? actorType,
    String? scheduleId,
    String? affectedUserId,
    String? affectedResourceId,
    Map<String, dynamic>? metadata,
    String? category,
    String? ipAddress,
    String? userAgent,
    RiskLevel? riskLevel,
    Map<String, dynamic>? changesBefore,
    Map<String, dynamic>? changesAfter,
    bool success = true,
    String? errorMessage,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // Generate unique ID
      final logId = _firestore.collection('audit_logs').doc().id;
      
      // Get current user if actor details not provided
      String finalActorId = actorId ?? _auth.currentUser?.uid ?? 'system';
      String finalActorEmail = actorEmail ?? _auth.currentUser?.email ?? 'system';
      String finalActorName = actorName ?? 'System';
      String finalActorType = actorType ?? 'system';
      
      // If we have a current user but no actor name, try to fetch it
      if (actorName == null && _auth.currentUser != null) {
        try {
          final userData = await _getUserData(_auth.currentUser!.uid);
          if (userData != null) {
            finalActorName = userData['name'] ?? 'Unknown User';
            finalActorType = userData['role'] ?? 'user';
          }
        } catch (e) {
          print('⚠️ Could not fetch user data for audit log: $e');
        }
      }

      // Infer category if not provided
      final finalCategory = category ?? _inferCategoryFromAction(action);
      
      // Determine risk level automatically if not provided
      final finalRiskLevel = riskLevel ?? AuditLog.determineRiskLevel(action);
      
      // Get session ID
      final sessionId = _getSessionId();
      
      // Calculate execution time
      final executionTime = DateTime.now().difference(startTime).inMilliseconds;

      // Create enhanced audit log
      final auditLog = AuditLog(
        id: logId,
        actorId: finalActorId,
        actorEmail: finalActorEmail,
        actorName: finalActorName,
        actorType: finalActorType,
        action: action,
        description: description,
        scheduleId: scheduleId,
        affectedUserId: affectedUserId,
        affectedResourceId: affectedResourceId,
        timestamp: DateTime.now(),
        metadata: metadata,
        category: finalCategory,
        ipAddress: ipAddress ?? 'N/A',
        userAgent: userAgent ?? 'Web Browser',
        sessionId: sessionId,
        riskLevel: finalRiskLevel,
        changesBefore: changesBefore,
        changesAfter: changesAfter,
        executionTimeMs: executionTime,
        success: success,
        errorMessage: errorMessage,
      );

      // Save to Firestore
      await _firestore
          .collection('audit_logs')
          .doc(logId)
          .set(auditLog.toJson());

      print('✅ Audit log created: ${action.toString().split('.').last} [${finalRiskLevel.toString().split('.').last.toUpperCase()}]');
    } catch (e) {
      print('❌ Error creating audit log: $e');
      // Don't throw error to avoid breaking the main flow
    }
  }

  /// Log user login
  static Future<void> logUserLogin(UserModel user) async {
    await log(
      action: user.role == UserRole.admin
          ? AuditAction.adminLoggedIn
          : AuditAction.userLoggedIn,
      description: '${user.name} logged in',
      actorId: user.uid,
      actorEmail: user.email,
      actorName: user.name,
      actorType: user.role == UserRole.admin ? 'admin' : 'user',
      metadata: {
        'loginTime': DateTime.now().toIso8601String(),
        'userAgent': 'web',
      },
    );
  }

  /// Log user logout
  static Future<void> logUserLogout(UserModel user) async {
    await log(
      action: user.role == UserRole.admin
          ? AuditAction.adminLoggedOut
          : AuditAction.userLoggedOut,
      description: '${user.name} logged out',
      actorId: user.uid,
      actorEmail: user.email,
      actorName: user.name,
      actorType: user.role == UserRole.admin ? 'admin' : 'user',
      metadata: {
        'logoutTime': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log schedule creation
  static Future<void> logScheduleCreated({
    required String scheduleId,
    required String scheduleName,
    String? actorId,
    String? actorName,
    Map<String, dynamic>? scheduleData,
  }) async {
    await log(
      action: AuditAction.scheduleCreated,
      description: 'Created schedule: $scheduleName',
      actorId: actorId,
      actorName: actorName,
      actorType: 'admin',
      scheduleId: scheduleId,
      metadata: scheduleData,
      category: 'admin_actions',
    );
  }

  /// Log schedule update
  static Future<void> logScheduleUpdated({
    required String scheduleId,
    required String scheduleName,
    String? actorId,
    String? actorName,
    Map<String, dynamic>? changes,
  }) async {
    await log(
      action: AuditAction.scheduleUpdated,
      description: 'Updated schedule: $scheduleName',
      actorId: actorId,
      actorName: actorName,
      actorType: 'admin',
      scheduleId: scheduleId,
      metadata: changes,
      category: 'admin_actions',
    );
  }

  /// Log schedule deletion
  static Future<void> logScheduleDeleted({
    required String scheduleId,
    required String scheduleName,
    String? actorId,
    String? actorName,
  }) async {
    await log(
      action: AuditAction.scheduleDeleted,
      description: 'Deleted schedule: $scheduleName',
      actorId: actorId,
      actorName: actorName,
      actorType: 'admin',
      scheduleId: scheduleId,
      category: 'admin_actions',
    );
  }

  /// Log report action
  static Future<void> logReportAction({
    required AuditAction action,
    required String reportId,
    required String reportTitle,
    String? actorId,
    String? actorName,
    String? actorType,
    Map<String, dynamic>? metadata,
  }) async {
    await log(
      action: action,
      description: '${action.toString().split('.').last} report: $reportTitle',
      actorId: actorId,
      actorName: actorName,
      actorType: actorType ?? 'admin',
      affectedResourceId: reportId,
      metadata: metadata,
      category: 'admin_actions',
    );
  }

  /// Log user management action
  static Future<void> logUserManagement({
    required AuditAction action,
    required String targetUserId,
    required String targetUserName,
    String? actorId,
    String? actorName,
    Map<String, dynamic>? changes,
  }) async {
    await log(
      action: action,
      description: '${action.toString().split('.').last}: $targetUserName',
      actorId: actorId,
      actorName: actorName,
      actorType: 'admin',
      affectedUserId: targetUserId,
      metadata: changes,
      category: 'admin_actions',
    );
  }

  /// Log admin accessing sensitive areas
  static Future<void> logAdminAccess({
    required AuditAction action,
    required String area,
    String? actorId,
    String? actorName,
  }) async {
    await log(
      action: action,
      description: 'Accessed $area',
      actorId: actorId,
      actorName: actorName,
      actorType: 'admin',
      metadata: {
        'accessTime': DateTime.now().toIso8601String(),
        'area': area,
      },
      category: 'admin_actions',
    );
  }

  /// Log data export
  static Future<void> logDataExport({
    required String dataType,
    required String format,
    int? recordCount,
    String? actorId,
    String? actorName,
  }) async {
    await log(
      action: AuditAction.adminExportedData,
      description: 'Exported $dataType as $format',
      actorId: actorId,
      actorName: actorName,
      actorType: 'admin',
      metadata: {
        'dataType': dataType,
        'format': format,
        'recordCount': recordCount,
        'exportTime': DateTime.now().toIso8601String(),
      },
      category: 'admin_actions',
    );
  }

  /// Log robot action
  static Future<void> logRobotAction({
    required AuditAction action,
    required String robotId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    await log(
      action: action,
      description: description ?? action.toString().split('.').last,
      actorId: robotId,
      actorName: 'Robot $robotId',
      actorType: 'robot',
      metadata: metadata,
      category: _inferCategoryFromAction(action),
    );
  }

  /// Log system event
  static Future<void> logSystemEvent({
    required AuditAction action,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    await log(
      action: action,
      description: description,
      actorId: 'system',
      actorName: 'System',
      actorType: 'system',
      metadata: metadata,
      category: 'system_errors',
    );
  }

  /// Stream audit logs
  static Stream<List<AuditLog>> streamAuditLogs({
    int? limit,
    String? category,
    String? actorType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    if (actorType != null && actorType != 'All') {
      query = query.where('actorType', isEqualTo: actorType);
    }

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query =
          query.where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AuditLog.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get audit logs for a specific user
  static Future<List<AuditLog>> getUserAuditLogs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('audit_logs')
          .where('actorId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        return AuditLog.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching user audit logs: $e');
      return [];
    }
  }

  /// Get audit logs for a specific resource
  static Future<List<AuditLog>> getResourceAuditLogs(String resourceId) async {
    try {
      final snapshot = await _firestore
          .collection('audit_logs')
          .where('affectedResourceId', isEqualTo: resourceId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        return AuditLog.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching resource audit logs: $e');
      return [];
    }
  }

  /// Get statistics
  static Future<Map<String, int>> getAuditStats() async {
    try {
      final snapshot = await _firestore.collection('audit_logs').get();
      
      final stats = <String, int>{
        'total': snapshot.docs.length,
        'today': 0,
        'user_actions': 0,
        'admin_actions': 0,
        'robot_actions': 0,
        'system_errors': 0,
      };

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String?;
        final timestamp = data['timestamp'] as String?;

        if (category != null) {
          stats[category] = (stats[category] ?? 0) + 1;
        }

        if (timestamp != null) {
          final logDate = DateTime.parse(timestamp);
          if (logDate.isAfter(todayStart)) {
            stats['today'] = stats['today']! + 1;
          }
        }
      }

      return stats;
    } catch (e) {
      print('❌ Error fetching audit stats: $e');
      return {
        'total': 0,
        'today': 0,
        'user_actions': 0,
        'admin_actions': 0,
        'robot_actions': 0,
        'system_errors': 0,
      };
    }
  }

  /// Helper: Get user data
  static Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      // Check admins first
      var doc = await _firestore.collection('admins').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }

      // Check users
      doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }

      return null;
    } catch (e) {
      print('❌ Error fetching user data: $e');
      return null;
    }
  }

  /// Helper: Infer category from action
  static String _inferCategoryFromAction(AuditAction action) {
    final actionStr = action.toString().split('.').last;
    
    if (actionStr.startsWith('user')) return 'user_actions';
    if (actionStr.startsWith('admin')) return 'admin_actions';
    if (actionStr.startsWith('robot')) {
      if (actionStr.contains('Cleaning')) return 'cleaning_logs';
      if (actionStr.contains('Disposal')) return 'disposal_logs';
      if (actionStr.contains('Sensor')) return 'sensor_warnings';
      if (actionStr.contains('Connectivity')) return 'connectivity_issues';
      return 'robot_actions';
    }
    if (actionStr.startsWith('schedule')) return 'admin_actions';
    if (actionStr.startsWith('report')) return 'admin_actions';
    if (actionStr.startsWith('system')) return 'system_errors';
    
    return 'system_logs';
  }
}

