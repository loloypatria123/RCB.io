# System Architecture - Cleaning Schedule Management

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         RoboCleaner App                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────┐          ┌──────────────────────┐          │
│  │   Admin Dashboard    │          │   User Dashboard     │          │
│  │                      │          │                      │          │
│  │ • Today's Schedules  │          │ • Assigned Schedules │          │
│  │ • Activity Logs      │          │ • Notifications      │          │
│  │ • Quick Actions      │          │ • Schedule Details   │          │
│  └──────────────────────┘          └──────────────────────┘          │
│           │                                   │                       │
│           └───────────────┬───────────────────┘                       │
│                           │                                           │
│                    ┌──────▼──────┐                                    │
│                    │ ScheduleService                                  │
│                    │              │                                   │
│                    │ • Create     │                                   │
│                    │ • Update     │                                   │
│                    │ • Delete     │                                   │
│                    │ • Stream     │                                   │
│                    └──────┬───────┘                                   │
│                           │                                           │
│           ┌───────────────┼───────────────┐                          │
│           │               │               │                          │
│           ▼               ▼               ▼                          │
│      ┌─────────┐     ┌──────────┐   ┌──────────────┐               │
│      │Schedules│     │AuditLogs │   │Notifications │               │
│      │Collection    │Collection │   │ Collection   │               │
│      └─────────┘     └──────────┘   └──────────────┘               │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │
                    ┌───────────▼────────────┐
                    │   Firebase Firestore   │
                    │                        │
                    │ • Real-time Sync       │
                    │ • Cloud Storage        │
                    │ • Security Rules       │
                    └────────────────────────┘
```

---

## Data Flow Diagram

### Schedule Creation Flow

```
Admin Creates Schedule
        │
        ▼
┌──────────────────────────┐
│ ScheduleService          │
│ .createSchedule()        │
└──────────────────────────┘
        │
        ├─────────────────────────────────────────┐
        │                                         │
        ▼                                         ▼
┌──────────────────────┐              ┌──────────────────────┐
│ Save to schedules    │              │ Create audit log     │
│ collection           │              │ in audit_logs        │
│                      │              │ collection           │
│ • id                 │              │                      │
│ • adminId            │              │ • adminId            │
│ • title              │              │ • action             │
│ • scheduledDate      │              │ • description        │
│ • status             │              │ • timestamp          │
└──────────────────────┘              └──────────────────────┘
        │                                         │
        │                                         │
        ├─────────────────────────────────────────┤
        │                                         │
        ▼                                         ▼
┌──────────────────────────────────────────────────────────┐
│ If assignedUserId provided:                              │
│                                                          │
│ 1. Create notification in notifications collection      │
│ 2. Log notification action in audit_logs collection     │
└──────────────────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────────────────┐
│ Real-time Updates:                                       │
│                                                          │
│ • Admin Dashboard streams schedules → Shows new schedule │
│ • Admin Dashboard streams audit logs → Shows new log     │
│ • User receives notification → Shows in notification UI  │
└──────────────────────────────────────────────────────────┘
```

---

## Component Architecture

### Models Layer

```
┌─────────────────────────────────────────────────────────┐
│                    Models Layer                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────┐  ┌──────────────────────┐   │
│  │ CleaningSchedule     │  │ AuditLog             │   │
│  │                      │  │                      │   │
│  │ • id                 │  │ • id                 │   │
│  │ • adminId            │  │ • adminId            │   │
│  │ • title              │  │ • action             │   │
│  │ • status             │  │ • description        │   │
│  │ • scheduledDate      │  │ • timestamp          │   │
│  │ • toJson()           │  │ • toJson()           │   │
│  │ • fromJson()         │  │ • fromJson()         │   │
│  └──────────────────────┘  └──────────────────────┘   │
│                                                         │
│  ┌──────────────────────┐                              │
│  │ UserNotification     │                              │
│  │                      │                              │
│  │ • id                 │                              │
│  │ • userId             │                              │
│  │ • type               │                              │
│  │ • title              │                              │
│  │ • message            │                              │
│  │ • isRead             │                              │
│  │ • toJson()           │                              │
│  │ • fromJson()         │                              │
│  └──────────────────────┘                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Service Layer

