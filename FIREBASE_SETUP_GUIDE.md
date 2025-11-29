# Step-by-Step Firebase Firestore Collections Setup Guide

## Prerequisites
- Firebase project already created (rcbfinal-e7f13)
- Access to Firebase Console
- Admin privileges

---

## Step 1: Access Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click on your project: **rcbfinal-e7f13**
3. In the left sidebar, click **Firestore Database**
4. You should see the Firestore interface

---

## Step 2: Create "schedules" Collection

### 2.1: Start Collection Creation
1. Click the **"+ Start collection"** button (or **"Create collection"** if you have existing collections)
2. A dialog box will appear asking for the collection name

### 2.2: Name the Collection
1. In the **Collection ID** field, type: `schedules`
2. Click **Next**

### 2.3: Add First Document
1. Firebase requires at least one document to create a collection
2. Click **Auto ID** to generate an automatic document ID
3. You'll see a form to add fields

### 2.4: Add Fields to First Document

Add these fields (you can add sample data or leave blank):

| Field Name | Type | Value |
|-----------|------|-------|
| id | String | `schedule_001` |
| adminId | String | `admin_123` |
| title | String | `Sample Schedule` |
| description | String | `Sample Description` |
| status | String | `scheduled` |
| scheduledDate | Timestamp | (current date) |
| scheduledTime | Timestamp | (current time) |
| createdAt | Timestamp | (current time) |

**Steps to add each field:**
1. Click **Add field**
2. Enter field name (e.g., "id")
3. Select field type from dropdown (String, Timestamp, etc.)
4. Enter the value
5. Repeat for each field

### 2.5: Save Collection
1. Click **Save** button
2. The "schedules" collection is now created!

---

## Step 3: Create "audit_logs" Collection

### 3.1: Start New Collection
1. In the Firestore Database view, click **"+ Start collection"** (or **"Create collection"**)
2. Enter collection name: `audit_logs`
3. Click **Next**

### 3.2: Add First Document
1. Click **Auto ID**
2. Add these fields:

| Field Name | Type | Value |
|-----------|------|-------|
| id | String | `log_001` |
| adminId | String | `admin_123` |
| adminEmail | String | `admin@example.com` |
| adminName | String | `John Admin` |
| action | String | `scheduleCreated` |
| description | String | `Created schedule` |
| timestamp | Timestamp | (current time) |

### 3.3: Save Collection
1. Click **Save**
2. The "audit_logs" collection is now created!

---

## Step 4: Create "notifications" Collection

### 4.1: Start New Collection
1. Click **"+ Start collection"** (or **"Create collection"**)
2. Enter collection name: `notifications`
3. Click **Next**

### 4.2: Add First Document
1. Click **Auto ID**
2. Add these fields:

| Field Name | Type | Value |
|-----------|------|-------|
| id | String | `notif_001` |
| userId | String | `user_123` |
| type | String | `scheduleAdded` |
| title | String | `New Schedule` |
| message | String | `You have a new schedule` |
| isRead | Boolean | `false` |
| createdAt | Timestamp | (current time) |

### 4.3: Save Collection
1. Click **Save**
2. The "notifications" collection is now created!

---

## Step 5: Verify Collections Created

1. In the Firestore Database view, you should see three collections:
   - ✅ **schedules**
   - ✅ **audit_logs**
   - ✅ **notifications**

2. Click on each collection to verify documents are there

---

## Step 6: Create Firestore Indexes (Optional but Recommended)

### 6.1: Create Index for "schedules" Collection

**Index 1: Query by scheduled date**

1. Go to **Firestore Database** → **Indexes** tab
2. Click **Create Index**
3. Fill in the form:
   - **Collection ID**: `schedules`
   - **Fields indexed**: 
     - Field: `scheduledDate` | Order: `Ascending`
   - Click **Create Index**

**Index 2: Query by user and date**

1. Click **Create Index** again
2. Fill in the form:
   - **Collection ID**: `schedules`
   - **Fields indexed**:
     - Field: `assignedUserId` | Order: `Ascending`
     - Field: `scheduledDate` | Order: `Descending`
   - Click **Create Index**

### 6.2: Create Index for "audit_logs" Collection

1. Click **Create Index**
2. Fill in the form:
   - **Collection ID**: `audit_logs`
   - **Fields indexed**:
     - Field: `timestamp` | Order: `Descending`
   - Click **Create Index**

### 6.3: Create Index for "notifications" Collection

1. Click **Create Index**
2. Fill in the form:
   - **Collection ID**: `notifications`
   - **Fields indexed**:
     - Field: `userId` | Order: `Ascending`
     - Field: `createdAt` | Order: `Descending`
   - Click **Create Index**

**Note:** Indexes may take a few minutes to build. You'll see a status indicator.

---

