# Implementation Guide - Cleaning Schedule System

## Quick Start

### 1. Models Created
- **`lib/models/cleaning_schedule_model.dart`** - Schedule data model
- **`lib/models/audit_log_model.dart`** - Audit log data model
- **`lib/models/notification_model.dart`** - Notification data model

### 2. Service Created
- **`lib/services/schedule_service.dart`** - All Firebase operations for schedules, logs, and notifications

### 3. UI Updated
- **`lib/pages/admin_dashboard.dart`** - Now displays real-time schedules and audit logs

---

## How to Use

### For Admin: Creating a Schedule

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'services/schedule_service.dart';

// Get current admin
final currentUser = FirebaseAuth.instance.currentUser;

// Create schedule
final scheduleId = await ScheduleService.createSchedule(
  adminId: currentUser!.uid,
  adminEmail: currentUser.email!,
  adminName: 'Admin Name', // Get from user profile
  title: 'Living Room Cleaning',
  description: 'Deep clean with vacuum and mop',
  scheduledDate: DateTime(2024, 1, 20),
  scheduledTime: DateTime(2024, 1, 20, 10, 30),
  assignedUserId: 'user_uid_here',
  notes: 'Use eco-friendly solution',
  estimatedDuration: 45,
);

if (scheduleId != null) {
  print('Schedule created: $scheduleId');
  // Show success message to user
} else {
  print('Failed to create schedule');
  // Show error message to user
}
```

**What happens automatically:**
1. ✅ Schedule saved to `schedules` collection
2. ✅ Action logged to `audit_logs` collection
3. ✅ Notification created in `notifications` collection
4. ✅ User receives notification in their app

---

### For Admin: Viewing Today's Schedules

The admin dashboard automatically streams today's schedules:

```dart
// In admin_dashboard.dart
StreamBuilder<List<CleaningSchedule>>(
  stream: _todaySchedulesStream,
  builder: (context, snapshot) {
    // Displays real-time schedules
  },
)
```

---

### For Admin: Viewing Activity Logs

The admin dashboard automatically streams recent activity logs:

```dart
// In admin_dashboard.dart
StreamBuilder<List<AuditLog>>(
  stream: _auditLogsStream,
  builder: (context, snapshot) {
    // Displays real-time audit logs
  },
)
```

---

### For User: Viewing Assigned Schedules

```dart
import 'services/schedule_service.dart';

// Get user's schedules
final userSchedules = ScheduleService.streamUserSchedules(userId);

// Use in StreamBuilder
StreamBuilder<List<CleaningSchedule>>(
  stream: userSchedules,
  builder: (context, snapshot) {
    final schedules = snapshot.data ?? [];
    // Display schedules
  },
)
```

---

### For User: Viewing Notifications

```dart
import 'services/schedule_service.dart';

// Get user's notifications
final notifications = ScheduleService.streamUserNotifications(userId);

// Use in StreamBuilder
StreamBuilder<List<UserNotification>>(
  stream: notifications,
  builder: (context, snapshot) {
    final notifs = snapshot.data ?? [];
    // Display notifications
  },
)
```

---

### For User: Marking Notification as Read

```dart
// Mark a notification as read
await ScheduleService.markNotificationAsRead(notificationId);
```

---

## File Structure

```
lib/
├── models/
│   ├── cleaning_schedule_model.dart    ✨ NEW
│   ├── audit_log_model.dart            ✨ NEW
│   ├── notification_model.dart         ✨ NEW
│   ├── user_model.dart                 (existing)
│   └── user_page.dart                  (existing)
├── services/
│   ├── schedule_service.dart           ✨ NEW
│   ├── firestore_verification_service.dart (existing)
│   ├── email_service.dart              (existing)
│   └── fallback_email_service.dart     (existing)
└── pages/
    ├── admin_dashboard.dart            📝 UPDATED
    └── ... (other pages)
