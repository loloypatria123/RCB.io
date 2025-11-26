# ✅ **VERIFY FIRESTORE ADMIN DOCUMENT**

## 🎯 **Goal**
Ensure your admin document in Firestore is set up correctly so admins go to the admin dashboard.

## 📋 **Step-by-Step Verification**

### **Step 1: Open Firebase Console**

```
URL: https://console.firebase.google.com/
Project: rcbfinal-e7f13
```

### **Step 2: Go to Firestore Database**

```
Left Menu:
  → Build
    → Firestore Database
```

### **Step 3: Check Collections**

You should see:
- ✅ `admins` collection
- ✅ `users` collection

If you don't see `admins` collection:
1. Click "Create collection"
2. Enter: `admins`
3. Click "Next"

### **Step 4: Open Admins Collection**

```
Click: admins (collection)
```

You should see your admin document with ID = User UID

### **Step 5: Verify Document Fields**

Click on the admin document and verify each field:

#### **Field 1: uid**
```
Name: uid
Type: String
Value: (should match User UID from Firebase Auth)
Example: abc123def456ghi789
```
✅ Correct if it matches the document ID

#### **Field 2: email**
```
Name: email
Type: String
Value: admin@example.com
```
✅ Correct if it matches Firebase Auth email

#### **Field 3: name**
```
Name: name
Type: String
Value: Admin User
```
✅ Correct if it's not empty

#### **Field 4: role** ⭐ **MOST IMPORTANT**
```
Name: role
Type: String
Value: admin
```
✅ **MUST BE**: `admin` (lowercase, no quotes)
❌ **NOT**: `Admin`, `ADMIN`, `admin_user`, etc.

#### **Field 5: isEmailVerified**
```
Name: isEmailVerified
Type: Boolean
Value: true
```
✅ **MUST BE**: `true` (boolean, not string)

#### **Field 6: createdAt**
```
Name: createdAt
Type: String
Value: 2025-11-26T01:36:00.000Z
```
✅ Correct if it's an ISO date string

#### **Field 7: lastLogin**
```
Name: lastLogin
Type: String
Value: 2025-11-26T01:36:00.000Z
```
✅ Correct if it's an ISO date string

### **Step 6: Complete Document Check**

Your admin document should look exactly like this:

```
admins/abc123def456ghi789
├── uid: "abc123def456ghi789"
├── email: "admin@example.com"
├── name: "Admin User"
├── role: "admin"  ⭐ KEY FIELD
├── isEmailVerified: true
├── createdAt: "2025-11-26T01:36:00.000Z"
└── lastLogin: "2025-11-26T01:36:00.000Z"
```

## 🔍 **Common Mistakes**

### **Mistake 1: Role is "Admin" (capital A)**
```
❌ WRONG: role: "Admin"
✅ CORRECT: role: "admin"
```
**Fix**: Edit the field and change to lowercase

### **Mistake 2: Role is "admin_user"**
```
❌ WRONG: role: "admin_user"
✅ CORRECT: role: "admin"
```
**Fix**: Edit the field and change to exactly "admin"

### **Mistake 3: Document in users collection**
```
❌ WRONG: users/abc123/...
✅ CORRECT: admins/abc123/...
```
**Fix**: 
1. Copy all fields from users document
2. Delete from users collection
3. Create new document in admins collection
4. Paste all fields

### **Mistake 4: isEmailVerified is false**
```
❌ WRONG: isEmailVerified: false
✅ CORRECT: isEmailVerified: true
```
**Fix**: Edit the field and set to true

### **Mistake 5: role field is missing**
```
❌ WRONG: (no role field)
✅ CORRECT: role: "admin"
```
**Fix**: Click "Add field" and add role field

### **Mistake 6: Document ID doesn't match User UID**
```
❌ WRONG: admins/wrong_uid/...
✅ CORRECT: admins/correct_uid/...
```
**Fix**:
1. Get correct User UID from Firebase Auth
2. Delete wrong document
3. Create new document with correct UID

## 📊 **How to Fix Each Mistake**

### **Fix: Edit a Field**

1. Click on the admin document
2. Find the field to edit
3. Click the field value
4. Edit the value
5. Click outside or press Enter
6. Changes save automatically

### **Fix: Add a Missing Field**

1. Click on the admin document
2. Scroll to bottom
3. Click "Add field"
4. Enter field name
5. Select field type
6. Enter field value
7. Click "Save"

### **Fix: Delete and Recreate Document**

1. Click on the admin document
2. Click "Delete" button (top right)
3. Confirm deletion
4. Go back to admins collection
5. Click "Add document"
6. Set document ID to User UID
7. Add all fields again

## ✅ **Final Verification Checklist**

- [ ] `admins` collection exists
- [ ] Admin document exists with User UID as ID
- [ ] `uid` field = User UID
- [ ] `email` field = admin@example.com
- [ ] `name` field = Admin User
- [ ] `role` field = admin (lowercase!)
- [ ] `isEmailVerified` = true
- [ ] `createdAt` field present
- [ ] `lastLogin` field present
- [ ] All fields have correct types
- [ ] No extra or missing fields

## 🧪 **Test After Verification**

1. Open app in browser
2. Go to Sign In page
3. Enter: admin@example.com / Admin@123456
4. Open console (F12)
5. Click Sign In
6. Check console for:
   - "Loaded admin from admins collection"
   - "Is admin: true"
   - "Navigating to admin dashboard"
7. Verify admin dashboard appears

## 📝 **Document Template**

If you need to recreate the document, use this template:

```
Collection: admins
Document ID: (User UID from Firebase Auth)

Fields:
1. uid (String): (User UID)
2. email (String): admin@example.com
3. name (String): Admin User
4. role (String): admin
5. isEmailVerified (Boolean): true
6. createdAt (String): 2025-11-26T01:36:00.000Z
7. lastLogin (String): 2025-11-26T01:36:00.000Z
```

**Your Firestore document is now verified!** ✅
