# Test Examples - Cleaning Schedule System

## Unit Test Examples

### Test Schedule Creation

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:robocleaner/models/cleaning_schedule_model.dart';

void main() {
  group('CleaningSchedule Model Tests', () {
    test('Create schedule with all fields', () {
      final schedule = CleaningSchedule(
        id: 'test_id',
        adminId: 'admin_123',
        assignedUserId: 'user_456',
        title: 'Test Schedule',
        description: 'Test Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
        createdAt: DateTime.now(),
        status: ScheduleStatus.scheduled,
        notes: 'Test notes',
        estimatedDuration: 45,
      );

      expect(schedule.id, 'test_id');
      expect(schedule.title, 'Test Schedule');
      expect(schedule.status, ScheduleStatus.scheduled);
    });

    test('Convert schedule to JSON', () {
      final schedule = CleaningSchedule(
        id: 'test_id',
        adminId: 'admin_123',
        assignedUserId: 'user_456',
        title: 'Test Schedule',
        description: 'Test Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
        createdAt: DateTime.now(),
        status: ScheduleStatus.scheduled,
      );

      final json = schedule.toJson();
      expect(json['id'], 'test_id');
      expect(json['title'], 'Test Schedule');
      expect(json['status'], 'scheduled');
    });

    test('Create schedule from JSON', () {
      final json = {
        'id': 'test_id',
        'adminId': 'admin_123',
        'assignedUserId': 'user_456',
        'title': 'Test Schedule',
        'description': 'Test Description',
        'scheduledDate': '2024-01-20T00:00:00.000Z',
        'scheduledTime': '2024-01-20T10:30:00.000Z',
        'createdAt': '2024-01-19T15:30:00.000Z',
        'status': 'scheduled',
      };

      final schedule = CleaningSchedule.fromJson(json);
      expect(schedule.id, 'test_id');
      expect(schedule.title, 'Test Schedule');
    });

    test('Check if schedule is for today', () {
      final today = DateTime.now();
      final schedule = CleaningSchedule(
        id: 'test_id',
        adminId: 'admin_123',
        title: 'Today Schedule',
        description: 'Test',
        scheduledDate: today,
        scheduledTime: today,
        createdAt: today,
        status: ScheduleStatus.scheduled,
      );

      expect(schedule.isForToday(), true);
    });

    test('Copy schedule with updated fields', () {
      final schedule = CleaningSchedule(
        id: 'test_id',
        adminId: 'admin_123',
        title: 'Original Title',
        description: 'Original Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
        createdAt: DateTime.now(),
        status: ScheduleStatus.scheduled,
      );

      final updated = schedule.copyWith(
        title: 'Updated Title',
        status: ScheduleStatus.inProgress,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.status, ScheduleStatus.inProgress);
      expect(updated.description, 'Original Description');
    });
  });
}
```

### Test Audit Log Model

```dart
void main() {
  group('AuditLog Model Tests', () {
    test('Create audit log', () {
      final log = AuditLog(
        id: 'log_id',
        adminId: 'admin_123',
        adminEmail: 'admin@example.com',
        adminName: 'John Admin',
        action: AuditAction.scheduleCreated,
        description: 'Created schedule',
        scheduleId: 'schedule_123',
        timestamp: DateTime.now(),
      );

      expect(log.id, 'log_id');
      expect(log.action, AuditAction.scheduleCreated);
      expect(log.getActionText(), 'Created Schedule');
    });

    test('Convert audit log to JSON', () {
      final log = AuditLog(
        id: 'log_id',
        adminId: 'admin_123',
        adminEmail: 'admin@example.com',
        adminName: 'John Admin',
        action: AuditAction.scheduleCreated,
        description: 'Created schedule',
        timestamp: DateTime.now(),
      );

      final json = log.toJson();
      expect(json['id'], 'log_id');
      expect(json['action'], 'scheduleCreated');
    });
  });
}
```

### Test Notification Model

```dart
void main() {
  group('UserNotification Model Tests', () {
    test('Create notification', () {
      final notification = UserNotification(
        id: 'notif_id',
        userId: 'user_123',
        type: NotificationType.scheduleAdded,
        title: 'New Schedule',
        message: 'You have a new schedule',
        isRead: false,
        createdAt: DateTime.now(),
      );

      expect(notification.id, 'notif_id');
      expect(notification.type, NotificationType.scheduleAdded);
      expect(notification.isRead, false);
    });

    test('Mark notification as read', () {
      final notification = UserNotification(
        id: 'notif_id',
        userId: 'user_123',
        type: NotificationType.scheduleAdded,
        title: 'New Schedule',
        message: 'You have a new schedule',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final updated = notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );

      expect(updated.isRead, true);
      expect(updated.readAt, isNotNull);
    });
  });
}
```

---

## Integration Test Examples

### Test Schedule Creation Flow

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:robocleaner/services/schedule_service.dart';

void main() {
  setUpAll(() async {
    // Initialize Firebase for testing
    await Firebase.initializeApp();
  });

  group('Schedule Service Integration Tests', () {
    test('Create schedule and verify in Firestore', () async {
      final scheduleId = await ScheduleService.createSchedule(
        adminId: 'test_admin',
        adminEmail: 'admin@test.com',
        adminName: 'Test Admin',
        title: 'Test Schedule',
        description: 'Test Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
        assignedUserId: 'test_user',
      );

      expect(scheduleId, isNotNull);

      // Verify schedule was created
      final schedule = await ScheduleService.getScheduleById(scheduleId!);
      expect(schedule, isNotNull);
      expect(schedule!.title, 'Test Schedule');
    });

    test('Update schedule status', () async {
      // Create schedule
      final scheduleId = await ScheduleService.createSchedule(
        adminId: 'test_admin',
        adminEmail: 'admin@test.com',
        adminName: 'Test Admin',
        title: 'Test Schedule',
        description: 'Test Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
      );

      // Update status
      final updated = await ScheduleService.updateSchedule(
        scheduleId: scheduleId!,
        adminId: 'test_admin',
        adminEmail: 'admin@test.com',
        adminName: 'Test Admin',
        status: ScheduleStatus.inProgress,
      );

      expect(updated, true);

      // Verify update
      final schedule = await ScheduleService.getScheduleById(scheduleId);
      expect(schedule!.status, ScheduleStatus.inProgress);
    });

    test('Delete schedule', () async {
      // Create schedule
      final scheduleId = await ScheduleService.createSchedule(
        adminId: 'test_admin',
        adminEmail: 'admin@test.com',
        adminName: 'Test Admin',
        title: 'Test Schedule',
        description: 'Test Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
      );

      // Delete schedule
      final deleted = await ScheduleService.deleteSchedule(
        scheduleId: scheduleId!,
        adminId: 'test_admin',
        adminEmail: 'admin@test.com',
        adminName: 'Test Admin',
      );

      expect(deleted, true);

      // Verify deletion
      final schedule = await ScheduleService.getScheduleById(scheduleId);
      expect(schedule, isNull);
    });

    test('Verify audit log created', () async {
      // Create schedule
      await ScheduleService.createSchedule(
        adminId: 'test_admin',
        adminEmail: 'admin@test.com',
        adminName: 'Test Admin',
        title: 'Test Schedule',
        description: 'Test Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
      );

      // Get audit logs
      final logs = await ScheduleService.getAuditLogs(limit: 10);
      expect(logs, isNotEmpty);

      // Verify log contains schedule creation
      final creationLog = logs.firstWhere(
        (log) => log.action == AuditAction.scheduleCreated,
        orElse: () => throw Exception('No creation log found'),
      );

      expect(creationLog.adminId, 'test_admin');
      expect(creationLog.description, contains('Test Schedule'));
    });

    test('Verify notification created', () async {
      // Create schedule with assigned user
      await ScheduleService.createSchedule(
        adminId: 'test_admin',
        adminEmail: 'admin@test.com',
        adminName: 'Test Admin',
        title: 'Test Schedule',
        description: 'Test Description',
        scheduledDate: DateTime(2024, 1, 20),
        scheduledTime: DateTime(2024, 1, 20, 10, 30),
        assignedUserId: 'test_user',
      );

      // Get user notifications
      final notifications = await ScheduleService.getUserNotifications('test_user');
      expect(notifications, isNotEmpty);

      // Verify notification
      final notification = notifications.firstWhere(
        (n) => n.type == NotificationType.scheduleAdded,
        orElse: () => throw Exception('No notification found'),
      );

      expect(notification.userId, 'test_user');
      expect(notification.isRead, false);
    });
  });
}
```