## Step 7: Set Up Firestore Security Rules

### 7.1: Go to Security Rules

1. In Firestore Database, click the **Rules** tab
2. You'll see the default rules

### 7.2: Replace with Custom Rules

Delete the existing rules and paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read schedules
    match /schedules/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth.token.role == 'admin';
    }
    
    // Only admins can read/write audit logs
    match /audit_logs/{document=**} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    
    // Users can read/update their own notifications, admins can create
    match /notifications/{document=**} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.role == 'admin';
    }
  }
}
```

### 7.3: Publish Rules

1. Click **Publish** button
2. Confirm the changes
3. Rules are now active!

---

## Step 8: Verify Everything Works

### 8.1: Check Collections in Console

1. Go to **Firestore Database** → **Data** tab
2. You should see:
   ```
   Firestore
   ├── schedules
   │   └── (document with sample data)
   ├── audit_logs
   │   └── (document with sample data)
   └── notifications
       └── (document with sample data)
   ```

### 8.2: Test from Your App

Run this code in your Flutter app to verify:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirestore() async {
  final firestore = FirebaseFirestore.instance;
  
  // Test 1: Read schedules
  final schedules = await firestore.collection('schedules').get();
  print('Schedules: ${schedules.docs.length}');
  
  // Test 2: Read audit logs
  final logs = await firestore.collection('audit_logs').get();
  print('Audit logs: ${logs.docs.length}');
  
  // Test 3: Read notifications
  final notifications = await firestore.collection('notifications').get();
  print('Notifications: ${notifications.docs.length}');
}
```

---

## Troubleshooting

### Issue: Can't create collection
**Solution:** 
- Make sure you're in the correct Firebase project
- Check that Firestore is enabled (should be by default)
- Try refreshing the page

### Issue: Fields not saving
**Solution:**
- Make sure you're selecting the correct field type
- Check that you clicked **Add field** for each field
- Verify the value is in the correct format

### Issue: Indexes not building
**Solution:**
- Indexes can take 5-10 minutes to build
- Check the Indexes tab for status
- Refresh the page to see updated status

### Issue: Security rules error
**Solution:**
- Make sure you copied the entire rules block
- Check for syntax errors (missing brackets, etc.)
- Try publishing again

---

## Collection Structure Reference

### schedules Collection
```
schedules/
├── document_id_1/
│   ├── id: "string"
│   ├── adminId: "string"
│   ├── assignedUserId: "string"
│   ├── title: "string"
│   ├── description: "string"
│   ├── scheduledDate: "timestamp"
│   ├── scheduledTime: "timestamp"
│   ├── createdAt: "timestamp"
│   ├── updatedAt: "timestamp"
│   ├── status: "string" (scheduled/inProgress/completed/cancelled)
│   ├── notes: "string"
│   └── estimatedDuration: "number"
└── document_id_2/
    └── ...
```

### audit_logs Collection
```
audit_logs/
├── document_id_1/
│   ├── id: "string"
│   ├── adminId: "string"
│   ├── adminEmail: "string"
│   ├── adminName: "string"
│   ├── action: "string"
│   ├── description: "string"
│   ├── scheduleId: "string"
│   ├── affectedUserId: "string"
│   ├── timestamp: "timestamp"
│   └── metadata: "map"
└── document_id_2/
    └── ...
```

### notifications Collection
```
notifications/
├── document_id_1/
│   ├── id: "string"
│   ├── userId: "string"
│   ├── type: "string"
│   ├── title: "string"
│   ├── message: "string"
│   ├── scheduleId: "string"
│   ├── isRead: "boolean"
│   ├── createdAt: "timestamp"
│   ├── readAt: "timestamp"
│   └── metadata: "map"
└── document_id_2/
    └── ...
```

---

## Quick Checklist

- [ ] Logged into Firebase Console
- [ ] Opened rcbfinal-e7f13 project
- [ ] Created "schedules" collection
- [ ] Created "audit_logs" collection
- [ ] Created "notifications" collection
- [ ] Created recommended indexes (optional)
- [ ] Set up security rules
- [ ] Verified collections in console
- [ ] Tested from Flutter app
- [ ] All working! ✅

---

## Next Steps

1. **Test Schedule Creation** - Run the app and create a schedule
2. **Verify Data** - Check Firebase Console to see new documents
3. **Check Real-time Updates** - Dashboard should update automatically
4. **Monitor Firestore Usage** - Check usage in Firebase Console

---

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the DATABASE_FLOW.md for technical details
3. Check Firebase Console for error messages
4. Verify your project ID: `rcbfinal-e7f13`

---

## Video Tutorial (Alternative)

If you prefer video instructions:
1. Search "Firebase Firestore Create Collection" on YouTube
2. Follow along with the steps above
3. The process is the same for all collections
