# 🔍 Audit Trail - Quick Reference Card

## 📌 Common Usage Patterns

### Import Statement
```dart
import '../services/audit_service.dart';
import '../models/audit_log_model.dart';
```

### 1. **User Login/Logout** (Auto-tracked in auth_provider.dart)
```dart
// Login
await AuditService.logUserLogin(userModel);

// Logout
await AuditService.logUserLogout(userModel);
```

### 2. **Admin Actions**
```dart
// Access sensitive area
await AuditService.logAdminAccess(
  action: AuditAction.adminAccessedReports,
  area: 'Reports & Feedback Management',
);

// Export data
await AuditService.logDataExport(
  dataType: 'Reports',
  format: 'CSV',
  recordCount: 150,
);
```

### 3. **Schedule Management** (Auto-tracked in schedule_service.dart)
```dart
// Create
await AuditService.logScheduleCreated(
  scheduleId: id,
  scheduleName: name,
  scheduleData: {...},
);

// Update
await AuditService.logScheduleUpdated(
  scheduleId: id,
  scheduleName: name,
  changes: {...},
);

// Delete
await AuditService.logScheduleDeleted(
  scheduleId: id,
  scheduleName: name,
);
```

### 4. **Report Management** (Auto-tracked in report_service.dart)
```dart
await AuditService.logReportAction(
  action: AuditAction.reportResolved,
  reportId: id,
  reportTitle: title,
  metadata: {...},
);
```

### 5. **User Management**
```dart
await AuditService.logUserManagement(
  action: AuditAction.adminCreatedUser,
  targetUserId: userId,
  targetUserName: userName,
  changes: {...},
);
```

### 6. **Robot Actions**
```dart
await AuditService.logRobotAction(
  action: AuditAction.robotCleaningStarted,
  robotId: 'ROBOT_001',
  description: 'Cleaning Zone A',
  metadata: {...},
);
```

### 7. **Generic Logging**
```dart
await AuditService.log(
  action: AuditAction.configurationChanged,
  description: 'Updated system settings',
  actorId: userId,
  actorName: userName,
  actorType: 'admin',
  metadata: {...},
);
```

## 📊 Viewing Logs

### Admin UI
Navigate to: **Admin Dashboard → System Logs & Audit Trail**

### Programmatically
```dart
// Stream all logs
AuditService.streamAuditLogs(limit: 500).listen((logs) {
  // Handle logs
});

// Get user logs
final logs = await AuditService.getUserAuditLogs(userId);

// Get statistics
final stats = await AuditService.getAuditStats();
```

## 🎯 Action Types Reference

| Category | Actions |
|----------|---------|
| **User Actions** | userLoggedIn, userLoggedOut, userPasswordChanged, userAccountCreated, userAccountUpdated, userAccountDeleted |
| **Admin Actions** | adminLoggedIn, adminLoggedOut, adminCreatedUser, adminUpdatedUser, adminDeletedUser, adminAccessedReports, adminAccessedLogs, adminExportedData |
| **Schedules** | scheduleCreated, scheduleUpdated, scheduleDeleted, scheduleCancelled, scheduleCompleted |
| **Reports** | reportCreated, reportViewed, reportResolved, reportArchived, reportReplied |
| **Robot** | robotConnected, robotDisconnected, robotCleaningStarted, robotCleaningCompleted, robotDisposalPerformed, robotSensorWarning, robotConnectivityIssue |
| **System** | systemError, systemWarning, configurationChanged, userNotified |

## 🗂️ Categories

- `user_actions` - User operations
- `admin_actions` - Admin operations
- `robot_actions` - Robot activities
- `cleaning_logs` - Cleaning operations
- `disposal_logs` - Disposal activities
- `sensor_warnings` - Sensor alerts
- `connectivity_issues` - Network issues
- `system_errors` - System errors
- `system_logs` - General logs

## 🎨 UI Features

**Admin Logs Page:**
- ✅ Real-time streaming
- ✅ Filter by category
- ✅ Filter by actor type
- ✅ Full-text search
- ✅ Statistics dashboard
- ✅ Relative timestamps
- ✅ Export capabilities

## 📁 Files

| File | Purpose |
|------|---------|
| `lib/models/audit_log_model.dart` | Data model |
| `lib/services/audit_service.dart` | Core service |
| `lib/pages/admin_logs.dart` | Admin UI |
| `lib/providers/auth_provider.dart` | Login/logout tracking |
| `lib/services/schedule_service.dart` | Schedule tracking |
| `lib/services/report_service.dart` | Report tracking |

## 🔐 Security

- All authenticated users can read audit logs
- All authenticated users can create audit logs
- Configured in `firestore.rules`

## 🐛 Debugging Tips

1. Check console for log messages:
   - ✅ = Success
   - ❌ = Error
   - 📝 = Info

2. Verify Firestore collection `audit_logs` exists

3. Check user authentication status

4. Review Firestore security rules deployment

---

**For detailed documentation, see:** `AUDIT_TRAIL_BACKEND_GUIDE.md`

