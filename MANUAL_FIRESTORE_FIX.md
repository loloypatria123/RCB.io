# Manual Firestore Fixes

If you want to manually fix your Firestore database without using the debug tool, follow these steps.

---

## Fix 1: Move Admin from Users to Admins Collection

### Scenario
You have `admin@gmail.com` in the `users` collection, but it should be in the `admins` collection.

### Manual Steps (Firebase Console)

1. **Go to Firebase Console**
   - URL: https://console.firebase.google.com/
   - Project: `rcbfinal-e7f13`
   - Firestore Database

2. **Find the admin in users collection**
   - Click on `users` collection
   - Find the document with `email: "admin@gmail.com"`
   - Copy the entire document data

3. **Create new document in admins collection**
   - Click on `admins` collection
   - Click "Add document"
   - Use the SAME document ID as in users collection
   - Paste the data
   - Make sure `role` field = `"admin"` (lowercase)

4. **Delete from users collection**
   - Go back to `users` collection
   - Find the admin document
   - Click the three dots menu
   - Click "Delete document"

---

## Fix 2: Update Role Field to Correct Value

### Scenario
An admin has `role: "Admin"` (capitalized) but should be `role: "admin"` (lowercase).

### Manual Steps (Firebase Console)

1. **Go to Firebase Console**
   - Firestore Database
   - Open `admins` collection

2. **Find the document**
   - Click on the document
   - Find the `role` field

3. **Edit the field**
   - Click on the `role` field value
   - Change from `"Admin"` to `"admin"`
   - Press Enter

4. **Repeat for users collection**
   - Go to `users` collection
   - Make sure all have `role: "user"` (lowercase)

---

## Fix 3: Create Admin Account Manually

### Scenario
You want to manually create an admin account.

### Manual Steps (Firebase Console)

1. **Create Firebase Auth User First**
   - Go to Authentication section
   - Click "Add user"
   - Email: `admin@gmail.com`
   - Password: (set a password)
   - Click "Create user"
   - Copy the UID (it's shown in the user list)

2. **Create Firestore Document**
   - Go to Firestore Database
   - Click on `admins` collection
   - Click "Add document"
   - Set Document ID: (paste the UID from step 1)
   - Add fields:
     ```
     uid: "paste_uid_here"
     email: "admin@gmail.com"
     name: "Admin"
     role: "admin"
     isEmailVerified: true
     createdAt: (current timestamp)
     lastLogin: (current timestamp)
     ```

3. **Done!**
   - Now admin@gmail.com can login
   - Will see Admin Dashboard

---

## Fix 4: Create User Account Manually

### Scenario
You want to manually create a regular user account.

### Manual Steps (Firebase Console)

1. **Create Firebase Auth User First**
   - Go to Authentication section
   - Click "Add user"
   - Email: `user@gmail.com`
   - Password: (set a password)
   - Click "Create user"
   - Copy the UID

2. **Create Firestore Document**
   - Go to Firestore Database
   - Click on `users` collection
   - Click "Add document"
   - Set Document ID: (paste the UID from step 1)
   - Add fields:
     ```
     uid: "paste_uid_here"
     email: "user@gmail.com"
     name: "User"
     role: "user"
     isEmailVerified: true
     createdAt: (current timestamp)
     lastLogin: (current timestamp)
     ```

3. **Done!**
   - Now user@gmail.com can login
   - Will see User Dashboard

---

## Dart Code for Manual Fixes

If you want to run fixes from your Dart code, use these snippets:

### Move Admin from Users to Admins
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> moveAdminFromUsersToAdmins(String adminEmail) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    // Find in users collection
    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .get();
    
    if (userQuery.docs.isEmpty) {
      print('❌ Admin not found in users collection');
      return;
    }
    
    final doc = userQuery.docs.first;
    final data = doc.data();
    
    // Add to admins collection
    await firestore.collection('admins').doc(doc.id).set(data);
    print('✅ Added to admins collection');
    
    // Update role
    await firestore.collection('admins').doc(doc.id).update({
      'role': 'admin',
    });
    print('✅ Updated role to "admin"');
    
    // Delete from users collection
    await firestore.collection('users').doc(doc.id).delete();
    print('✅ Removed from users collection');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Fix Role Field
```dart
Future<void> fixRoleField(String collection, String docId, String correctRole) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    await firestore.collection(collection).doc(docId).update({
      'role': correctRole,
    });
    print('✅ Updated role to "$correctRole"');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Create Admin Account
```dart
Future<void> createAdminAccount({
  required String uid,
  required String email,
  required String name,
}) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    await firestore.collection('admins').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'role': 'admin',
      'isEmailVerified': true,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
    });
    print('✅ Admin account created');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Create User Account
```dart
Future<void> createUserAccount({
  required String uid,
  required String email,
  required String name,
}) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'role': 'user',
      'isEmailVerified': true,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
    });
    print('✅ User account created');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## Quick Reference: Correct Structure

### Admin Document (in `admins` collection)
```json
{
  "uid": "abc123def456",
  "email": "admin@gmail.com",
  "name": "Admin Name",
  "role": "admin",
  "isEmailVerified": true,
  "createdAt": "2024-11-26T02:00:00.000Z",
  "lastLogin": "2024-11-26T02:15:00.000Z"
}
```

### User Document (in `users` collection)
```json
{
  "uid": "xyz789uvw012",
  "email": "user@gmail.com",
  "name": "User Name",
  "role": "user",
  "isEmailVerified": true,
  "createdAt": "2024-11-26T02:00:00.000Z",
  "lastLogin": "2024-11-26T02:15:00.000Z"
}
```

---

## Verification Checklist

After making manual fixes, verify:

- [ ] Admin document is in `admins` collection
- [ ] Admin has `role: "admin"` (lowercase)
- [ ] User document is in `users` collection
- [ ] User has `role: "user"` (lowercase)
- [ ] Both have `isEmailVerified: true`
- [ ] Both have `uid`, `email`, `name` fields
- [ ] Login with admin → Admin Dashboard appears
- [ ] Login with user → User Dashboard appears

---

## Need Help?

Use the **Firestore Debug Tool** instead:
- Navigate to `/firestore-debug`
- Click "Verify & Fix Firestore"
- It will automatically fix everything!
