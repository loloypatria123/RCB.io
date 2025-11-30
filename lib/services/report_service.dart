import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';

class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'reports';

  /// Create a new report
  static Future<String?> createReport({
    required String userId,
    required String userEmail,
    required String userName,
    required String title,
    required String description,
    required ReportCategory category,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ ReportService: User not authenticated');
        return null;
      }

      final reportId = _firestore.collection(_collectionName).doc().id;
      final now = DateTime.now();

      final report = Report(
        id: reportId,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        title: title,
        description: description,
        category: category,
        status: ReportStatus.open,
        createdAt: now,
      );

      await _firestore
          .collection(_collectionName)
          .doc(reportId)
          .set(report.toJson());

      print('✅ Report created: $reportId');
      return reportId;
    } catch (e) {
      print('❌ Error creating report: $e');
      return null;
    }
  }

  /// Get all reports (for admin)
  static Stream<List<Report>> getAllReports() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Report.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get reports by user ID
  static Stream<List<Report>> getUserReports(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Report.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get a single report by ID
  static Future<Report?> getReportById(String reportId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(reportId)
          .get();

      if (doc.exists) {
        return Report.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting report: $e');
      return null;
    }
  }

  /// Update report status and notify user if resolved
  static Future<bool> updateReportStatus(
    String reportId,
    ReportStatus status,
  ) async {
    try {
      final report = await getReportById(reportId);
      if (report == null) {
        print('❌ Report not found: $reportId');
        return false;
      }

      final updates = <String, dynamic>{
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (status == ReportStatus.resolved) {
        updates['resolvedAt'] = DateTime.now().toIso8601String();
        
        // Create notification for the user when report is resolved
        await _createNotification(
          userId: report.userId,
          type: NotificationType.reportResolved,
          title: 'Report Resolved',
          message: 'Your report "${report.title}" has been marked as resolved.',
          reportId: reportId,
        );
      }

      await _firestore
          .collection(_collectionName)
          .doc(reportId)
          .update(updates);

      print('✅ Report status updated: $reportId -> $status');
      return true;
    } catch (e) {
      print('❌ Error updating report status: $e');
      return false;
    }
  }

  /// Archive a report
  static Future<bool> archiveReport(String reportId) async {
    try {
      await _firestore.collection(_collectionName).doc(reportId).update({
        'archived': true,
        'status': ReportStatus.archived.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Report archived: $reportId');
      return true;
    } catch (e) {
      print('❌ Error archiving report: $e');
      return false;
    }
  }

  /// Add a reply to a report and notify the user
  static Future<bool> addReply({
    required String reportId,
    required String adminId,
    required String adminName,
    required String adminEmail,
    required String message,
  }) async {
    try {
      final report = await getReportById(reportId);
      if (report == null) {
        print('❌ Report not found: $reportId');
        return false;
      }

      final replyId = _firestore.collection('temp').doc().id;
      final reply = ReportReply(
        id: replyId,
        adminId: adminId,
        adminName: adminName,
        adminEmail: adminEmail,
        message: message,
        createdAt: DateTime.now(),
      );

      final updatedReplies = [...report.replies, reply];

      await _firestore.collection(_collectionName).doc(reportId).update({
        'replies': updatedReplies.map((r) => r.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Create notification for the user
      await _createNotification(
        userId: report.userId,
        type: NotificationType.reportReply,
        title: 'Admin Reply to Your Report',
        message: 'Admin $adminName replied to your report: "${report.title}". Reply: $message',
        reportId: reportId,
      );

      print('✅ Reply added to report: $reportId');
      return true;
    } catch (e) {
      print('❌ Error adding reply: $e');
      return false;
    }
  }

  /// Delete a report
  static Future<bool> deleteReport(String reportId) async {
    try {
      await _firestore.collection(_collectionName).doc(reportId).delete();
      print('✅ Report deleted: $reportId');
      return true;
    } catch (e) {
      print('❌ Error deleting report: $e');
      return false;
    }
  }

  /// Get reports by status
  static Stream<List<Report>> getReportsByStatus(ReportStatus status) {
    final statusString = status.toString().split('.').last;
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: statusString)
        .where('archived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Report.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get reports by category
  static Stream<List<Report>> getReportsByCategory(ReportCategory category) {
    final categoryString = category.toString().split('.').last;
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: categoryString)
        .where('archived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Report.fromJson(doc.data()))
          .toList();
    });
  }

  /// Create notification for user
  static Future<void> _createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? reportId,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = UserNotification(
        id: notificationId,
        userId: userId,
        type: type,
        title: title,
        message: message,
        scheduleId: null, // Not used for reports
        isRead: false,
        createdAt: DateTime.now(),
        metadata: reportId != null ? {'reportId': reportId} : null,
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());

      print('✅ Notification created for user: $userId');
    } catch (e) {
      print('❌ Error creating notification: $e');
    }
  }
}

