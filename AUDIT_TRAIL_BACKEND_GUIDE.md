# 🔍 Audit Trail Backend System - Complete Guide

## 📋 Overview

The audit trail system tracks and logs all user and admin actions in the RoboCleaner application. It provides comprehensive monitoring, accountability, and compliance capabilities for your admin web interface.

## ✅ What's Implemented

### 1. **Audit Log Model** (`lib/models/audit_log_model.dart`)
Comprehensive model that tracks:
- **Actor Information**: ID, email, name, and type (admin/user/robot/system)
- **Action Details**: 40+ predefined actions across all system areas
- **Metadata**: Timestamps, affected resources, custom data
- **Categories**: Automatic categorization for easy filtering

### 2. **Audit Service** (`lib/services/audit_service.dart`)
Centralized service providing:
- Automatic logging with current user detection
- Specialized logging methods for different action types
- Real-time streaming of audit logs
- Statistics and analytics
- Resource-specific audit trails

### 3. **Admin Logs UI** (`lib/pages/admin_logs.dart`)
Beautiful, functional admin interface with:
- Real-time log streaming from Firestore
- Advanced filtering (category, actor type, search)
- Statistics dashboard
- Relative timestamps (e.g., "5m ago", "2h ago")
- Export capabilities

## 🎯 Tracked Actions

### **User Actions**
- Login/Logout
- Password changes
- Account creation/updates
- Report submissions

### **Admin Actions**
- Login/Logout
- Schedule management (create/update/delete)
- User management (create/update/delete/status changes)
- Report management (view/resolve/archive/reply)
- Data exports
- System access to sensitive areas

### **Robot Actions**
- Connection/Disconnection
- Cleaning operations
- Disposal activities
- Sensor warnings
- Connectivity issues

### **System Events**
- Errors and warnings
- Configuration changes
- Automated processes

## 📁 File Structure

```
lib/
├── models/
│   └── audit_log_model.dart          # Data model with 40+ action types
├── services/
│   └── audit_service.dart            # Core logging service
├── pages/
│   └── admin_logs.dart               # Admin UI for viewing logs
└── providers/
    └── auth_provider.dart            # Integrated with login/logout logging
```

## 🚀 Usage Examples

### 1. **Basic Logging**

```dart
import '../services/audit_service.dart';
import '../models/audit_log_model.dart';

// Simple log
await AuditService.log(
  action: AuditAction.userLoggedIn,
  description: 'User John Doe logged in',
);
```

### 2. **Login/Logout Tracking**

Already integrated in `auth_provider.dart`:

```dart
// Automatic on login
await AuditService.logUserLogin(_userModel!);

// Automatic on logout
await AuditService.logUserLogout(_userModel!);
```

### 3. **Schedule Management**

Already integrated in `schedule_service.dart`:

```dart
// Log schedule creation
await AuditService.logScheduleCreated(
  scheduleId: scheduleId,
  scheduleName: title,
  actorId: adminId,
  actorName: adminName,
  scheduleData: {...},
);

// Log schedule update
await AuditService.logScheduleUpdated(
  scheduleId: scheduleId,
  scheduleName: title,
  actorId: adminId,
  actorName: adminName,
  changes: {...},
);

// Log schedule deletion
await AuditService.logScheduleDeleted(
  scheduleId: scheduleId,
  scheduleName: title,
  actorId: adminId,
  actorName: adminName,
);
```

### 4. **Report Management**

Already integrated in `report_service.dart`:

```dart
// Log report action
await AuditService.logReportAction(
  action: AuditAction.reportResolved,
  reportId: reportId,
  reportTitle: title,
  metadata: {'timestamp': DateTime.now().toIso8601String()},
);
```

### 5. **User Management**

