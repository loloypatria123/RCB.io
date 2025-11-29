# Cleaning Schedule Database Flow

## Overview
This document describes the complete Firebase database flow for managing cleaning schedules in the RoboCleaner application. The system handles schedule creation, user notifications, audit logging, and real-time updates across admin and user interfaces.

---

## Database Collections

### 1. `schedules` Collection
Stores all cleaning schedules created by admins.

**Document Structure:**
```json
{
  "id": "schedule_uuid",
  "adminId": "admin_uid",
  "assignedUserId": "user_uid",
  "title": "Living Room Cleaning",
  "description": "Deep clean with vacuum and mop",
  "scheduledDate": "2024-01-15T00:00:00.000Z",
  "scheduledTime": "2024-01-15T10:30:00.000Z",
  "createdAt": "2024-01-14T15:30:00.000Z",
  "updatedAt": "2024-01-14T15:30:00.000Z",
  "status": "scheduled",
  "notes": "Use eco-friendly cleaning solution",
  "estimatedDuration": 45
}
```

**Fields:**
- `id`: Unique schedule identifier
- `adminId`: UID of the admin who created the schedule
- `assignedUserId`: UID of the user assigned to this schedule (optional)
- `title`: Schedule title
- `description`: Detailed description
- `scheduledDate`: Date when the schedule is set (ISO 8601)
- `scheduledTime`: Time when the schedule is set (ISO 8601)
- `createdAt`: Timestamp of creation
- `updatedAt`: Timestamp of last update
- `status`: One of `scheduled`, `inProgress`, `completed`, `cancelled`
- `notes`: Additional notes
- `estimatedDuration`: Expected duration in minutes

**Indexes:**
- `scheduledDate` (ascending) - for querying today's schedules
- `assignedUserId` (ascending) - for user-specific queries

---

### 2. `audit_logs` Collection
Tracks all admin actions for compliance and auditing.

**Document Structure:**
```json
{
  "id": "log_uuid",
  "adminId": "admin_uid",
  "adminEmail": "admin@example.com",
  "adminName": "John Admin",
  "action": "scheduleCreated",
  "description": "Created cleaning schedule: Living Room Cleaning",
  "scheduleId": "schedule_uuid",
  "affectedUserId": "user_uid",
  "timestamp": "2024-01-14T15:30:00.000Z",
  "metadata": {}
}
```

**Fields:**
- `id`: Unique log identifier
- `adminId`: UID of the admin performing the action
- `adminEmail`: Email of the admin
- `adminName`: Name of the admin
- `action`: Type of action (see AuditAction enum)
- `description`: Human-readable description
- `scheduleId`: Related schedule ID (if applicable)
- `affectedUserId`: User affected by the action (if applicable)
- `timestamp`: When the action occurred
- `metadata`: Additional context data

**Supported Actions:**
- `scheduleCreated` - Admin created a new schedule
- `scheduleUpdated` - Admin modified an existing schedule
- `scheduleDeleted` - Admin deleted a schedule
- `scheduleCancelled` - Admin cancelled a schedule
- `scheduleCompleted` - Schedule was marked as completed
- `userNotified` - User was notified about a schedule

**Indexes:**
- `timestamp` (descending) - for recent logs

---

### 3. `notifications` Collection
Stores user notifications about schedules and system events.

**Document Structure:**
```json
{
  "id": "notification_uuid",
  "userId": "user_uid",
  "type": "scheduleAdded",
  "title": "New Cleaning Schedule",
  "message": "Admin John has scheduled a cleaning: Living Room Cleaning",
  "scheduleId": "schedule_uuid",
  "isRead": false,
  "createdAt": "2024-01-14T15:30:00.000Z",
  "readAt": null,
  "metadata": {}
}
```

**Fields:**
- `id`: Unique notification identifier
- `userId`: UID of the user receiving the notification
- `type`: Type of notification (see NotificationType enum)
- `title`: Notification title
- `message`: Notification message
- `scheduleId`: Related schedule ID (if applicable)
- `isRead`: Whether the user has read the notification
- `createdAt`: When the notification was created
- `readAt`: When the user read the notification
- `metadata`: Additional context data

**Supported Types:**
- `scheduleAdded` - New schedule created for the user
- `scheduleUpdated` - Existing schedule was modified
- `scheduleReminder` - Reminder about upcoming schedule
- `scheduleCompleted` - Schedule has been completed
- `alert` - General system alert