```
┌─────────────────────────────────────────────────────────┐
│                   Service Layer                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│              ScheduleService                            │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Schedule Operations                             │  │
│  │ • createSchedule()                              │  │
│  │ • updateSchedule()                              │  │
│  │ • deleteSchedule()                              │  │
│  │ • getScheduleById()                             │  │
│  │ • getAllSchedules()                             │  │
│  │ • getTodaySchedules()                           │  │
│  │ • getUserSchedules()                            │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Real-time Streams                               │  │
│  │ • streamTodaySchedules()                        │  │
│  │ • streamUserSchedules()                         │  │
│  │ • streamAuditLogs()                             │  │
│  │ • streamUserNotifications()                     │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Audit & Notification Operations                 │  │
│  │ • _logAuditAction()                             │  │
│  │ • _createNotification()                         │  │
│  │ • getAuditLogs()                                │  │
│  │ • getUserNotifications()                        │  │
│  │ • markNotificationAsRead()                      │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### UI Layer

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ AdminDashboard                                   │  │
│  │                                                  │  │
│  │ ┌────────────────────────────────────────────┐  │  │
│  │ │ Today's Cleaning Schedule Section          │  │  │
│  │ │ • StreamBuilder<CleaningSchedule>          │  │  │
│  │ │ • Displays schedules with status           │  │  │
│  │ │ • Real-time updates                        │  │  │
│  │ └────────────────────────────────────────────┘  │  │
│  │                                                  │  │
│  │ ┌────────────────────────────────────────────┐  │  │
│  │ │ Recent Activity Logs Section               │  │  │
│  │ │ • StreamBuilder<AuditLog>                  │  │  │
│  │ │ • Displays admin actions                   │  │  │
│  │ │ • Real-time updates                        │  │  │
│  │ └────────────────────────────────────────────┘  │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Database Schema

### Firestore Collections

```
firestore/
│
├── schedules/
│   ├── schedule_001/
│   │   ├── id: "schedule_001"
│   │   ├── adminId: "admin_123"
│   │   ├── assignedUserId: "user_456"
│   │   ├── title: "Living Room Cleaning"
│   │   ├── description: "Deep clean with vacuum"
│   │   ├── scheduledDate: "2024-01-20T00:00:00Z"
│   │   ├── scheduledTime: "2024-01-20T10:30:00Z"
│   │   ├── createdAt: "2024-01-19T15:30:00Z"
│   │   ├── status: "scheduled"
│   │   ├── notes: "Use eco-friendly solution"
│   │   └── estimatedDuration: 45
│   │
│   └── schedule_002/
│       └── ...
│
├── audit_logs/
│   ├── log_001/
│   │   ├── id: "log_001"
│   │   ├── adminId: "admin_123"
│   │   ├── adminEmail: "admin@example.com"
│   │   ├── adminName: "John Admin"
│   │   ├── action: "scheduleCreated"
│   │   ├── description: "Created schedule: Living Room Cleaning"
│   │   ├── scheduleId: "schedule_001"
│   │   ├── affectedUserId: "user_456"
│   │   └── timestamp: "2024-01-19T15:30:00Z"
│   │
│   └── log_002/
│       └── ...
│
└── notifications/
    ├── notif_001/
    │   ├── id: "notif_001"
    │   ├── userId: "user_456"
    │   ├── type: "scheduleAdded"
    │   ├── title: "New Cleaning Schedule"
    │   ├── message: "Admin John has scheduled: Living Room Cleaning"
    │   ├── scheduleId: "schedule_001"
    │   ├── isRead: false
    │   ├── createdAt: "2024-01-19T15:30:00Z"
    │   └── readAt: null
    │
    └── notif_002/
        └── ...
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────────────┐
│ AdminDashboard (StatefulWidget)                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ initState():                                            │
│   _todaySchedulesStream = streamTodaySchedules()       │
│   _auditLogsStream = streamAuditLogs()                 │
│                                                         │
│ build():                                                │
│   ┌─────────────────────────────────────────────────┐  │
│   │ StreamBuilder<List<CleaningSchedule>>           │  │
│   │   stream: _todaySchedulesStream                 │  │
│   │   builder: (context, snapshot) {                │  │
│   │     if (snapshot.hasData) {                     │  │
│   │       display schedules                         │  │
│   │     }                                           │  │
│   │   }                                             │  │
│   └─────────────────────────────────────────────────┘  │
│                                                         │
│   ┌─────────────────────────────────────────────────┐  │
│   │ StreamBuilder<List<AuditLog>>                   │  │
│   │   stream: _auditLogsStream                      │  │
│   │   builder: (context, snapshot) {                │  │
│   │     if (snapshot.hasData) {                     │  │
│   │       display logs                              │  │
│   │     }                                           │  │
│   │   }                                             │  │
│   └─────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Error Handling Strategy

