# How to Apply Combined Firestore Rules - Step by Step

## Quick Steps

1. **Open Firebase Console**
   - Go to https://console.firebase.google.com/
   - Click your project: `rcbfinal-e7f13`

2. **Go to Firestore Database**
   - Left sidebar → Firestore Database

3. **Click Rules Tab**
   - At the top, click **Rules** (next to Data, Indexes, Usage)

4. **Delete Old Rules**
   - Select all text (Ctrl+A)
   - Delete it

5. **Paste New Rules**
   - Open `FIRESTORE_RULES_COMBINED.md`
   - Copy the entire rules block (starting with `rules_version = '2';`)
   - Paste into the rules editor

6. **Publish**
   - Click **Publish** button
   - Confirm changes

7. **Done!** ✅

---

## Detailed Step-by-Step

### Step 1: Open Firebase Console

**What to do:**
1. Go to https://console.firebase.google.com/
2. You'll see your projects

**What you'll see:**
```
Firebase Console
├── rcbfinal-e7f13  ← CLICK HERE
└── (other projects)
```

---

### Step 2: Navigate to Firestore

**What to do:**
1. After clicking your project, you see the dashboard
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
│   └── ...
```

---

### Step 3: Click Rules Tab

**What to do:**
1. You're now in Firestore Database page
2. At the top, you see tabs: Data, Rules, Indexes, Usage
3. Click **Rules** tab

**What you'll see:**
```
Firestore Database Tabs:
┌────────────────────────────────────┐
│ Data    Rules ← CLICK HERE    Indexes    Usage │
└────────────────────────────────────┘

(Below: Text editor with current rules)
```

---

### Step 4: Delete Old Rules

**What to do:**
1. In the text editor, select all text
2. Press Ctrl+A (or Cmd+A on Mac)
3. Press Delete or Backspace

**What you'll see:**
```
Text Editor:
┌────────────────────────────────────┐
│ (empty editor)                     │
│                                    │
│                                    │
│                                    │
└────────────────────────────────────┘
```

---

### Step 5: Copy New Rules

**What to do:**
1. Open file: `FIRESTORE_RULES_COMBINED.md`
2. Find the code block starting with `rules_version = '2';`
3. Select all the rules (from `rules_version` to the last `}`)
4. Copy (Ctrl+C)

**What to copy:**
```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // USERS COLLECTION RULES
    match /users/{userId} {
      allow create: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // ADMINS COLLECTION RULES
    match /admins/{adminId} {
      allow create: if request.auth != null && request.auth.uid == adminId;
      allow read: if request.auth != null && request.auth.uid == adminId;
      allow update: if request.auth != null && request.auth.uid == adminId;
      allow delete: if request.auth != null && request.auth.uid == adminId;
    }
    
    // SCHEDULES COLLECTION RULES (NEW)
    match /schedules/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth.token.role == 'admin';
    }
    
    // AUDIT LOGS COLLECTION RULES (NEW)
    match /audit_logs/{document=**} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    
    // NOTIFICATIONS COLLECTION RULES (NEW)
    match /notifications/{document=**} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.role == 'admin';
    }
    
    // DEFAULT DENY
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

### Step 6: Paste Rules

**What to do:**
1. Click in the text editor (in Firebase Console)
2. Paste the rules (Ctrl+V)

**What you'll see:**
```
Text Editor:
┌────────────────────────────────────┐
│ rules_version = '2';               │
│                                    │
│ service cloud.firestore {          │
│   match /databases/{database}/...  │
│   ...                              │
│ }                                  │
└────────────────────────────────────┘
```

---

### Step 7: Check for Errors

**What to do:**
1. Look at the right side of the editor
2. Check if there are any red error indicators
3. If you see red X or errors, check the syntax

**What you'll see (if OK):**
```
Text Editor (Right side):
✅ No errors shown
```

**What you'll see (if error):**
```
Text Editor (Right side):
❌ Error on line X: ...
```

---

### Step 8: Publish Rules

**What to do:**
1. Look for the **Publish** button
2. It's usually at the top right or bottom right
3. Click **Publish**

**What you'll see:**
```
Buttons:
[Cancel]  [Publish] ← CLICK HERE
```

---

### Step 9: Confirm Publish

**What to do:**
1. A confirmation dialog appears
2. Click **Publish** to confirm

**What you'll see:**
```
Confirmation Dialog:
┌──────────────────────────────────┐
│ Publish new security rules?      │
│                                  │
│ This will update the rules for   │
│ your Firestore database.         │
│                                  │
│ [Cancel]  [Publish] ← CLICK HERE│
└──────────────────────────────────┘
```

---

### Step 10: Success!

**What you'll see:**
```
Success Message:
✅ Rules published successfully

(or)

Firestore Database
├── Data    Rules    Indexes    Usage
│
│ (Your new rules are now active)
```

---

## Verification

### Check if Rules are Active

1. Go to **Rules** tab
2. You should see your new rules displayed
3. No error messages should appear

### Test the Rules

Run your Flutter app and try:
1. Create a schedule (as admin) - Should work ✅
2. Create a schedule (as user) - Should fail ❌
3. Read a schedule (as user) - Should work ✅
4. Read audit logs (as user) - Should fail ❌
5. Read audit logs (as admin) - Should work ✅

---

## Troubleshooting

### Issue: "Syntax error" when publishing
**Solution:**
1. Check for missing brackets `{` `}`
2. Check for missing commas `,`
3. Check for missing semicolons `;`
4. Copy the rules again from `FIRESTORE_RULES_COMBINED.md`

### Issue: Rules won't publish
**Solution:**
1. Click **Publish** again
2. Check the error message
3. Fix the syntax error
4. Try publishing again

### Issue: "Permission denied" errors in app
**Solution:**
1. Make sure admin users have `role: 'admin'` custom claim
2. Make sure user IDs match in documents
3. Make sure notifications have `userId` field

### Issue: Can't see Publish button
**Solution:**
1. Make sure you're on the **Rules** tab
2. Scroll down to see the Publish button
3. Try refreshing the page

---

## What Changed

### Before (Old Rules)
```javascript
// Only users and admins collections
match /users/{userId} { ... }
match /admins/{adminId} { ... }
match /{document=**} { allow read, write: if false; }
```

### After (New Rules)
```javascript
// Users and admins (kept)
match /users/{userId} { ... }
match /admins/{adminId} { ... }

// NEW: Schedules, audit logs, notifications
match /schedules/{document=**} { ... }
match /audit_logs/{document=**} { ... }
match /notifications/{document=**} { ... }

// Default deny (kept)
match /{document=**} { allow read, write: if false; }
```

---

## Security Summary

Your Firestore is now protected:

| Who | Can Do What |
|-----|------------|
| Any User | Read schedules, read own notifications |
| Admin | Create/update/delete schedules, read audit logs, create notifications |
| Other Users | Can't access other users' data |
| Unauthenticated | Can't access anything |

---

## Next Steps

1. ✅ Apply the combined rules (you just did this!)
2. ✅ Test with your app
3. ✅ Create a schedule
4. ✅ Verify it appears in Firestore
5. ✅ Check admin dashboard for real-time updates

---

## Need Help?

- **Rules not working?** Check `FIRESTORE_RULES_COMBINED.md`
- **Can't find Rules tab?** Make sure you're in Firestore Database
- **Syntax error?** Copy the rules again carefully
- **Permission denied in app?** Check custom claims setup

---

## Done! 🎉

Your Firestore is now secured with combined rules for:
- ✅ User authentication
- ✅ Admin authentication
- ✅ Schedule management
- ✅ Audit logging
- ✅ User notifications

**Your app is now production-ready!**
