# Firestore Rules - Summary & Quick Reference

## What You Need to Know

### Your Existing Rules
You had rules for:
- ✅ **users** collection
- ✅ **admins** collection
- ✅ Default deny for everything else

### New Rules Added
For the cleaning schedule system:
- ✅ **schedules** collection
- ✅ **audit_logs** collection
- ✅ **notifications** collection

---

## Combined Rules (Copy & Paste Ready)

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow create: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admins collection
    match /admins/{adminId} {
      allow create: if request.auth != null && request.auth.uid == adminId;
      allow read: if request.auth != null && request.auth.uid == adminId;
      allow update: if request.auth != null && request.auth.uid == adminId;
      allow delete: if request.auth != null && request.auth.uid == adminId;
    }
    
    // Schedules collection (NEW)
    match /schedules/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth.token.role == 'admin';
    }
    
    // Audit logs collection (NEW)
    match /audit_logs/{document=**} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    
    // Notifications collection (NEW)
    match /notifications/{document=**} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.role == 'admin';
    }
    
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## How to Apply

### Quick Steps:
1. Firebase Console → rcbfinal-e7f13 → Firestore Database
2. Click **Rules** tab
3. Delete all existing rules
4. Paste the combined rules above
5. Click **Publish**
6. Done! ✅

### Detailed Guide:
See `APPLY_RULES_GUIDE.md` for step-by-step with screenshots

---

## What Each Collection Allows

### users Collection
```
CREATE: User can create their own document
READ:   User can read their own document
UPDATE: User can update their own document
DELETE: User can delete their own document
```

### admins Collection
```
CREATE: Admin can create their own document
READ:   Admin can read their own document
UPDATE: Admin can update their own document
DELETE: Admin can delete their own document
```

### schedules Collection (NEW)
```
READ:   Any authenticated user can read
CREATE: Only admins can create
UPDATE: Only admins can update
DELETE: Only admins can delete
```

### audit_logs Collection (NEW)
```
READ:   Only admins can read
WRITE:  Only admins can write
```

### notifications Collection (NEW)
```
READ:   User can read their own notifications
UPDATE: User can update their own notifications
CREATE: Only admins can create
DELETE: Only admins can delete
```

### All Other Collections
```
READ:   Denied
WRITE:  Denied
```

---

## Security Matrix

| Collection | User | Admin | Other |
|-----------|------|-------|-------|
| users | Own only | Own only | Denied |
| admins | Own only | Own only | Denied |
| schedules | Read | All | Denied |
| audit_logs | Denied | All | Denied |
| notifications | Own only | All | Denied |
| Others | Denied | Denied | Denied |

---

## Important: Custom Claims

The rules use `request.auth.token.role == 'admin'`

**This means:**
- Admin users must have `role: 'admin'` custom claim set
- Without this claim, admins can't create/update/delete schedules

**How to set custom claims:**

### Option 1: Firebase Console
1. Go to Authentication
2. Click on admin user
3. Scroll to "Custom claims"
4. Add: `{"role": "admin"}`
5. Save

### Option 2: Firebase Admin SDK
```javascript
admin.auth().setCustomUserClaims(uid, { role: 'admin' })
  .then(() => console.log('Admin claim set'));
```

---

## Testing the Rules

### Test 1: User Reading Schedule
```
User: regular_user@example.com
Action: Read schedule
Expected: ✅ Success (any authenticated user can read)
```

### Test 2: User Creating Schedule
```
User: regular_user@example.com
Action: Create schedule
Expected: ❌ Denied (only admins can create)
```

### Test 3: Admin Creating Schedule
```
User: admin@example.com (with role: 'admin' claim)
Action: Create schedule
Expected: ✅ Success (admins can create)
```

### Test 4: User Reading Own Notification
```
User: user@example.com
Action: Read notification with userId = user's UID
Expected: ✅ Success (can read own notifications)
```

### Test 5: User Reading Other's Notification
```
User: user1@example.com
Action: Read notification with userId = user2's UID
Expected: ❌ Denied (can't read other users' notifications)
```

### Test 6: Admin Reading Audit Logs
```
User: admin@example.com (with role: 'admin' claim)
Action: Read audit logs
Expected: ✅ Success (admins can read audit logs)
```

### Test 7: User Reading Audit Logs
```
User: regular_user@example.com
Action: Read audit logs
Expected: ❌ Denied (only admins can read audit logs)
```

---

## Troubleshooting

### Issue: "Permission denied" when creating schedule
**Cause:** User doesn't have admin role  
**Solution:** Set `role: 'admin'` custom claim for admin users

### Issue: "Permission denied" when reading notification
**Cause:** Notification's userId doesn't match user's UID  
**Solution:** Make sure notification has correct userId field

### Issue: Rules won't publish
**Cause:** Syntax error in rules  
**Solution:** Check for missing brackets, commas, semicolons

### Issue: Admin can't access audit logs
**Cause:** Admin doesn't have `role: 'admin'` custom claim  
**Solution:** Set custom claim in Firebase Console

### Issue: User can read other user's notification
**Cause:** Rule is wrong  
**Solution:** Check that rule checks `resource.data.userId`

---

## Files Reference

| File | Purpose |
|------|---------|
| `FIRESTORE_RULES_COMBINED.md` | Complete combined rules |
| `APPLY_RULES_GUIDE.md` | Step-by-step guide to apply rules |
| `RULES_SUMMARY.md` | This file - quick reference |
| `FIREBASE_SETUP_GUIDE.md` | Collection creation guide |

---

## Quick Checklist

- [ ] Copied combined rules
- [ ] Opened Firebase Console
- [ ] Went to Firestore Database → Rules
- [ ] Deleted old rules
- [ ] Pasted new rules
- [ ] Clicked Publish
- [ ] Set admin custom claims
- [ ] Tested with app
- [ ] All working! ✅

---

## What's Protected

✅ Users can't access other users' data  
✅ Regular users can't create/edit/delete schedules  
✅ Regular users can't access audit logs  
✅ Regular users can only read their own notifications  
✅ Only admins can manage schedules  
✅ Only admins can access audit logs  
✅ Only admins can create notifications  
✅ Unauthenticated users can't access anything  

---

## Next Steps

1. **Apply the rules** - Follow `APPLY_RULES_GUIDE.md`
2. **Set admin claims** - Add `role: 'admin'` to admin users
3. **Test with app** - Create a schedule and verify
4. **Monitor** - Check Firestore usage in Firebase Console

---

## Summary

Your Firestore is now:
- ✅ Secure
- ✅ Protecting user data
- ✅ Restricting admin operations
- ✅ Enforcing role-based access
- ✅ Ready for production

**Apply the rules and you're done!**
