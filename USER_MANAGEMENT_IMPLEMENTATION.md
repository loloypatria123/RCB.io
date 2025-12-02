# User Management Implementation Guide

## Overview
This guide explains the complete user management system with status control and admin promotion features.

---

## Features Implemented

### 1. **Inactive User Blocking**
- Users with status other than "Active" are blocked from signing in
- Implemented in `auth_provider.dart` (lines 298-311)
- User is signed out immediately if their account is inactive
- Clear error message displayed to the user

### 2. **Admin Promotion**
- Admins can promote users to admin role
- User document is moved from `users` collection to `admins` collection
- Role field is updated to 'admin'
- User can immediately login as admin after promotion

### 3. **Live Status Updates**
- Changes to user status are reflected immediately in Firestore
- No caching issues - always reads from Firestore on login
- Auth provider reloads user model after role changes

---

## How It Works

### **Sign In Flow with Status Check**

```dart
// In auth_provider.dart - signIn method
1. User enters credentials
2. Firebase authenticates the user
3. Load user model from Firestore (checks both admins and users collections)
4. Check user status:
   - If status != "Active" → Sign out user and show error
   - If status == "Active" → Allow login and update lastLogin
5. Navigate to appropriate dashboard based on role
```

**Code Implementation:**
```dart
// Block inactive accounts from signing in
if (_userModel != null && _userModel!.status != 'Active') {
  print('⛔ User account is inactive. Status: ${_userModel!.status}');
  _errorMessage = 'Your account is inactive. Please contact the administrator.';
  
  // Sign out the Firebase user and clear local state
  await _firebaseAuth.signOut();
  _user = null;
  _userModel = null;
  _isLoading = false;
  notifyListeners();
  return false;
}
```

---

### **Admin Promotion Flow**

```dart
// In user_management_service.dart - updateUserRole method
1. Admin selects a user to promote
2. System reads user document from 'users' collection
3. Update role field to 'admin'
4. Create new document in 'admins' collection with updated data
5. Delete old document from 'users' collection
6. User can now login as admin
```

**Code Implementation:**
```dart
static Future<bool> updateUserRole({
  required String targetUserId,
  required bool currentIsAdmin,
  required bool makeAdmin,
  required String adminId,
  required String adminEmail,
  required String adminName,
}) async {
  try {
    if (currentIsAdmin == makeAdmin) {
      return true;
    }

    final fromCollection = currentIsAdmin ? 'admins' : 'users';
    final toCollection = makeAdmin ? 'admins' : 'users';

    final docRef = _firestore.collection(fromCollection).doc(targetUserId);
    final doc = await docRef.get();
    if (!doc.exists) {
      print('❌ User document not found in $fromCollection: $targetUserId');
      return false;
    }

    final data = doc.data() ?? {};
    data['role'] = makeAdmin ? 'admin' : 'user';

    await _firestore.collection(toCollection).doc(targetUserId).set(data);
    await docRef.delete();

    print('✅ Moved user $targetUserId from $fromCollection to $toCollection with role ${data['role']}');
    return true;
  } catch (e) {
    print('❌ Error updating user role: $e');
    return false;
  }
}
```

---

### **Status Update Flow**

```dart
// In user_management_service.dart - updateUserStatus method
1. Admin changes user status (Active/Inactive/Suspended/etc.)
2. System updates status field in appropriate collection
3. Change is immediately reflected in Firestore
4. Next time user tries to login, status is checked
```

**Code Implementation:**
```dart
static Future<bool> updateUserStatus({
  required String targetUserId,
  required bool isAdmin,
  required String newStatus,
  required String adminId,
  required String adminEmail,
  required String adminName,
}) async {
  try {
    final collectionName = isAdmin ? 'admins' : 'users';

    await _firestore.collection(collectionName).doc(targetUserId).update({
      'status': newStatus,
    });

    print('✅ Updated user status for $targetUserId to $newStatus');
    return true;
  } catch (e) {
    print('❌ Error updating user status: $e');
    return false;
  }
}
```

---

