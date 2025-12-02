import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cleaning_schedule_model.dart';
import '../models/audit_log_model.dart';
import '../models/notification_model.dart';
import 'audit_service.dart';

class ScheduleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test Firebase setup and connectivity
  static Future<void> testFirebaseSetup() async {
    print('🧪 Testing Firebase setup...');

    // Test 1: Authentication
    final user = FirebaseAuth.instance.currentUser;
    print(
      'Auth: ${user != null ? "✅" : "❌"} User: ${user?.email} (${user?.uid})',
    );

    if (user == null) {
      print('❌ CRITICAL: User not authenticated. Please log in first.');
      return;
    }

    // Test 2: Connection
    try {
      await _firestore.collection('test').limit(1).get();
      print('Connection: ✅ Firebase reachable');
    } catch (e) {
      print('Connection: ❌ $e');
      return;
    }

    // Test 3: Collections exist and are writable
    try {
      final schedulesRef = _firestore.collection('schedules');
      final schedules = await schedulesRef.limit(1).get();
      print('Schedules collection: ✅ Exists (${schedules.docs.length} docs)');

      // Test write permission
      try {
        await schedulesRef.doc('test_doc').set({'test': true});
        await schedulesRef.doc('test_doc').delete();
        print('Schedules write: ✅ Can write to collection');
      } catch (e) {
        print('Schedules write: ❌ Cannot write: $e');
      }
    } catch (e) {
      print('Schedules collection: ❌ $e');
    }

    try {
      final logsRef = _firestore.collection('audit_logs');
      final logs = await logsRef.limit(1).get();
      print('Audit logs collection: ✅ Exists (${logs.docs.length} docs)');

      // Test write permission
      try {
        await logsRef.doc('test_doc').set({'test': true});
        await logsRef.doc('test_doc').delete();
        print('Audit logs write: ✅ Can write to collection');
      } catch (e) {
        print('Audit logs write: ❌ Cannot write: $e');
      }
    } catch (e) {
      print('Audit logs collection: ❌ $e');
    }

    try {
      final notificationsRef = _firestore.collection('notifications');
      final notifications = await notificationsRef.limit(1).get();
      print(
        'Notifications collection: ✅ Exists (${notifications.docs.length} docs)',
      );

      // Test write permission
      try {
        await notificationsRef.doc('test_doc').set({'test': true});
        await notificationsRef.doc('test_doc').delete();
        print('Notifications write: ✅ Can write to collection');
      } catch (e) {
        print('Notifications write: ❌ Cannot write: $e');
      }
    } catch (e) {
      print('Notifications collection: ❌ $e');
    }

    print('🧪 Firebase test complete!');
  }

  /// Create a new cleaning schedule
  /// Returns the schedule ID if successful
  static Future<String?> createSchedule({
    required String adminId,
    required String adminEmail,
    required String adminName,
    required String title,
    required String description,
    required DateTime scheduledDate,
    required DateTime scheduledTime,
    String? assignedUserId,
    String? notes,
    int? estimatedDuration,
  }) async {
    try {
      final scheduleId = _firestore.collection('schedules').doc().id;
      final now = DateTime.now();

      final schedule = CleaningSchedule(
        id: scheduleId,
        adminId: adminId,
        assignedUserId: assignedUserId,
        title: title,
        description: description,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        createdAt: now,
        status: ScheduleStatus.scheduled,
        notes: notes,
        estimatedDuration: estimatedDuration,
      );

      // Save schedule to Firestore
      await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .set(schedule.toJson());

      // Log the action
      await AuditService.logScheduleCreated(
        scheduleId: scheduleId,
        scheduleName: title,
        actorId: adminId,
        actorName: adminName,
        scheduleData: {
          'description': description,
          'scheduledDate': scheduledDate.toIso8601String(),
          'scheduledTime': scheduledTime.toIso8601String(),
          'assignedUserId': assignedUserId,
        },
      );

      // Create notification for assigned user if applicable
      if (assignedUserId != null) {
        await _createNotification(
          userId: assignedUserId,
          type: NotificationType.scheduleAdded,
          title: 'New Cleaning Schedule',
          message: 'Admin $adminName has scheduled a cleaning: $title',
          scheduleId: scheduleId,
        );

        // Log the notification action
        await AuditService.log(
          action: AuditAction.userNotified,
          description: 'Notified user about new schedule: $title',
          actorId: adminId,
          actorName: adminName,
          actorType: 'admin',
          scheduleId: scheduleId,
          affectedUserId: assignedUserId,
        );
      }

      print('✅ Schedule created successfully: $scheduleId');
      return scheduleId;
    } catch (e) {
      print('❌ Error creating schedule: $e');
      return null;
    }
  }

  /// Update an existing schedule
  static Future<bool> updateSchedule({
    required String scheduleId,
    required String adminId,
    required String adminEmail,
    required String adminName,
    String? title,
    String? description,
    DateTime? scheduledDate,
    DateTime? scheduledTime,
    ScheduleStatus? status,
    String? notes,
    int? estimatedDuration,
  }) async {
    try {
      // Get current schedule
      final currentDoc = await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .get();
      if (!currentDoc.exists) {
        print('❌ Schedule not found: $scheduleId');
        return false;
      }

      final currentSchedule = CleaningSchedule.fromJson(currentDoc.data()!);

      // Update schedule
      final updatedSchedule = currentSchedule.copyWith(
        title: title,
        description: description,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        status: status,
        notes: notes,
        estimatedDuration: estimatedDuration,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .update(updatedSchedule.toJson());

      // Log the action
      await AuditService.logScheduleUpdated(
        scheduleId: scheduleId,
        scheduleName: title ?? currentSchedule.title,
        actorId: adminId,
        actorName: adminName,
        changes: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (scheduledDate != null) 'scheduledDate': scheduledDate.toIso8601String(),
          if (scheduledTime != null) 'scheduledTime': scheduledTime.toIso8601String(),
          if (status != null) 'status': status.toString().split('.').last,
        },
      );

      print('✅ Schedule updated successfully: $scheduleId');
      return true;
    } catch (e) {
      print('❌ Error updating schedule: $e');
      return false;
    }
  }

  /// Delete a schedule
  static Future<bool> deleteSchedule({
    required String scheduleId,
    required String adminId,
    required String adminEmail,
    required String adminName,
  }) async {
    try {
      // Get schedule before deleting
      final doc = await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .get();
      if (!doc.exists) {
        print('❌ Schedule not found: $scheduleId');
        return false;
      }

      final schedule = CleaningSchedule.fromJson(doc.data()!);

      // Delete schedule
      await _firestore.collection('schedules').doc(scheduleId).delete();

      // Log the action
      await AuditService.logScheduleDeleted(
        scheduleId: scheduleId,
        scheduleName: schedule.title,
        actorId: adminId,
        actorName: adminName,
      );

      print('✅ Schedule deleted successfully: $scheduleId');
      return true;
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      return false;
    }
  }

  /// Get all schedules for today
  static Future<List<CleaningSchedule>> getTodaySchedules() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('schedules')
          .where(
            'scheduledDate',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where(
            'scheduledDate',
            isLessThanOrEqualTo: endOfDay.toIso8601String(),
          )
          .orderBy('scheduledDate')
          .get();

      return snapshot.docs
          .map((doc) => CleaningSchedule.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching today schedules: $e');
      return [];
    }
  }

  /// Get schedules for a specific user
  static Future<List<CleaningSchedule>> getUserSchedules(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('schedules')
          .where('assignedUserId', isEqualTo: userId)
          .orderBy('scheduledDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CleaningSchedule.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching user schedules: $e');
      return [];
    }
  }

  /// Get all schedules (admin view)
  static Future<List<CleaningSchedule>> getAllSchedules() async {
    try {
      final snapshot = await _firestore
          .collection('schedules')
          .orderBy('scheduledDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CleaningSchedule.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching all schedules: $e');
      return [];
    }
  }

  /// Get a single schedule by ID
  static Future<CleaningSchedule?> getScheduleById(String scheduleId) async {
    try {
      final doc = await _firestore
          .collection('schedules')
          .doc(scheduleId)
          .get();
      if (!doc.exists) return null;
      return CleaningSchedule.fromJson(doc.data()!);
    } catch (e) {
      print('❌ Error fetching schedule: $e');
      return null;
    }
  }

  /// Stream today's schedules (real-time updates)
  static Stream<List<CleaningSchedule>> streamTodaySchedules() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('schedules')
        .where(
          'scheduledDate',
          isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
        )
        .where('scheduledDate', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .orderBy('scheduledDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CleaningSchedule.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Stream user schedules (real-time updates)
  static Stream<List<CleaningSchedule>> streamUserSchedules(String userId) {
    return _firestore
        .collection('schedules')
        .where('assignedUserId', isEqualTo: userId)
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CleaningSchedule.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Stream all schedules (admin view - real-time updates)
  static Stream<List<CleaningSchedule>> streamAllSchedules() {
    return _firestore
        .collection('schedules')
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CleaningSchedule.fromJson(doc.data()))
              .toList(),
        );
  }


  /// Create notification for user
  static Future<void> _createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? scheduleId,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final now = DateTime.now();
      
      // Create notification data with Firestore Timestamp for createdAt
      final notificationData = {
        'id': notificationId,
        'userId': userId,
        'type': type.toString().split('.').last,
        'title': title,
        'message': message,
        'scheduleId': scheduleId,
        'isRead': false,
        'createdAt': Timestamp.fromDate(now), // Use Firestore Timestamp
        'readAt': null,
      };

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notificationData);

      print('✅ Notification created for user: $userId');
    } catch (e) {
      print('❌ Error creating notification: $e');
    }
  }

  /// Get audit logs for admin
  static Future<List<AuditLog>> getAuditLogs({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => AuditLog.fromJson(doc.data())).toList();
    } catch (e) {
      print('❌ Error fetching audit logs: $e');
      return [];
    }
  }

  /// Stream audit logs (real-time updates)
  static Stream<List<AuditLog>> streamAuditLogs({int limit = 50}) {
    return _firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLog.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get notifications for user
  static Future<List<UserNotification>> getUserNotifications(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            // Convert Firestore Timestamp to ISO string for UserNotification model
            final createdAtValue = data['createdAt'];
            String? createdAtString;
            
            if (createdAtValue is Timestamp) {
              createdAtString = createdAtValue.toDate().toIso8601String();
            } else if (createdAtValue is String) {
              createdAtString = createdAtValue;
            } else {
              createdAtString = DateTime.now().toIso8601String();
            }
            
            // Convert readAt if it exists
            final readAtValue = data['readAt'];
            String? readAtString;
            if (readAtValue is Timestamp) {
              readAtString = readAtValue.toDate().toIso8601String();
            } else if (readAtValue is String) {
              readAtString = readAtValue;
            }
            
            // Use Firestore document ID as the notification ID
            return UserNotification.fromJson({
              ...data,
              'id': doc.id,
              'createdAt': createdAtString,
              if (readAtString != null) 'readAt': readAtString,
            });
          })
          .toList();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  /// Stream user notifications (real-time updates)
  static Stream<List<UserNotification>> streamUserNotifications(
    String userId, {
    int limit = 50,
  }) {
    try {
      // Query with orderBy (requires composite index: userId + createdAt)
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) {
              try {
                final notifications = _parseNotifications(snapshot.docs, userId);
                
                print('📬 Stream returned ${notifications.length} notifications for user: $userId');
                if (notifications.isNotEmpty) {
                  print('   First notification: ${notifications.first.title} (read: ${notifications.first.isRead}, id: ${notifications.first.id})');
                }
                return notifications;
              } catch (e) {
                print('❌ Error processing notification stream: $e');
                return <UserNotification>[];
              }
            },
          )
          .handleError((error) {
            print('❌ Error in notification stream: $error');
            print('   User ID: $userId');
            print('   Error type: ${error.runtimeType}');
            print('   ⚠️ This might be due to missing composite index!');
            print('   ⚠️ Create index: notifications collection');
            print('   ⚠️ Fields: userId (Ascending) + createdAt (Descending)');
            // Return empty list on error
            return <UserNotification>[];
          });
    } catch (e) {
      print('❌ Error creating notification stream: $e');
      // Return an empty stream on error
      return Stream.value(<UserNotification>[]);
    }
  }

  /// Helper method to parse notification documents
  static List<UserNotification> _parseNotifications(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String userId,
  ) {
    return docs
        .map((doc) {
          try {
            final data = doc.data();
            // Convert Firestore Timestamp to ISO string for UserNotification model
            final createdAtValue = data['createdAt'];
            String? createdAtString;
            
            if (createdAtValue is Timestamp) {
              createdAtString = createdAtValue.toDate().toIso8601String();
            } else if (createdAtValue is String) {
              createdAtString = createdAtValue;
            } else {
              createdAtString = DateTime.now().toIso8601String();
            }
            
            // Convert readAt if it exists
            final readAtValue = data['readAt'];
            String? readAtString;
            if (readAtValue is Timestamp) {
              readAtString = readAtValue.toDate().toIso8601String();
            } else if (readAtValue is String) {
              readAtString = readAtValue;
            }
            
            // Use Firestore document ID as the notification ID to ensure consistency
            final notification = UserNotification.fromJson({
              ...data,
              'id': doc.id, // Always use the document ID
              'createdAt': createdAtString,
              if (readAtString != null) 'readAt': readAtString,
            });
            
            return notification;
          } catch (e) {
            print('❌ Error parsing notification document ${doc.id}: $e');
            print('   Document data: ${doc.data()}');
            return null;
          }
        })
        .where((n) => n != null)
        .cast<UserNotification>()
        .toList();
  }

  /// Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()), // Use Firestore Timestamp
      });
      return true;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      print('   Notification ID: $notificationId');
      return false;
    }
  }
}