---

## Widget Test Examples

### Test Admin Dashboard

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robocleaner/pages/admin_dashboard.dart';

void main() {
  group('AdminDashboard Widget Tests', () {
    testWidgets('Dashboard displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminDashboard(),
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('Dashboard displays sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminDashboard(),
          ),
        ),
      );

      expect(find.text("Today's Cleaning Schedule"), findsOneWidget);
      expect(find.text('Recent Activity Logs'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('Dashboard shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminDashboard(),
          ),
        ),
      );

      // Initially should show loading or empty state
      await tester.pumpAndSettle();

      // Should display either loading spinner or empty message
      expect(
        find.byType(CircularProgressIndicator).or(
          find.text('No cleaning schedule for today'),
        ),
        findsWidgets,
      );
    });
  });
}
```

---

## Manual Testing Checklist

### Schedule Creation
- [ ] Admin can create schedule with all fields
- [ ] Schedule appears in Firestore console
- [ ] Audit log created for schedule creation
- [ ] Notification created for assigned user
- [ ] Admin dashboard updates in real-time
- [ ] User receives notification

### Schedule Update
- [ ] Admin can update schedule status
- [ ] Audit log created for update
- [ ] Dashboard updates in real-time
- [ ] User sees updated schedule

### Schedule Deletion
- [ ] Admin can delete schedule
- [ ] Schedule removed from Firestore
- [ ] Audit log created for deletion
- [ ] Dashboard updates in real-time

### Audit Logs
- [ ] All admin actions logged
- [ ] Logs display correctly in dashboard
- [ ] Logs show correct timestamp
- [ ] Logs show correct admin info
- [ ] Real-time updates work

### Notifications
- [ ] Notifications created for new schedules
- [ ] Notifications display in user view
- [ ] Users can mark as read
- [ ] Read status updates in Firestore
- [ ] Real-time updates work

### Error Handling
- [ ] Network error shows error message
- [ ] Invalid data shows error
- [ ] Missing fields show error
- [ ] Firestore rules violations show error
- [ ] UI recovers gracefully

---

## Performance Testing

### Load Test: Create 100 Schedules

```dart
Future<void> loadTestScheduleCreation() async {
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < 100; i++) {
    await ScheduleService.createSchedule(
      adminId: 'admin_123',
      adminEmail: 'admin@example.com',
      adminName: 'Test Admin',
      title: 'Schedule $i',
      description: 'Test schedule $i',
      scheduledDate: DateTime.now().add(Duration(days: i)),
      scheduledTime: DateTime.now().add(Duration(days: i, hours: 10)),
      assignedUserId: 'user_${i % 10}',
    );
  }

  stopwatch.stop();
  print('Created 100 schedules in ${stopwatch.elapsedMilliseconds}ms');
  print('Average: ${stopwatch.elapsedMilliseconds / 100}ms per schedule');
}
```

### Load Test: Stream 100 Schedules

```dart
Future<void> loadTestStreamSchedules() async {
  final stopwatch = Stopwatch()..start();

  final stream = ScheduleService.streamTodaySchedules();
  var count = 0;

  stream.listen((schedules) {
    count = schedules.length;
  });

  await Future.delayed(Duration(seconds: 5));
  stopwatch.stop();

  print('Streamed $count schedules in ${stopwatch.elapsedMilliseconds}ms');
}
```

---

## Test Data Setup

### Create Test Admin

```dart
Future<void> setupTestAdmin() async {
  await FirestoreVerificationService.createTestAdminAccount(
    uid: 'test_admin_123',
    email: 'admin@test.com',
    name: 'Test Admin',
  );
}
```

### Create Test Users

```dart
Future<void> setupTestUsers() async {
  for (int i = 1; i <= 5; i++) {
    await FirestoreVerificationService.createTestUserAccount(
      uid: 'test_user_$i',
      email: 'user$i@test.com',
      name: 'Test User $i',
    );
  }
}
```

### Create Test Schedules

```dart
Future<void> setupTestSchedules() async {
  for (int i = 1; i <= 10; i++) {
    await ScheduleService.createSchedule(
      adminId: 'test_admin_123',
      adminEmail: 'admin@test.com',
      adminName: 'Test Admin',
      title: 'Test Schedule $i',
      description: 'Test schedule description $i',
      scheduledDate: DateTime.now().add(Duration(days: i)),
      scheduledTime: DateTime.now().add(Duration(days: i, hours: 10 + i)),
      assignedUserId: 'test_user_${(i % 5) + 1}',
    );
  }
}
```

---

## Debugging Tips

### Enable Firestore Logging

```dart
// In main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Firestore logging
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### Monitor Firestore Operations

```dart
// Add this to ScheduleService for debugging
static Future<void> debugGetAllSchedules() async {
  try {
    final snapshot = await _firestore.collection('schedules').get();
    print('Total schedules: ${snapshot.docs.length}');
    
    for (var doc in snapshot.docs) {
      print('Schedule: ${doc.id}');
      print('  Title: ${doc['title']}');
      print('  Status: ${doc['status']}');
      print('  Date: ${doc['scheduledDate']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Monitor Real-time Updates

```dart
// Subscribe to stream and log updates
ScheduleService.streamTodaySchedules().listen(
  (schedules) {
    print('Schedules updated: ${schedules.length} schedules');
    for (var schedule in schedules) {
      print('  - ${schedule.title} (${schedule.status})');
    }
  },
  onError: (error) {
    print('Stream error: $error');
  },
);
```