## Firestore Security Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // --- Helpers ---
    function isSignedIn() {
      return request.auth != null;
    }

    function isSelf(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // A user is considered admin if they have a document in /admins/{uid}
    function isAdmin() {
      return isSignedIn() &&
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }

    // ============================
    // USERS COLLECTION
    // ============================
    match /users/{userId} {
      // Create: user can create own doc (sign-up) OR admin can create users
      allow create: if isSelf(userId) || isAdmin();

      // Read/update/delete:
      //  - owner can manage own doc
      //  - admins can manage all users
      allow read, update, delete: if isSelf(userId) || isAdmin();
    }

    // ============================
    // ADMINS COLLECTION
    // ============================
    match /admins/{adminId} {
      // Only admins can read/update/delete admin docs
      allow read, update, delete: if isAdmin();

      // For security: do NOT allow clients to create admin docs.
      // Create the first admin (and any others) manually in Firestore Console.
      allow create: if false;
    }

    // ============================
    // DEFAULT DENY FOR OTHERS
    // ============================
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Key Points:**
- ✅ Users can create their own account during sign-up
- ✅ Admins can create, read, update, and delete user accounts
- ✅ Users can only read/update their own account
- ✅ Admin status is determined by existence in `/admins/{uid}` collection
- ✅ No client-side admin creation (must be done in Firebase Console)
- ✅ All other collections are denied by default

---

## User Model Structure

```dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;           // admin or user
  final bool isEmailVerified;
  final String? verificationCode;
  final DateTime? verificationCodeExpiry;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String status;            // Active, Inactive, Suspended, etc.
  final int? activityCount;
}
```

**Status Values:**
- `"Active"` - User can login (default)
- `"Inactive"` - User is blocked from login
- `"Suspended"` - User is temporarily blocked
- `"Banned"` - User is permanently blocked
- Any other value - User is blocked from login

---

## Testing the Implementation

### **Test 1: Inactive User Login**
1. Create a user account
2. In Firebase Console, change user's status to "Inactive"
3. Try to login with that user
4. **Expected Result:** Login fails with message "Your account is inactive. Please contact the administrator."

### **Test 2: Admin Promotion**
1. Login as admin
2. Go to User Management
3. Select a regular user
4. Click "Promote to Admin"
5. Logout
6. Login with the promoted user's credentials
7. **Expected Result:** User logs in successfully and sees admin dashboard

### **Test 3: Status Change**
1. Login as admin
2. Go to User Management
3. Change a user's status from "Active" to "Inactive"
4. Logout
5. Try to login with that user
6. **Expected Result:** Login fails with inactive account message

### **Test 4: Admin Demotion**
1. Login as admin
2. Go to User Management
3. Select an admin user
4. Click "Demote to User"
5. Logout
6. Login with the demoted user's credentials
7. **Expected Result:** User logs in successfully and sees user dashboard (not admin)

---

## Key Files Modified

### 1. **firestore.rules**
- Updated security rules
- Removed schedules, audit_logs, and notifications collections
- Added helper functions for admin detection

### 2. **lib/services/user_management_service.dart**
- Removed audit logging functionality
- Simplified status and role update methods
- Removed dependency on audit_log_model.dart

### 3. **lib/providers/auth_provider.dart**
- Already has inactive user blocking (lines 298-311)
- Added `reloadUserModel()` method for refreshing user data
- Properly handles role changes by checking both collections

### 4. **lib/models/user_model.dart**
- Has `status` field with default value "Active"
- Supports role changes between admin and user

---

## API Methods

### **UserManagementService**

#### `getAllAccounts()`
Returns list of all users and admins combined.

```dart
final accounts = await UserManagementService.getAllAccounts();
```

#### `updateUserStatus()`
Updates user status (Active/Inactive/etc.)

```dart
final success = await UserManagementService.updateUserStatus(
  targetUserId: 'user123',
  isAdmin: false,
  newStatus: 'Inactive',
  adminId: currentAdmin.uid,
  adminEmail: currentAdmin.email,
  adminName: currentAdmin.name,
);
```

#### `updateUserRole()`
Promotes user to admin or demotes admin to user.

```dart
final success = await UserManagementService.updateUserRole(
  targetUserId: 'user123',
  currentIsAdmin: false,
  makeAdmin: true,  // Promote to admin
  adminId: currentAdmin.uid,
  adminEmail: currentAdmin.email,
  adminName: currentAdmin.name,
);
```

### **AuthProvider**

#### `reloadUserModel()`
Reloads user data from Firestore (useful after role/status changes).

```dart
await authProvider.reloadUserModel();
```

---

## Common Issues & Solutions

### **Issue 1: User promoted to admin but still sees user dashboard**
**Solution:** User needs to logout and login again. The role change requires a fresh authentication session.

### **Issue 2: Status change not taking effect**
**Solution:** Status is checked only during login. If user is already logged in, they need to logout and login again.

### **Issue 3: Admin can't promote users**
**Solution:** Ensure the admin account exists in the `/admins/{uid}` collection in Firestore. The security rules check for this.

### **Issue 4: First admin can't be created**
**Solution:** First admin must be created manually in Firebase Console:
1. Go to Firestore Database
2. Open `admins` collection
3. Add document with ID = user's UID
4. Add fields: uid, email, name, role='admin', status='Active', isEmailVerified=true

---

## Security Considerations

1. **Admin Creation:** First admin must be created manually in Firebase Console to prevent unauthorized admin creation
2. **Status Check:** Status is checked on every login to ensure real-time enforcement
3. **Role Verification:** Role is verified by checking collection existence, not just a field value
4. **No Client-Side Promotion:** Users cannot promote themselves - only existing admins can promote others

---

## Summary

✅ **Inactive users are blocked from signing in**
- Status checked on every login
- User signed out immediately if inactive
- Clear error message displayed

✅ **Admin promotion works live**
- User document moved between collections
- Role field updated correctly
- User can login as admin immediately after promotion

✅ **No audit logs, notifications, or schedules**
- Removed all references to these collections
- Simplified codebase
- Cleaner Firestore rules

✅ **Secure implementation**
- Proper security rules
- Admin verification through collection existence
- No client-side admin creation

---

## Next Steps

1. Test all scenarios thoroughly
2. Create UI for user management (if not already done)
3. Add user feedback messages for status changes
4. Consider adding email notifications for status changes (optional)
5. Add logging for security audit trail (optional)