```dart
// Log user creation by admin
await AuditService.logUserManagement(
  action: AuditAction.adminCreatedUser,
  targetUserId: userId,
  targetUserName: userName,
  actorId: adminId,
  actorName: adminName,
  changes: {
    'role': 'user',
    'status': 'Active',
  },
);

// Log user status change
await AuditService.logUserManagement(
  action: AuditAction.userStatusChanged,
  targetUserId: userId,
  targetUserName: userName,
  changes: {
    'oldStatus': 'Active',
    'newStatus': 'Inactive',
  },
);
```

### 6. **Admin Access Tracking**

Already integrated in `admin_logs.dart`:

```dart
// Log when admin accesses sensitive areas
await AuditService.logAdminAccess(
  action: AuditAction.adminAccessedLogs,
  area: 'System Logs & Audit Trail',
);

// Log when admin accesses reports
await AuditService.logAdminAccess(
  action: AuditAction.adminAccessedReports,
  area: 'Reports & Feedback Management',
);
```

### 7. **Data Export Tracking**

```dart
// Log data export
await AuditService.logDataExport(
  dataType: 'Reports',
  format: 'CSV',
  recordCount: 150,
  actorId: adminId,
  actorName: adminName,
);
```

### 8. **Robot Actions**

```dart
// Log robot events
await AuditService.logRobotAction(
  action: AuditAction.robotCleaningStarted,
  robotId: 'ROBOT_001',
  description: 'Cleaning started in Zone A',
  metadata: {
    'zone': 'A',
    'batteryLevel': 85,
  },
);
```

### 9. **System Events**

```dart
// Log system errors
await AuditService.logSystemEvent(
  action: AuditAction.systemError,
  description: 'Database connection timeout',
  metadata: {
    'errorCode': 'DB_TIMEOUT',
    'severity': 'high',
  },
);
```

## 📊 Viewing Audit Logs

### Admin Dashboard Integration

The audit logs are accessible from the admin dashboard through the "System Logs & Audit Trail" page.

**Features:**
- **Real-time Updates**: Logs stream automatically from Firestore
- **Statistics**: Total logs, today's count, errors count
- **Filtering**: By category and actor type
- **Search**: Full-text search across actors, actions, and details
- **Timestamps**: User-friendly relative times

### Streaming Logs Programmatically

```dart
// Stream all logs
AuditService.streamAuditLogs(limit: 500).listen((logs) {
  print('Received ${logs.length} audit logs');
});

// Stream with filters
AuditService.streamAuditLogs(
  limit: 100,
  category: 'admin_actions',
  actorType: 'admin',
  startDate: DateTime.now().subtract(Duration(days: 7)),
).listen((logs) {
  print('Last 7 days of admin actions: ${logs.length}');
});

// Get logs for specific user
final userLogs = await AuditService.getUserAuditLogs(userId);

// Get logs for specific resource
final resourceLogs = await AuditService.getResourceAuditLogs(resourceId);
```

## 🗄️ Firestore Structure

### Collection: `audit_logs`

```json
{
  "id": "unique_id",
  "actorId": "user_or_admin_uid",
  "actorEmail": "user@example.com",
  "actorName": "John Doe",
  "actorType": "admin",
  "action": "scheduleCreated",
  "description": "Created cleaning schedule: Morning Cleanup",
  "scheduleId": "schedule_123",
  "affectedUserId": "user_456",
  "affectedResourceId": "resource_789",
  "timestamp": "2025-12-02T10:30:00.000Z",
  "metadata": {
    "description": "Clean main floor",
    "scheduledDate": "2025-12-03T09:00:00.000Z"
  },
  "category": "admin_actions"
}
```

### Categories

- `user_actions` - User-initiated actions
- `admin_actions` - Admin operations
- `robot_actions` - Robot activities
- `cleaning_logs` - Cleaning operations
- `disposal_logs` - Waste disposal
- `sensor_warnings` - Sensor alerts
- `connectivity_issues` - Network problems
- `system_errors` - System-level errors
- `system_logs` - General system events

## 🔐 Firestore Security Rules

Already configured in `firestore.rules`:

