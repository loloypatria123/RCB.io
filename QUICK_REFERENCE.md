# Quick Reference - Cleaning Schedule System

## File Locations

| File | Purpose |
|------|---------|
| `lib/models/cleaning_schedule_model.dart` | Schedule data model |
| `lib/models/audit_log_model.dart` | Audit log data model |
| `lib/models/notification_model.dart` | Notification data model |
| `lib/services/schedule_service.dart` | All Firebase operations |
| `lib/pages/admin_dashboard.dart` | Admin dashboard (updated) |

---

## Common Operations

### Create Schedule
```dart
await ScheduleService.createSchedule(
  adminId: 'admin_uid',
  adminEmail: 'admin@example.com',
  adminName: 'John Admin',
  title: 'Living Room Cleaning',
  description: 'Deep clean',
  scheduledDate: DateTime(2024, 1, 20),
  scheduledTime: DateTime(2024, 1, 20, 10, 30),
  assignedUserId: 'user_uid',
);
```

### Update Schedule
```dart
await ScheduleService.updateSchedule(
  scheduleId: 'schedule_id',
  adminId: 'admin_uid',
  adminEmail: 'admin@example.com',
  adminName: 'John Admin',
  status: ScheduleStatus.inProgress,
);
```

### Delete Schedule
```dart
await ScheduleService.deleteSchedule(
  scheduleId: 'schedule_id',
  adminId: 'admin_uid',
  adminEmail: 'admin@example.com',
  adminName: 'John Admin',
);
```

### Get Today's Schedules (Real-time)
```dart
StreamBuilder<List<CleaningSchedule>>(
  stream: ScheduleService.streamTodaySchedules(),
  builder: (context, snapshot) {
    final schedules = snapshot.data ?? [];
    // Display schedules
  },
)
```

### Get User Schedules (Real-time)
```dart
StreamBuilder<List<CleaningSchedule>>(
  stream: ScheduleService.streamUserSchedules(userId),
  builder: (context, snapshot) {
    final schedules = snapshot.data ?? [];
    // Display schedules
  },
)
```

### Get Audit Logs (Real-time)
```dart
StreamBuilder<List<AuditLog>>(
  stream: ScheduleService.streamAuditLogs(limit: 50),
  builder: (context, snapshot) {
    final logs = snapshot.data ?? [];
    // Display logs
  },
)
```

### Get User Notifications (Real-time)
```dart
StreamBuilder<List<UserNotification>>(
  stream: ScheduleService.streamUserNotifications(userId, limit: 50),
  builder: (context, snapshot) {
    final notifications = snapshot.data ?? [];
    // Display notifications
  },
)
```

### Mark Notification as Read
```dart
await ScheduleService.markNotificationAsRead(notificationId);
```

---

## Enums

### ScheduleStatus
- `scheduled` - Schedule is planned
- `inProgress` - Schedule is currently running
- `completed` - Schedule has finished
- `cancelled` - Schedule was cancelled

### AuditAction
- `scheduleCreated` - New schedule created
- `scheduleUpdated` - Schedule modified
- `scheduleDeleted` - Schedule deleted
- `scheduleCancelled` - Schedule cancelled
- `scheduleCompleted` - Schedule finished
- `userNotified` - User was notified

### NotificationType
- `scheduleAdded` - New schedule assigned
- `scheduleUpdated` - Schedule was modified
- `scheduleReminder` - Reminder notification
- `scheduleCompleted` - Schedule finished
- `alert` - System alert

---

## Database Collections

### schedules
```json
{
  "id": "string",
  "adminId": "string",
  "assignedUserId": "string (optional)",
  "title": "string",
  "description": "string",
  "scheduledDate": "ISO 8601 datetime",
  "scheduledTime": "ISO 8601 datetime",
  "createdAt": "ISO 8601 datetime",
  "updatedAt": "ISO 8601 datetime (optional)",
  "status": "scheduled|inProgress|completed|cancelled",
  "notes": "string (optional)",
  "estimatedDuration": "number (minutes, optional)"
}
```

### audit_logs
```json
{
  "id": "string",
  "adminId": "string",
  "adminEmail": "string",
  "adminName": "string",
  "action": "scheduleCreated|scheduleUpdated|...",
  "description": "string",
  "scheduleId": "string (optional)",
  "affectedUserId": "string (optional)",
  "timestamp": "ISO 8601 datetime",
  "metadata": "object (optional)"
}
```

### notifications
```json
{
  "id": "string",
  "userId": "string",
  "type": "scheduleAdded|scheduleUpdated|...",
  "title": "string",
  "message": "string",
  "scheduleId": "string (optional)",
  "isRead": "boolean",
  "createdAt": "ISO 8601 datetime",
  "readAt": "ISO 8601 datetime (optional)",
  "metadata": "object (optional)"
}
```

---

## Admin Dashboard Features

### Today's Cleaning Schedule Section
- Displays all schedules for today
- Shows time, title, description, and status
- Real-time updates
- Color-coded status indicators

### Recent Activity Logs Section
- Shows last 10 admin actions
- Displays timestamp, action type, admin name, and description
- Real-time updates
- Sorted by most recent first

---

## Firestore Security Rules Template

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Schedules
    match /schedules/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth.token.role == 'admin';
    }
    
    // Audit Logs
    match /audit_logs/{document=**} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    
    // Notifications
    match /notifications/{document=**} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.role == 'admin';
    }
  }
}
```

---

## Debugging Checklist

- [ ] Check Firestore console for documents
- [ ] Verify collection names match exactly
- [ ] Check admin credentials are passed correctly
- [ ] Verify user IDs are correct
- [ ] Check browser console for errors
- [ ] Verify internet connection
- [ ] Check Firestore security rules
- [ ] Look for debug print statements in console

---

## Performance Tips

- Use `limit` parameter to reduce data transfer
- Create recommended Firestore indexes
- Implement pagination for large datasets
- Cache frequently accessed data
- Use `Future` methods for one-time reads
- Use `Stream` methods for real-time updates

---

## Common Errors & Solutions

| Error | Solution |
|-------|----------|
| "No schedules showing" | Check if stream is connected, verify Firestore rules |
| "Notifications not created" | Verify assignedUserId is provided, check notifications collection |
| "Audit logs empty" | Check if createSchedule() is being called, verify admin credentials |
| "Real-time updates not working" | Use Stream methods, check internet, verify Firestore connection |
| "Permission denied" | Check Firestore security rules, verify user role |

---

## Next Implementation Steps

1. **Admin Schedule Form**
   - Create UI for schedule creation
   - Validate inputs
   - Call `createSchedule()`

2. **User Schedule View**
   - Display user's schedules
   - Stream from `streamUserSchedules()`

3. **Notification Center**
   - Display notifications
   - Mark as read functionality
   - Stream from `streamUserNotifications()`

4. **Schedule Management**
   - Edit schedules
   - Delete schedules
   - Update status

5. **Audit Log Viewer**
   - Detailed log page
   - Filtering options
   - Export functionality

6. **Security Rules**
   - Implement rules from template
   - Test with different roles

---

## Useful Links

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firestore Package](https://pub.dev/packages/cloud_firestore)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Real-time Updates with Streams](https://firebase.google.com/docs/firestore/query-data/listen)

---

## Support Files

- `DATABASE_FLOW.md` - Detailed technical documentation
- `IMPLEMENTATION_GUIDE.md` - Step-by-step implementation guide
- `QUICK_REFERENCE.md` - This file
