# Visual Step-by-Step Firebase Setup

## Overview
This guide shows exactly what you'll see on your screen at each step.

---

## STEP 1: Open Firebase Console

**What you'll do:**
1. Go to https://console.firebase.google.com/
2. You'll see your projects list
3. Click on **rcbfinal-e7f13**

**What you'll see:**
```
Firebase Console
├── Projects
│   ├── rcbfinal-e7f13  ← CLICK HERE
│   └── (other projects)
```

---

## STEP 2: Navigate to Firestore Database

**What you'll do:**
1. After clicking your project, you'll see the Firebase dashboard
2. Look at the left sidebar
3. Find **Build** section
4. Click **Firestore Database**

**What you'll see:**
```
Left Sidebar:
├── Build
│   ├── Authentication
│   ├── Firestore Database  ← CLICK HERE
│   ├── Realtime Database
│   ├── Storage
│   └── ...
```

---

## STEP 3: Start Creating First Collection (schedules)

**What you'll do:**
1. You'll see the Firestore main page
2. There's a big button that says **"+ Start collection"** or **"Create collection"**
3. Click it

**What you'll see:**
```
Firestore Database Page
┌─────────────────────────────────────┐
│  Firestore Database                 │
│                                     │
│  [+ Start collection] ← CLICK HERE  │
│                                     │
│  (Empty database message)           │
└─────────────────────────────────────┘
```

---

## STEP 4: Name the Collection "schedules"

**What you'll do:**
1. A dialog box appears asking for collection name
2. Type: `schedules` (exactly as shown, lowercase)
3. Click **Next**

**What you'll see:**
```
Dialog Box:
┌──────────────────────────────────┐
│ Create a collection              │
│                                  │
│ Collection ID:                   │
│ [schedules____________]          │
│                                  │
│ [Cancel]  [Next] ← CLICK NEXT   │
└──────────────────────────────────┘
```

---

## STEP 5: Add First Document to "schedules"

**What you'll do:**
1. Next dialog appears asking to add first document
2. Click **Auto ID** button (to generate automatic ID)
3. This creates a document with an auto-generated ID

**What you'll see:**
```
Dialog Box:
┌──────────────────────────────────┐
│ Add the first document            │
│                                  │
│ Document ID:                     │
│ [Auto ID] ← CLICK THIS           │
│                                  │
│ [Cancel]  [Next]                │
└──────────────────────────────────┘
```

---

## STEP 6: Add Fields to First Document

**What you'll do:**
1. Now you see a form to add fields
2. For each field, click **Add field**
3. Enter field name, select type, enter value
4. Repeat for all fields below

**What you'll see:**
```
Form:
┌────────────────────────────────────┐
│ Add fields to document             │
│                                    │
│ Field 1:                           │
│ Name: [id____________]             │
│ Type: [String ▼]                   │
│ Value: [schedule_001_____]         │
│                                    │
│ [+ Add field] ← CLICK TO ADD MORE  │
│                                    │
│ [Cancel]  [Save]                  │
└────────────────────────────────────┘
```

**Fields to add for "schedules":**

1. **id** (String)
   - Name: `id`
   - Type: `String`
   - Value: `schedule_001`

2. **adminId** (String)
   - Name: `adminId`
   - Type: `String`
   - Value: `admin_123`

3. **title** (String)
   - Name: `title`
   - Type: `String`
   - Value: `Sample Schedule`

4. **description** (String)
   - Name: `description`
   - Type: `String`
   - Value: `Sample Description`

5. **status** (String)
   - Name: `status`
   - Type: `String`
   - Value: `scheduled`

6. **scheduledDate** (Timestamp)
   - Name: `scheduledDate`
   - Type: `Timestamp`
   - Value: (click calendar, select today)

7. **createdAt** (Timestamp)
   - Name: `createdAt`
   - Type: `Timestamp`
   - Value: (click calendar, select today)

---

## STEP 7: Save First Collection

**What you'll do:**
1. After adding all fields, click **Save** button
2. The "schedules" collection is created!

**What you'll see:**
```
After saving:
┌────────────────────────────────────┐
│ Firestore Database                 │
│                                    │
│ Collections:                       │
│ ├── schedules ✅ (created!)       │
│ │   └── (auto_id_123)             │
│ │       ├── id: "schedule_001"    │
│ │       ├── adminId: "admin_123"  │
│ │       └── ...                   │
│                                    │
└────────────────────────────────────┘
```

---

## STEP 8: Create Second Collection (audit_logs)

**What you'll do:**
1. Click **+ Create collection** button (or **+ Start collection**)
2. Type: `audit_logs`
3. Click **Next**
4. Click **Auto ID**
5. Add these fields:

**Fields for "audit_logs":**

1. **id** (String): `log_001`
2. **adminId** (String): `admin_123`
3. **adminEmail** (String): `admin@example.com`
4. **adminName** (String): `John Admin`
5. **action** (String): `scheduleCreated`
6. **description** (String): `Created schedule`
7. **timestamp** (Timestamp): (today)

6. Click **Save**

**What you'll see:**
```
After saving:
┌────────────────────────────────────┐
│ Collections:                       │
│ ├── schedules ✅                  │
│ └── audit_logs ✅ (created!)      │
│     └── (auto_id_456)             │
│         ├── id: "log_001"         │
│         ├── adminId: "admin_123"  │
│         └── ...                   │
└────────────────────────────────────┘
```

---

## STEP 9: Create Third Collection (notifications)

**What you'll do:**
1. Click **+ Create collection** button
2. Type: `notifications`
3. Click **Next**
4. Click **Auto ID**
5. Add these fields:

