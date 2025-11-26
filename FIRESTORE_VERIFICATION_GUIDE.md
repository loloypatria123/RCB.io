# Firestore Verification & Fix Guide

## Quick Start

I've created a **Firestore Debug Tool** that automatically verifies and fixes your database structure.

### How to Use:

1. **Run your app**
2. **Navigate to the debug page** by going to:
   ```
   http://localhost:8080/firestore-debug
   ```
   OR add a button in your sign-in page temporarily

3. **Click "Verify & Fix Firestore"** button
   - This will check your database structure
   - Automatically fix any issues
   - Show detailed output

4. **Click "Print Summary"** to see all admins and users

---

## What Gets Verified

### ✅ Admins Collection
- Checks if `admins` collection exists
- Verifies each admin has:
  - `uid` - Firebase Auth UID
  - `email` - Admin email
  - `name` - Admin name
  - `role` - Must be `"admin"` (lowercase string)
  - `isEmailVerified` - Boolean
  - `createdAt` - Timestamp
  - `lastLogin` - Timestamp

### ✅ Users Collection
- Checks if `users` collection exists
- Verifies each user has:
  - `uid` - Firebase Auth UID
  - `email` - User email
  - `name` - User name
  - `role` - Must be `"user"` (lowercase string)
  - `isEmailVerified` - Boolean
  - `createdAt` - Timestamp
  - `lastLogin` - Timestamp

---

## What Gets Fixed Automatically

### 🔧 Fix 1: Move Admin Accounts
If an admin account is in the `users` collection:
- ✅ Moves it to `admins` collection
- ✅ Updates role to `"admin"`
- ✅ Removes from `users` collection

### 🔧 Fix 2: Correct Role Fields
If any document has wrong role:
- ✅ Admins with role != "admin" → updated to "admin"
- ✅ Users with role != "user" → updated to "user"

### 🔧 Fix 3: Create Collections
If collections don't exist:
- ✅ They're created automatically when first document is added

---

## Manual Verification (Firebase Console)

If you want to manually check your Firestore:

### Step 1: Go to Firebase Console
1. Visit: https://console.firebase.google.com/
2. Select project: `rcbfinal-e7f13`
3. Go to Firestore Database

### Step 2: Check Admins Collection
```
Collection: admins
├── Document: [user_uid_1]
│   ├── uid: "user_uid_1"
│   ├── email: "admin@gmail.com"
│   ├── name: "Admin Name"
│   ├── role: "admin"              ← MUST be lowercase "admin"
│   ├── isEmailVerified: true
│   ├── createdAt: "2024-..."
│   └── lastLogin: "2024-..."
└── Document: [user_uid_2]
    └── ...
```

### Step 3: Check Users Collection
```
Collection: users
├── Document: [user_uid_1]
│   ├── uid: "user_uid_1"
│   ├── email: "user@gmail.com"
│   ├── name: "User Name"
│   ├── role: "user"               ← MUST be lowercase "user"
│   ├── isEmailVerified: true
│   ├── createdAt: "2024-..."
│   └── lastLogin: "2024-..."
└── Document: [user_uid_2]
    └── ...
```

---

## Code Reference

### FirestoreVerificationService Methods

#### 1. Verify and Fix Everything
```dart
await FirestoreVerificationService.verifyAndFixFirestore();
```
Runs all verification and fixes automatically.

#### 2. Get All Admins
```dart
List<UserModel> admins = 
  await FirestoreVerificationService.getAllAdmins();
```

#### 3. Get All Users
```dart
List<UserModel> users = 
  await FirestoreVerificationService.getAllUsers();
```

#### 4. Create Test Admin
```dart
await FirestoreVerificationService.createTestAdminAccount(
  uid: 'test_admin_uid',
  email: 'admin@test.com',
  name: 'Test Admin',
);
```

#### 5. Create Test User
```dart
await FirestoreVerificationService.createTestUserAccount(
  uid: 'test_user_uid',
  email: 'user@test.com',
  name: 'Test User',
);
```

#### 6. Print Summary
```dart
await FirestoreVerificationService.printSummary();
```
Prints all admins and users in console.

---

## Expected Output

When you run the verification, you should see something like:

```
🔍 Starting Firestore verification...

📋 Step 1: Checking admins collection...
   Found 1 admin(s)

   📄 Admin Document: abc123def456
      Email: admin@gmail.com
      Name: Admin
      Role: admin
      Email Verified: true
      ✅ Role is correct

📋 Step 2: Checking users collection...
   Found 2 user(s)

   📄 User Document: xyz789uvw012
      Email: user1@gmail.com
      Name: User One
      Role: user
      Email Verified: true
      ✅ Role is correct

   📄 User Document: qrs345tuvw678
      Email: user2@gmail.com
      Name: User Two
      Role: user
      Email Verified: true
      ✅ Role is correct

📋 Step 3: Fixing any issues...
   🔧 Fixing: Moving admin accounts to admins collection...
   🔧 Fixing: Ensuring all documents have correct role field...
   ✅ All fixes completed!

✅ Firestore verification completed!
```

---

## Troubleshooting

### Issue: "Collection not found"
**Solution**: This is normal if the collection is empty. It will be created when you add the first document.

### Issue: "Role is admin but in users collection"
**Solution**: Run the verification tool - it will automatically move it to the admins collection.

### Issue: "Role field is 'Admin' (capitalized)"
**Solution**: Run the verification tool - it will automatically fix it to lowercase "admin".

### Issue: "Email verified is false"
**Solution**: This is fine for new accounts. They need to verify their email first.

---

## Testing After Fix

### Test 1: Admin Login
```
1. Login with: admin@gmail.com
2. Expected: Admin Dashboard appears ✅
3. Check console: "✅ Access granted - User is admin"
```

### Test 2: User Login
```
1. Login with: user@gmail.com
2. Expected: User Dashboard appears ✅
3. Check console: "✅ Access granted - User is regular user"
```

### Test 3: Wrong Dashboard Access
```
1. Login as user
2. Try to manually navigate to /admin-dashboard
3. Expected: Redirected back to /user-dashboard ✅
```

---

## Files Created

1. **lib/services/firestore_verification_service.dart**
   - Contains all verification and fix logic
   - Can be used programmatically

2. **lib/pages/firestore_debug_page.dart**
   - UI for running verification
   - Shows detailed output
   - Easy to use

3. **lib/main.dart** (updated)
   - Added `/firestore-debug` route

---

## Next Steps

1. ✅ Run your app
2. ✅ Navigate to `/firestore-debug`
3. ✅ Click "Verify & Fix Firestore"
4. ✅ Check the output
5. ✅ Test login with admin account
6. ✅ Test login with user account
7. ✅ Verify correct dashboards appear

---

## Need Help?

Check the console logs for detailed error messages. The verification tool will tell you exactly what's wrong and what it fixed.
