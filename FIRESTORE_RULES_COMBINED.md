# Combined Firestore Security Rules

## Complete Rules (Users + Admins + Schedules)

Copy and paste this entire block into your Firestore Rules:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // ============================================
    // USERS COLLECTION RULES
    // ============================================
    match /users/{userId} {
      // Allow create during sign up (initial user creation)
      allow create: if request.auth != null && 
        request.auth.uid == userId;
      
      // Allow read if user is authenticated and is the owner
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Allow update if user is authenticated and is the owner
      allow update: if request.auth != null && request.auth.uid == userId;
      
      // Allow delete if user is authenticated and is the owner
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // ============================================
    // ADMINS COLLECTION RULES
    // ============================================
    match /admins/{adminId} {
      // Allow create during sign up (initial admin creation)
      allow create: if request.auth != null && 
        request.auth.uid == adminId;
      
      // Allow read if user is authenticated and is the owner
      allow read: if request.auth != null && request.auth.uid == adminId;
      
      // Allow update if user is authenticated and is the owner
      allow update: if request.auth != null && request.auth.uid == adminId;
      
      // Allow delete if user is authenticated and is the owner
      allow delete: if request.auth != null && request.auth.uid == adminId;
    }
    
    // ============================================
    // SCHEDULES COLLECTION RULES (NEW)
    // ============================================
    // Allow authenticated users to read schedules
    match /schedules/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth.token.role == 'admin';
    }
    
    // ============================================
    // AUDIT LOGS COLLECTION RULES (NEW)
    // ============================================
    // Only admins can read/write audit logs
    match /audit_logs/{document=**} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    
    // ============================================
    // NOTIFICATIONS COLLECTION RULES (NEW)
    // ============================================
    // Users can read/update their own notifications, admins can create
    match /notifications/{document=**} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.role == 'admin';
    }
    
    // ============================================
    // DEFAULT DENY FOR ALL OTHER COLLECTIONS
    // ============================================
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## What Changed

### Added to Your Existing Rules:

1. **schedules** collection
   - Any authenticated user can READ
   - Only admins can CREATE, UPDATE, DELETE

2. **audit_logs** collection
   - Only admins can READ and WRITE

3. **notifications** collection
   - Users can READ and UPDATE their own notifications
   - Only admins can CREATE notifications

### Kept Your Existing Rules:

- ✅ **users** collection - Unchanged
- ✅ **admins** collection - Unchanged
- ✅ Default deny - Unchanged

---

## How to Apply

1. Go to Firebase Console
2. Firestore Database → **Rules** tab
3. Delete all existing text
4. Paste the complete rules above
5. Click **Publish**

---

## Rule Breakdown

### Users Collection
```javascript
match /users/{userId} {
  allow create: if user is authenticated and creating their own document
  allow read: if user is authenticated and reading their own document
  allow update: if user is authenticated and updating their own document
  allow delete: if user is authenticated and deleting their own document
}
```

### Admins Collection
```javascript
match /admins/{adminId} {
  allow create: if admin is authenticated and creating their own document
  allow read: if admin is authenticated and reading their own document
  allow update: if admin is authenticated and updating their own document
  allow delete: if admin is authenticated and deleting their own document
}
```

### Schedules Collection (NEW)
```javascript
match /schedules/{document=**} {
  allow read: if user is authenticated (any user can view schedules)
  allow create, update, delete: if user has admin role
}
```

### Audit Logs Collection (NEW)
```javascript
match /audit_logs/{document=**} {
  allow read, write: if user has admin role (only admins can access)
}
```

### Notifications Collection (NEW)
```javascript
match /notifications/{document=**} {
  allow read, update: if user is reading/updating their own notifications
  allow create: if user has admin role (only admins create notifications)
}
```

### Default Deny
```javascript
match /{document=**} {
  allow read, write: if false;  // Deny everything else
}
```

---

## Security Summary

| Collection | Read | Create | Update | Delete |
|-----------|------|--------|--------|--------|
| users | Owner only | Owner only | Owner only | Owner only |
| admins | Owner only | Owner only | Owner only | Owner only |
| schedules | All authenticated | Admin only | Admin only | Admin only |
| audit_logs | Admin only | Admin only | Admin only | Admin only |
| notifications | Own only | Admin only | Own only | Admin only |
| Others | Denied | Denied | Denied | Denied |

---

## Testing the Rules

### Test 1: User Reading Schedule
✅ Should work - Any authenticated user can read schedules

### Test 2: User Creating Schedule
❌ Should fail - Only admins can create schedules

### Test 3: Admin Creating Schedule
✅ Should work - Admins can create schedules

### Test 4: User Reading Own Notification
✅ Should work - Users can read their own notifications

### Test 5: User Reading Other's Notification
❌ Should fail - Users can't read other users' notifications

### Test 6: Admin Creating Notification
✅ Should work - Admins can create notifications

### Test 7: User Accessing Audit Logs
❌ Should fail - Only admins can access audit logs

### Test 8: Admin Accessing Audit Logs
✅ Should work - Admins can access audit logs

---

## Important Notes

1. **Custom Claims Required**: The rules use `request.auth.token.role == 'admin'`
   - Make sure your admin users have this custom claim set in Firebase Authentication
   - See Firebase Authentication documentation for setting custom claims

2. **User ID Match**: For users/admins collections, the document ID must match the auth UID
   - When creating a user, use their UID as the document ID

3. **Notification User ID**: Notifications must have a `userId` field that matches the authenticated user's UID

4. **Timestamp**: All rules are evaluated at request time

---

## Next Steps

1. Copy the complete rules above
2. Go to Firebase Console → Firestore Database → Rules
3. Paste the rules
4. Click **Publish**
5. Test with your app

---

## Troubleshooting

### Issue: "Permission denied" when creating schedule
**Solution:** Make sure the admin user has `role: 'admin'` custom claim

### Issue: "Permission denied" when reading notification
**Solution:** Make sure the notification has `userId` field matching the authenticated user

### Issue: Rules won't publish
**Solution:** Check for syntax errors (missing brackets, commas, etc.)

### Issue: Admin can't access audit logs
**Solution:** Verify admin has `role: 'admin'` custom claim set

---

## Custom Claims Setup

To set custom claims for admins, use Firebase Admin SDK:

```javascript
// Node.js example
admin.auth().setCustomUserClaims(uid, { role: 'admin' })
  .then(() => {
    console.log('Custom claims set for user:', uid);
  });
```

Or use Firebase Console:
1. Go to Authentication
2. Click on user
3. Scroll to "Custom claims"
4. Add: `{"role": "admin"}`
5. Save

---

## Summary

Your Firestore now has:
- ✅ User authentication rules
- ✅ Admin authentication rules
- ✅ Schedule management rules
- ✅ Audit logging rules
- ✅ Notification rules
- ✅ Default deny for security

**All collections are now secure and ready to use!**