**Indexes:**
- `userId` (ascending) - for user-specific queries
- `createdAt` (descending) - for recent notifications

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      ADMIN CREATES SCHEDULE                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ ScheduleService  │
                    │ .createSchedule()│
                    └──────────────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
        │  schedules   │ │ audit_logs   │ │notifications │
        │  collection  │ │ collection   │ │ collection   │
        └──────────────┘ └──────────────┘ └──────────────┘
                │             │                   │
                │             │                   │
                ▼             ▼                   ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
        │ Admin sees   │ │ Admin sees   │ │ User receives│
        │ schedules in │ │ action logs  │ │ notification │
        │ dashboard    │ │ in dashboard │ │ in app       │
        └──────────────┘ └──────────────┘ └──────────────┘
```

---

## API Reference

### ScheduleService

#### Create Schedule
```dart
Future<String?> createSchedule({
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
})
```

**Flow:**
1. Creates schedule document in `schedules` collection
2. Logs action in `audit_logs` collection
3. Creates notification in `notifications` collection (if user assigned)
4. Logs notification action in `audit_logs` collection

**Returns:** Schedule ID if successful, null on error

---

#### Update Schedule
```dart
Future<bool> updateSchedule({
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
})
```

**Flow:**
1. Updates schedule document in `schedules` collection
2. Logs action in `audit_logs` collection

**Returns:** true if successful, false on error

---

#### Delete Schedule
```dart
Future<bool> deleteSchedule({
  required String scheduleId,
  required String adminId,
  required String adminEmail,
  required String adminName,
})
```

**Flow:**
1. Retrieves schedule document
2. Deletes schedule from `schedules` collection
3. Logs action in `audit_logs` collection

**Returns:** true if successful, false on error

---

#### Get Today's Schedules (Real-time)
```dart
Stream<List<CleaningSchedule>> streamTodaySchedules()
```

**Returns:** Stream of schedules for today, updates in real-time

---

#### Get User Schedules (Real-time)
```dart
Stream<List<CleaningSchedule>> streamUserSchedules(String userId)
```

**Returns:** Stream of schedules for a specific user, updates in real-time

---

#### Get Audit Logs (Real-time)
```dart
Stream<List<AuditLog>> streamAuditLogs({int limit = 50})
```

**Returns:** Stream of recent audit logs, updates in real-time

---

#### Get User Notifications (Real-time)
```dart
Stream<List<UserNotification>> streamUserNotifications(String userId, {int limit = 50})
```

**Returns:** Stream of user notifications, updates in real-time

---

#### Mark Notification as Read
```dart
Future<bool> markNotificationAsRead(String notificationId)
```

**Flow:**
1. Updates notification document with `isRead: true` and `readAt` timestamp

**Returns:** true if successful, false on error

---

## Integration Points

### Admin Dashboard
- **Today's Schedules Section**: Uses `streamTodaySchedules()` to display real-time schedules
- **Activity Logs Section**: Uses `streamAuditLogs()` to display recent admin actions

### User Dashboard
- **Assigned Schedules**: Uses `streamUserSchedules(userId)` to display user's schedules
- **Notifications**: Uses `streamUserNotifications(userId)` to display notifications

### Admin Schedule Creation Page
- Calls `createSchedule()` when admin submits a new schedule
- Automatically creates audit log and user notification

---

## Security Considerations

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Schedules - Only admins can create/update, users can read their own
    match /schedules/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth.token.role == 'admin';
    }
    
    // Audit Logs - Only admins can read/write
    match /audit_logs/{document=**} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    
    // Notifications - Users can read/update their own, admins can create
    match /notifications/{document=**} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.role == 'admin';
    }
  }
}
```

---

## Error Handling

All service methods include try-catch blocks and print debug messages:
- ✅ Success: `print('✅ Action completed: $details')`
- ❌ Error: `print('❌ Error: $errorMessage')`

---

## Testing the Flow

### Test Schedule Creation
```dart
final scheduleId = await ScheduleService.createSchedule(
  adminId: 'admin123',
  adminEmail: 'admin@example.com',
  adminName: 'John Admin',
  title: 'Test Schedule',
  description: 'Test Description',
  scheduledDate: DateTime.now(),
  scheduledTime: DateTime.now().add(Duration(hours: 2)),
  assignedUserId: 'user123',
);
```

### Verify in Firebase Console
1. Check `schedules` collection for new document
2. Check `audit_logs` collection for action logs
3. Check `notifications` collection for user notification
4. Verify admin dashboard shows the schedule
5. Verify user receives notification

---

## Future Enhancements

- [ ] Schedule recurring/recurring patterns
- [ ] Email notifications for users
- [ ] Push notifications via Firebase Cloud Messaging
- [ ] Schedule conflict detection
- [ ] User acceptance/rejection of schedules
- [ ] Schedule completion confirmation
- [ ] Performance metrics and analytics
- [ ] Export audit logs to CSV/PDF
