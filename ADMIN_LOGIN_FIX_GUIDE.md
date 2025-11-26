# Admin Login Fix - Complete Guide

## Problem
When logging in with `admin@gmail.com`, the user was seeing the **User Dashboard** instead of the **Admin Dashboard**.

## Root Cause
The dashboards had **no role-based access protection**. Even though the sign-in logic correctly navigated based on role, there was no guard to prevent:
- Non-admins from manually accessing `/admin-dashboard`
- Admins from manually accessing `/user-dashboard`

## Solution Implemented

### 1. **AdminDashboard Protection** ✅
Added role check in `lib/pages/admin_dashboard.dart`:
- **initState()**: Checks if user is admin on page load
- **build()**: Double-checks role before rendering content
- **Redirect**: Non-admins are redirected to `/user-dashboard`

### 2. **UserDashboard Protection** ✅
Added role check in `lib/pages/user_dashboard.dart`:
- **initState()**: Checks if user is admin on page load
- **build()**: Double-checks role before rendering content
- **Redirect**: Admins are redirected to `/admin-dashboard`

## Database Verification Checklist

### ✅ Step 1: Check Firestore Collections
Your Firestore should have **TWO separate collections**:

**Collection: `admins`**
```
Document ID: [user_uid]
{
  "uid": "user_uid",
  "email": "admin@gmail.com",
  "name": "Admin Name",
  "role": "admin",           ← MUST be "admin" (string)
  "isEmailVerified": true,
  "createdAt": "2024-...",
  "lastLogin": "2024-..."
}
```

**Collection: `users`**
```
Document ID: [user_uid]
{
  "uid": "user_uid",
  "email": "user@gmail.com",
  "name": "User Name",
  "role": "user",            ← MUST be "user" (string)
  "isEmailVerified": true,
  "createdAt": "2024-...",
  "lastLogin": "2024-..."
}
```

### ✅ Step 2: Verify admin@gmail.com Entry

**Check if admin@gmail.com exists in the `admins` collection:**

1. Go to Firebase Console → Firestore Database
2. Look for collection named `admins`
3. Find document with email = `admin@gmail.com`
4. Verify the `role` field = `"admin"` (NOT `"Admin"` or `"ADMIN"`)

**If admin@gmail.com is in the `users` collection instead:**
- ❌ **WRONG**: It was created as a regular user
- ✅ **FIX**: Delete from `users` and manually create in `admins` collection

### ✅ Step 3: Manual Database Fix (If Needed)

If `admin@gmail.com` is in the wrong collection:

**Option A: Using Firebase Console**
1. Delete the document from `users` collection
2. Create new document in `admins` collection
3. Set fields:
   - `uid`: [same Firebase Auth UID]
   - `email`: `admin@gmail.com`
   - `name`: `Admin`
   - `role`: `admin`
   - `isEmailVerified`: `true`
   - `createdAt`: [current timestamp]

**Option B: Using Code (Create a migration script)**
```dart
// Add this to auth_provider.dart temporarily to fix existing admin
Future<void> fixAdminRole(String adminEmail) async {
  try {
    // Find user in users collection
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final doc = userQuery.docs.first;
      final data = doc.data();
      
      // Move to admins collection
      await _firestore.collection('admins').doc(doc.id).set(data);
      
      // Delete from users collection
      await _firestore.collection('users').doc(doc.id).delete();
      
      print('✅ Admin role fixed for $adminEmail');
    }
  } catch (e) {
    print('❌ Error fixing admin role: $e');
  }
}
```

## Testing the Fix

### Test Case 1: Admin Login
```
1. Login with: admin@gmail.com
2. Expected: Redirected to Admin Dashboard ✅
3. Check console logs for: "✅ Access granted - User is admin"
```

### Test Case 2: User Login
```
1. Login with: user@gmail.com
2. Expected: Redirected to User Dashboard ✅
3. Check console logs for: "✅ Access granted - User is regular user"
```

### Test Case 3: Manual URL Navigation
```
1. Login as user@gmail.com
2. Manually navigate to /admin-dashboard
3. Expected: Redirected back to /user-dashboard ✅
```

### Test Case 4: Admin Manual Navigation
```
1. Login as admin@gmail.com
2. Manually navigate to /user-dashboard
3. Expected: Redirected back to /admin-dashboard ✅
```

## Code Changes Summary

### Files Modified:
1. **lib/pages/admin_dashboard.dart**
   - Added `initState()` with `_checkAdminAccess()`
   - Added role check in `build()` method

2. **lib/pages/user_dashboard.dart**
   - Added `initState()` with `_checkUserAccess()`
   - Added role check in `build()` method

### How It Works:
1. **First Check**: `initState()` runs when page loads
   - Checks if user has correct role
   - Redirects immediately if wrong role

2. **Second Check**: `build()` method runs during render
   - Double-checks role before showing content
   - Shows "Unauthorized access" message if wrong role

3. **Result**: User cannot access wrong dashboard even if they try to navigate directly

## Debugging Tips

If admin still sees user dashboard:

1. **Check Console Logs**:
   - Look for: `👤 Is admin: true/false`
   - Look for: `✅ Access granted` or `❌ Access denied`

2. **Check Firestore**:
   - Verify `admin@gmail.com` is in `admins` collection
   - Verify `role` field = `"admin"` (lowercase string)

3. **Check AuthProvider**:
   - `authProvider.isAdmin` should return `true` for admins
   - `authProvider.userRole` should be `UserRole.admin`

4. **Clear Cache**:
   - Hot restart the app
   - Clear app data and login again

## Next Steps

1. ✅ Code changes deployed
2. ⏳ Verify admin@gmail.com is in `admins` collection with `role: "admin"`
3. ⏳ Test login with admin@gmail.com
4. ⏳ Verify admin sees Admin Dashboard
5. ⏳ Test login with regular user account
6. ⏳ Verify user sees User Dashboard