**Fields for "notifications":**

1. **id** (String): `notif_001`
2. **userId** (String): `user_123`
3. **type** (String): `scheduleAdded`
4. **title** (String): `New Schedule`
5. **message** (String): `You have a new schedule`
6. **isRead** (Boolean): `false`
7. **createdAt** (Timestamp): (today)

6. Click **Save**

**What you'll see:**
```
After saving:
┌────────────────────────────────────┐
│ Collections:                       │
│ ├── schedules ✅                  │
│ ├── audit_logs ✅                 │
│ └── notifications ✅ (created!)   │
│     └── (auto_id_789)             │
│         ├── id: "notif_001"       │
│         ├── userId: "user_123"    │
│         └── ...                   │
└────────────────────────────────────┘
```

---

## STEP 10: Verify All Collections

**What you'll do:**
1. Look at the left side of Firestore Database page
2. You should see all three collections listed

**What you'll see:**
```
Firestore Database
├── Data    Rules    Indexes    Usage
│
├── schedules ✅
│   └── (1 document)
├── audit_logs ✅
│   └── (1 document)
└── notifications ✅
    └── (1 document)
```

---

## STEP 11: Set Up Security Rules (Optional but Recommended)

**What you'll do:**
1. Click the **Rules** tab at the top
2. Delete all existing text
3. Paste the security rules code (see below)
4. Click **Publish**

**What you'll see:**
```
Firestore Database
├── Data    Rules ← CLICK HERE    Indexes    Usage
│
│ (Text editor with rules)
│
│ [Publish] ← CLICK WHEN DONE
```

**Rules to paste:**
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

---

## STEP 12: Create Indexes (Optional but Recommended)

**What you'll do:**
1. Click the **Indexes** tab
2. Click **Create Index** button
3. Fill in the form for each index

**What you'll see:**
```
Firestore Database
├── Data    Rules    Indexes ← CLICK HERE    Usage
│
│ [Create Index] ← CLICK THIS
│
│ Indexes:
│ ├── (building...)
│ └── (building...)
```

**Index 1: schedules by date**
- Collection ID: `schedules`
- Field: `scheduledDate` (Ascending)
- Click **Create Index**

**Index 2: schedules by user and date**
- Collection ID: `schedules`
- Fields:
  - `assignedUserId` (Ascending)
  - `scheduledDate` (Descending)
- Click **Create Index**

**Index 3: audit_logs by timestamp**
- Collection ID: `audit_logs`
- Field: `timestamp` (Descending)
- Click **Create Index**

**Index 4: notifications by user and date**
- Collection ID: `notifications`
- Fields:
  - `userId` (Ascending)
  - `createdAt` (Descending)
- Click **Create Index**

---

## STEP 13: Verify Everything Works

**What you'll do:**
1. Go back to **Data** tab
2. Expand each collection to see documents
3. Click on documents to view fields

**What you'll see:**
```
Firestore Database - Data Tab

schedules
├── auto_id_123
│   ├── id: "schedule_001"
│   ├── adminId: "admin_123"
│   ├── title: "Sample Schedule"
│   ├── description: "Sample Description"
│   ├── status: "scheduled"
│   ├── scheduledDate: (timestamp)
│   └── createdAt: (timestamp)

audit_logs
├── auto_id_456
│   ├── id: "log_001"
│   ├── adminId: "admin_123"
│   ├── adminEmail: "admin@example.com"
│   ├── adminName: "John Admin"
│   ├── action: "scheduleCreated"
│   ├── description: "Created schedule"
│   └── timestamp: (timestamp)

notifications
├── auto_id_789
│   ├── id: "notif_001"
│   ├── userId: "user_123"
│   ├── type: "scheduleAdded"
│   ├── title: "New Schedule"
│   ├── message: "You have a new schedule"
│   ├── isRead: false
│   └── createdAt: (timestamp)
```

---

## STEP 14: Test from Your Flutter App

**What you'll do:**
1. Run your Flutter app
2. The app will connect to Firestore
3. You should see the collections in Firebase Console

**To verify:**
1. Keep Firebase Console open
2. Run your app
3. Create a schedule from your app
4. Refresh Firebase Console
5. You should see new documents appear!

---

## ✅ Completion Checklist

- [ ] Opened Firebase Console
- [ ] Navigated to Firestore Database
- [ ] Created "schedules" collection
- [ ] Created "audit_logs" collection
- [ ] Created "notifications" collection
- [ ] Set up security rules
- [ ] Created indexes (optional)
- [ ] Verified all collections exist
- [ ] Ready to use in app!

---

## Common Mistakes to Avoid

❌ **Wrong:** Collection name is `Schedules` (capital S)  
✅ **Right:** Collection name is `schedules` (lowercase)

❌ **Wrong:** Field name is `AdminId`  
✅ **Right:** Field name is `adminId` (camelCase)

❌ **Wrong:** Forgot to click **Add field** for each field  
✅ **Right:** Clicked **Add field** for each field

❌ **Wrong:** Didn't click **Save** at the end  
✅ **Right:** Clicked **Save** to save the collection

---

## Need Help?

If something looks different:
1. Make sure you're in the correct Firebase project (rcbfinal-e7f13)
2. Check that Firestore is enabled
3. Try refreshing the page
4. Clear browser cache if needed

---

## Next: Test Your Setup

After completing these steps:
1. Go to `IMPLEMENTATION_GUIDE.md` for next steps
2. Create a schedule from your app
3. Watch it appear in Firebase Console in real-time!