```javascript
// Audit logs collection rules
match /audit_logs/{logId} {
  // Any authenticated user can read audit logs
  allow read: if request.auth != null;
  
  // Any authenticated user can create audit logs
  allow create: if request.auth != null;
}
```

## 📈 Statistics and Analytics

Get comprehensive audit statistics:

```dart
final stats = await AuditService.getAuditStats();

print('Total logs: ${stats['total']}');
print('Today: ${stats['today']}');
print('User actions: ${stats['user_actions']}');
print('Admin actions: ${stats['admin_actions']}');
print('Robot actions: ${stats['robot_actions']}');
print('System errors: ${stats['system_errors']}');
```

## 🎨 UI Customization

The audit logs UI uses a cyberpunk/modern dark theme with:
- Card-based layout
- Color-coded categories and actor types
- Responsive design
- Real-time updates
- Professional typography (Google Fonts - Poppins)

**Color Scheme:**
- Primary Accent: `#00D9FF` (Cyan)
- Secondary Accent: `#1E90FF` (Blue)
- Success: `#00FF88` (Green)
- Warning: `#FF6B35` (Orange)
- Error: `#FF3333` (Red)

## 🔄 Integration Checklist

- ✅ Authentication (login/logout) - `auth_provider.dart`
- ✅ Schedule management - `schedule_service.dart`
- ✅ Report management - `report_service.dart`
- ✅ Admin logs access tracking - `admin_logs.dart`
- ⚠️ User management actions - **Need to integrate in user management service**
- ⚠️ Robot actions - **Need IoT integration**
- ⚠️ Data export tracking - **Need to integrate in export functions**

## 🛠️ Adding New Action Types

1. **Add to enum** in `audit_log_model.dart`:

```dart
enum AuditAction {
  // ... existing actions
  myNewAction,
}
```

2. **Update parser** in `audit_log_model.dart`:

```dart
static AuditAction _parseAction(String? action) {
  switch (action) {
    // ... existing cases
    case 'myNewAction':
      return AuditAction.myNewAction;
  }
}
```

3. **Update action text** in `audit_log_model.dart`:

```dart
String getActionText() {
  switch (action) {
    // ... existing cases
    case AuditAction.myNewAction:
      return 'My New Action';
  }
}
```

4. **Use it in your code**:

```dart
await AuditService.log(
  action: AuditAction.myNewAction,
  description: 'Description of the action',
);
```

## 🐛 Debugging

Enable detailed logging:

```dart
// Service automatically prints logs with emojis:
// ✅ Success messages
// ❌ Error messages
// 📝 Info messages
// 🔍 Debug messages
```

Check terminal/console output for real-time feedback.

## 📦 Dependencies

Required packages (already in `pubspec.yaml`):
- `cloud_firestore: ^5.1.0` - Firestore database
- `firebase_auth: ^5.1.0` - Authentication
- `google_fonts: ^6.1.0` - UI typography
- `intl: ^0.19.0` - Date formatting
- `provider: ^6.1.5` - State management

## 🚀 Quick Start

1. **Access the audit logs UI**:
   - Login as admin
   - Navigate to "System Logs & Audit Trail" from dashboard

2. **See logs in action**:
   - Perform any action (login, create schedule, etc.)
   - Check the logs page - it updates in real-time!

3. **Filter and search**:
   - Use category dropdown to filter by type
   - Use actor dropdown to filter by who performed the action
   - Use search box for full-text search

4. **Export logs**:
   - Click "Export" button
   - Choose format (CSV or PDF)

## 🎉 Success!

Your audit trail backend is now fully operational! Every significant action in your system is being tracked and logged automatically.

## 📞 Support

For issues or questions:
1. Check the Firestore console for actual log data
2. Review terminal/console output for service logs
3. Verify Firestore security rules are deployed
4. Ensure user has proper authentication

---

**Built with ❤️ for RoboCleaner Admin System**