```
┌─────────────────────────────────────────────────────────┐
│ Error Handling Flow                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Try Block:                                              │
│   Execute Firebase operation                           │
│                                                         │
│ Catch Block:                                            │
│   ├─ Print error message to console                    │
│   ├─ Return null/false/empty list                      │
│   └─ UI shows error state or empty state               │
│                                                         │
│ UI Handling:                                            │
│   ├─ Loading state: Show spinner                       │
│   ├─ Error state: Show error message                   │
│   ├─ Empty state: Show "No data" message               │
│   └─ Success state: Display data                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Security Layers                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Layer 1: Firebase Authentication                        │
│   • User must be authenticated                          │
│   • User role determined by custom claims               │
│                                                         │
│ Layer 2: Firestore Security Rules                       │
│   • schedules: Read all, Write admin only              │
│   • audit_logs: Read/Write admin only                  │
│   • notifications: Read own, Write admin only          │
│                                                         │
│ Layer 3: Service Layer Validation                       │
│   • Verify admin credentials                           │
│   • Validate input data                                │
│   • Check user permissions                             │
│                                                         │
│ Layer 4: Audit Logging                                  │
│   • Log all admin actions                              │
│   • Track who did what and when                        │
│   • Enable compliance and auditing                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Scalability Considerations

### Current Implementation
- ✅ Real-time updates with Firestore streams
- ✅ Automatic indexing for common queries
- ✅ Pagination support with limit parameter
- ✅ Efficient data models

### Future Optimizations
- [ ] Implement caching layer
- [ ] Add offline support with local storage
- [ ] Implement pagination UI
- [ ] Add search and filtering
- [ ] Implement data archival for old logs
- [ ] Add batch operations for bulk updates
- [ ] Implement rate limiting

---

## Integration Points

### With Admin Dashboard
- Displays today's schedules in real-time
- Displays recent activity logs in real-time
- Shows schedule status and admin info

### With User Dashboard
- Display assigned schedules
- Show notifications
- Allow marking notifications as read

### With Schedule Creation Form
- Call `createSchedule()` on submit
- Show success/error messages
- Redirect on success

### With Notification Center
- Display notifications
- Stream from `streamUserNotifications()`
- Allow marking as read

---

## Performance Metrics

| Operation | Time | Notes |
|-----------|------|-------|
| Create Schedule | ~500ms | Includes audit log + notification |
| Update Schedule | ~300ms | Updates document + audit log |
| Delete Schedule | ~300ms | Deletes document + audit log |
| Stream Schedules | Real-time | Instant updates |
| Stream Audit Logs | Real-time | Instant updates |
| Stream Notifications | Real-time | Instant updates |

---

## Deployment Checklist

- [ ] Create Firestore collections
- [ ] Set up security rules
- [ ] Create recommended indexes
- [ ] Test schedule creation
- [ ] Test audit logging
- [ ] Test notifications
- [ ] Test real-time updates
- [ ] Test error handling
- [ ] Load test with sample data
- [ ] Monitor Firestore usage
