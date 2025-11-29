# Firebase Firestore Quick Start - 5 Minutes

## TL;DR - Super Quick Version

### Collections to Create:
1. **schedules**
2. **audit_logs**
3. **notifications**

### Quick Steps:

```
1. Go to Firebase Console → rcbfinal-e7f13
2. Click Firestore Database
3. Click "+ Start collection"
4. Type "schedules" → Next → Auto ID → Add fields → Save
5. Repeat for "audit_logs" and "notifications"
6. Done! ✅
```

---

## Detailed Quick Start

### Step 1: Open Firebase Console
```
https://console.firebase.google.com/
↓
Click: rcbfinal-e7f13
↓
Left sidebar: Firestore Database
```

### Step 2: Create "schedules" Collection

| Action | Input |
|--------|-------|
| Click | "+ Start collection" |
| Type | `schedules` |
| Click | Next |
| Click | Auto ID |
| Add Fields | See table below |
| Click | Save |

**Fields for schedules:**
```
id (String): schedule_001
adminId (String): admin_123
title (String): Sample Schedule
description (String): Sample Description
status (String): scheduled
scheduledDate (Timestamp): today
createdAt (Timestamp): today
```

### Step 3: Create "audit_logs" Collection

| Action | Input |
|--------|-------|
| Click | "+ Create collection" |
| Type | `audit_logs` |
| Click | Next |
| Click | Auto ID |
| Add Fields | See table below |
| Click | Save |

**Fields for audit_logs:**
```
id (String): log_001
adminId (String): admin_123
adminEmail (String): admin@example.com
adminName (String): John Admin
action (String): scheduleCreated
description (String): Created schedule
timestamp (Timestamp): today
```

### Step 4: Create "notifications" Collection

| Action | Input |
|--------|-------|
| Click | "+ Create collection" |
| Type | `notifications` |
| Click | Next |
| Click | Auto ID |
| Add Fields | See table below |
| Click | Save |

**Fields for notifications:**
```
id (String): notif_001
userId (String): user_123
type (String): scheduleAdded
title (String): New Schedule
message (String): You have a new schedule
isRead (Boolean): false
createdAt (Timestamp): today
```

### Step 5: Verify Collections

You should see:
```
Firestore Database
├── schedules ✅
├── audit_logs ✅
└── notifications ✅
```

---

## Optional: Set Up Security Rules

1. Click **Rules** tab
2. Delete existing text
3. Paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /schedules/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth.token.role == 'admin';
    }
    match /audit_logs/{document=**} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    match /notifications/{document=**} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.role == 'admin';
    }
  }
}
```

4. Click **Publish**

---

## Optional: Create Indexes

Click **Indexes** tab, then create:

1. **schedules - by date**
   - Collection: `schedules`
   - Field: `scheduledDate` (Ascending)

2. **schedules - by user and date**
   - Collection: `schedules`
   - Fields: `assignedUserId` (Asc), `scheduledDate` (Desc)

3. **audit_logs - by timestamp**
   - Collection: `audit_logs`
   - Field: `timestamp` (Descending)

4. **notifications - by user and date**
   - Collection: `notifications`
   - Fields: `userId` (Asc), `createdAt` (Desc)

---

## ✅ Done!

Your Firestore is ready to use!

**Next:** Run your Flutter app and create a schedule. You should see it appear in Firebase Console in real-time.

---

## Need More Details?

- **Full Guide:** See `FIREBASE_SETUP_GUIDE.md`
- **Visual Guide:** See `FIREBASE_VISUAL_STEPS.md`
- **Technical Details:** See `DATABASE_FLOW.md`

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't find Firestore | Make sure you're in rcbfinal-e7f13 project |
| Collections not showing | Refresh the page |
| Fields not saving | Make sure you clicked "Add field" for each one |
| Rules error | Check for syntax errors (missing brackets) |

---

## Collections Summary

### schedules
Stores cleaning schedules created by admins.

### audit_logs
Tracks all admin actions (create, update, delete, etc).

### notifications
Stores notifications sent to users about schedules.

---

## That's It! 🎉

You now have a working Firestore database for the cleaning schedule system!
