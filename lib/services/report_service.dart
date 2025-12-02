import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import '../models/audit_log_model.dart';
import 'audit_service.dart';

class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'reports';

  static Future<String?> createReport({
    required String title,
    required String category,
    required String description,
    required String submittedBy,
    required String submittedByUid,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final report = ReportModel(
        id: docRef.id,
        title: title,
        category: category,
        status: 'Open',
        description: description,
        submittedBy: submittedBy,
        submittedByUid: submittedByUid,
        submittedDate: DateTime.now().toIso8601String(),
      );

      await docRef.set(report.toJson());
      print('✅ Report created: ${docRef.id}');
      
      // Log report creation
      await AuditService.logReportAction(
        action: AuditAction.reportCreated,
        reportId: docRef.id,
        reportTitle: title,
        actorId: submittedByUid,
        actorName: submittedBy,
        actorType: 'user',
        metadata: {
          'category': category,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      
      return docRef.id;
    } catch (e) {
      print('❌ Error creating report: $e');
      return null;
    }
  }

  static Stream<List<ReportModel>> streamAllReports() {
    return _firestore
        .collection(_collection)
        .orderBy('submittedDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList(),
        );
  }

  static Future<void> markResolved(String id, bool resolved) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': resolved ? 'Resolved' : 'Open',
      });
      print('✅ Report $id marked as ${resolved ? 'Resolved' : 'Open'}');
      
      // Log report resolution
      final reportDoc = await _firestore.collection(_collection).doc(id).get();
      if (reportDoc.exists) {
        final title = reportDoc.data()?['title'] ?? 'Unknown Report';
        await AuditService.logReportAction(
          action: AuditAction.reportResolved,
          reportId: id,
          reportTitle: title,
          metadata: {
            'newStatus': resolved ? 'Resolved' : 'Open',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      print('❌ Error updating report status: $e');
    }
  }

  static Future<void> archive(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'archived': true,
      });
      print('✅ Report $id archived');
      
      // Log report archiving
      final reportDoc = await _firestore.collection(_collection).doc(id).get();
      if (reportDoc.exists) {
        final title = reportDoc.data()?['title'] ?? 'Unknown Report';
        await AuditService.logReportAction(
          action: AuditAction.reportArchived,
          reportId: id,
          reportTitle: title,
          metadata: {
            'archivedAt': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      print('❌ Error archiving report: $e');
    }
  }

  static Future<void> addReply(String id, String reply) async {
    try {
      final reportRef = _firestore.collection(_collection).doc(id);

      // Append reply to report document
      await reportRef.update({
        'replies': FieldValue.arrayUnion([reply]),
      });
      print('✅ Reply added to report $id');

      // Fetch report to know who to notify
      final reportSnap = await reportRef.get();
      if (reportSnap.exists) {
        final data = reportSnap.data() as Map<String, dynamic>;
        final userId = (data['submittedByUid'] ?? '') as String;
        final reportTitle = (data['title'] ?? '') as String;

        if (userId.isNotEmpty) {
          final notificationsRef = _firestore.collection('notifications');
          final notificationId = notificationsRef.doc().id;
          final now = DateTime.now();

          // Create notification data with Firestore Timestamp for createdAt
          final notificationData = {
            'id': notificationId,
            'userId': userId,
            'type': NotificationType.alert.toString().split('.').last,
            'title': 'Reply to your report',
            'message': reply,
            'scheduleId': null,
            'isRead': false,
            'createdAt': Timestamp.fromDate(now), // Use Firestore Timestamp
            'readAt': null,
            'metadata': {'reportId': id, 'reportTitle': reportTitle},
          };

          // Save notification with document ID matching notification ID
          await notificationsRef.doc(notificationId).set(notificationData);
          
          // Verify the notification was saved correctly
          final verifyDoc = await notificationsRef.doc(notificationId).get();
          if (verifyDoc.exists) {
            print('✅ Notification created and verified for report reply to user: $userId');
            print('   Notification ID: $notificationId');
            print('   Document ID: $notificationId');
            print('   Created at: ${now.toIso8601String()}');
            print('   Is Read: ${verifyDoc.data()?['isRead']}');
            print('   User ID: ${verifyDoc.data()?['userId']}');
          } else {
            print('❌ ERROR: Notification was not saved! ID: $notificationId');
          }
        }
      }
      
      // Log reply action
      await AuditService.logReportAction(
        action: AuditAction.reportReplied,
        reportId: id,
        reportTitle: reportSnap.exists ? (reportSnap.data()?['title'] ?? 'Unknown Report') : 'Unknown Report',
        metadata: {
          'replyLength': reply.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('❌ Error adding reply to report: $e');
    }
  }
}
