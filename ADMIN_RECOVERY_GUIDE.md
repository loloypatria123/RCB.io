# 🔄 Admin Recovery Guide

## Problem
You deleted the `admins` collection in Firestore, but the admin account still exists in Firebase Authentication. When you login, the app can't find the admin document and treats you as a regular user.

## Solution
I've created an **Admin Recovery Page** that automatically detects this situation and helps you recover the admin account.

---

## How It Works

### Automatic Detection
When you login with an admin email (containing "admin") and the Firestore document is missing:
1. App detects: Firebase Auth user exists but Firestore document is missing
2. App shows: Admin Recovery Page
3. You enter: Admin name
4. You click: "Recover Admin Account"
5. App creates: Admin document in Firestore
6. You see: Admin Dashboard ✅

---

## Step-by-Step

### Step 1: Login with Admin Email
```
Email: admin@gmail.com
Password: [your_password]
```

### Step 2: App Detects Missing Admin
Console shows:
```
⚠️ Admin account detected but Firestore document missing!
🔄 Showing admin recovery page...
```

### Step 3: Admin Recovery Page Appears
- Shows your Firebase UID
- Shows your email
- Asks for admin name

### Step 4: Enter Admin Name
```
Admin Name: Admin
```

### Step 5: Click "Recover Admin Account"
- App recreates admin document in Firestore
- Sets role to "admin"
- Marks email as verified
- Redirects to Admin Dashboard

### Step 6: Admin Dashboard Appears ✅
You're now logged in as admin!

---

## What Gets Recreated

When you click "Recover Admin Account", the following is created in Firestore:

**Collection**: `admins`
**Document ID**: `[your_firebase_uid]`

```json
{
  "uid": "mzdznlJxv3R7rTNmRqC16nPiBl22",
  "email": "admin@gmail.com",
  "name": "Admin",
  "role": "admin",
  "isEmailVerified": true,
  "createdAt": "2025-11-26T02:23:00.000Z",
  "lastLogin": "2025-11-26T02:23:00.000Z"
}
```

---

## Console Output

When recovery is successful, you'll see:

```
🔄 Recovering admin account...
   UID: mzdznlJxv3R7rTNmRqC16nPiBl22
   Email: admin@gmail.com
   Name: Admin
✅ Admin account recovered successfully!
📝 Reloading user model from Firestore...
✅ Access granted - User is admin
```

---

## Files Created/Modified

### New Files
- `lib/pages/admin_recovery_page.dart` - Recovery UI
- `ADMIN_RECOVERY_GUIDE.md` - This guide

### Modified Files
- `lib/providers/auth_provider.dart` - Added `recoverAdminAccount()` method
- `lib/pages/sign_in_page.dart` - Added recovery detection
- `lib/main.dart` - Added `/admin-recovery` route

---

## Testing

### Test 1: Delete Admin Collection
1. Go to Firebase Console
2. Delete the `admins` collection
3. Keep admin account in Firebase Auth

### Test 2: Login with Admin Email
```
Email: admin@gmail.com
Password: [your_password]
```

### Test 3: Recovery Page Appears
- You should see the recovery page
- Enter admin name
- Click "Recover Admin Account"

### Test 4: Admin Dashboard Appears
- You should be redirected to Admin Dashboard ✅

---

## Troubleshooting

### Issue: Recovery page doesn't appear
**Cause**: Email doesn't contain "admin"
**Solution**: Make sure you're using an email with "admin" in it

### Issue: "Failed to recover admin account"
**Cause**: Firestore permission issue
**Solution**: Check Firebase Firestore security rules

### Issue: Still seeing user dashboard after recovery
**Cause**: App cache
**Solution**: 
1. Hot restart: Press `R` in terminal
2. Login again

---

## Manual Recovery (Alternative)

If the automatic recovery doesn't work, you can manually recreate the admin document:

1. Go to Firebase Console
2. Go to Firestore Database
3. Create collection: `admins`
4. Create document with ID: `[your_firebase_uid]`
5. Add fields:
   ```
   uid: "your_firebase_uid"
   email: "admin@gmail.com"
   name: "Admin"
   role: "admin"
   isEmailVerified: true
   createdAt: (current timestamp)
   lastLogin: (current timestamp)
   ```
6. Login again

---

## Code Reference

### Recovery Method
```dart
// In AuthProvider
Future<bool> recoverAdminAccount({
  required String uid,
  required String email,
  required String name,
}) async {
  // Recreates admin document in Firestore
  // Reloads user model
  // Returns success/failure
}
```

### Detection Logic
```dart
// In SignInPage
if (authProvider.user != null && 
    authProvider.userModel == null &&
    _emailController.text.toLowerCase().contains('admin')) {
  // Show recovery page
}
```

---

## Summary

✅ **Automatic Detection**: App detects missing admin document
✅ **Easy Recovery**: Click button to recover
✅ **Firestore Recreation**: Admin document recreated automatically
✅ **Instant Access**: Redirected to Admin Dashboard

---

**Status**: ✅ Ready to Use
**Last Updated**: November 26, 2025