```

---

## Firebase Collections Setup

### Create Collections in Firebase Console

1. **schedules** collection
   - Auto-generate document IDs
   - Set security rules (see DATABASE_FLOW.md)

2. **audit_logs** collection
   - Auto-generate document IDs
   - Set security rules (see DATABASE_FLOW.md)

3. **notifications** collection
   - Auto-generate document IDs
   - Set security rules (see DATABASE_FLOW.md)

### Create Indexes (Optional but Recommended)

In Firebase Console → Firestore → Indexes:

1. **schedules**
   - Collection: `schedules`
   - Fields: `scheduledDate` (Ascending)

2. **schedules by user**
   - Collection: `schedules`
   - Fields: `assignedUserId` (Ascending), `scheduledDate` (Descending)

3. **audit_logs**
   - Collection: `audit_logs`
   - Fields: `timestamp` (Descending)

4. **notifications**
   - Collection: `notifications`
   - Fields: `userId` (Ascending), `createdAt` (Descending)

---

## Complete Flow Example

### Step 1: Admin Creates Schedule
```dart
// Admin submits form
final scheduleId = await ScheduleService.createSchedule(
  adminId: adminUid,
  adminEmail: adminEmail,
  adminName: adminName,
  title: 'Kitchen Cleaning',
  description: 'Mop and sanitize',
  scheduledDate: DateTime(2024, 1, 20),
  scheduledTime: DateTime(2024, 1, 20, 14, 0),
  assignedUserId: userUid,
);
```

### Step 2: System Automatically
- ✅ Saves schedule to `schedules` collection
- ✅ Creates audit log: "Admin created schedule: Kitchen Cleaning"
- ✅ Creates notification for user: "New Cleaning Schedule"
- ✅ Logs notification action in audit logs

### Step 3: Admin Sees Updates
- Dashboard streams `schedules` collection
- Shows "Kitchen Cleaning" in Today's Schedule section
- Shows "Created Schedule" in Activity Logs section

### Step 4: User Sees Updates
- Receives notification in notifications section
- Can view schedule in their assigned schedules
- Can mark notification as read

### Step 5: Admin Updates Schedule
```dart
await ScheduleService.updateSchedule(
  scheduleId: scheduleId,
  adminId: adminUid,
  adminEmail: adminEmail,
  adminName: adminName,
  status: ScheduleStatus.inProgress,
);
```

### Step 6: System Automatically
- ✅ Updates schedule status
- ✅ Creates audit log: "Admin updated schedule"
- ✅ Admin dashboard updates in real-time
- ✅ User's view updates in real-time

---

## Debugging

### Enable Console Logs
All service methods print debug messages:

```
✅ Schedule created successfully: schedule_id_123
✅ Audit log created: log_id_456
✅ Notification created for user: user_id_789
```

### Check Firebase Console
1. Go to Firestore Database
2. Check each collection for documents
3. Verify document structure matches models

### Test Queries
```dart
// Get all schedules
final allSchedules = await ScheduleService.getAllSchedules();
print('Total schedules: ${allSchedules.length}');

// Get today's schedules
final todaySchedules = await ScheduleService.getTodaySchedules();
print('Today schedules: ${todaySchedules.length}');

// Get user schedules
final userSchedules = await ScheduleService.getUserSchedules(userId);
print('User schedules: ${userSchedules.length}');

// Get audit logs
final logs = await ScheduleService.getAuditLogs(limit: 20);
print('Recent logs: ${logs.length}');
```

---

## Next Steps

1. **Create Admin Schedule Form**
   - Build UI for creating schedules
   - Call `ScheduleService.createSchedule()`
   - Show success/error messages

2. **Create User Schedule View**
   - Display user's assigned schedules
   - Stream from `ScheduleService.streamUserSchedules()`

3. **Create Notification Center**
   - Display user notifications
   - Allow marking as read
   - Stream from `ScheduleService.streamUserNotifications()`

4. **Add Schedule Management**
   - Edit existing schedules
   - Delete schedules
   - Update schedule status

5. **Add Audit Log Viewer**
   - Detailed audit log page
   - Filter by admin/action/date
   - Export functionality

6. **Set Firebase Security Rules**
   - Implement rules from DATABASE_FLOW.md
   - Test with different user roles

---

## Common Issues & Solutions

### Issue: Schedules not appearing in dashboard
**Solution:** 
- Check if `streamTodaySchedules()` is being called
- Verify Firestore rules allow reading schedules
- Check browser console for errors

### Issue: Notifications not created
**Solution:**
- Verify `assignedUserId` is provided when creating schedule
- Check if notifications collection exists in Firestore
- Verify user ID is correct

### Issue: Audit logs not showing
**Solution:**
- Check if `streamAuditLogs()` is being called
- Verify admin credentials are passed correctly
- Check Firestore rules allow reading audit logs

### Issue: Real-time updates not working
**Solution:**
- Ensure using `Stream` methods, not `Future` methods
- Check internet connection
- Verify Firestore connection is active
- Check browser console for connection errors

---

## Performance Tips

1. **Limit Stream Results**
   - Use `limit` parameter in `streamAuditLogs()`
   - Default is 50 logs, adjust as needed

2. **Use Indexes**
   - Create recommended indexes in Firestore
   - Improves query performance significantly

3. **Pagination**
   - For large datasets, implement pagination
   - Load more schedules as user scrolls

4. **Caching**
   - Consider caching frequently accessed data
   - Use local storage for offline support

---

## Security Reminders

- ✅ Never expose admin credentials in client code
- ✅ Use Firestore security rules to control access
- ✅ Validate all inputs on backend
- ✅ Log all admin actions (already implemented)
- ✅ Use HTTPS for all communications
- ✅ Implement rate limiting for API calls
