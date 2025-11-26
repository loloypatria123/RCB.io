# ✅ **VERIFY YOUR ADMIN ACCOUNT**

## 👤 **Your Admin Account**

```
Email: admin@gmail.com
Password: admin123
Role: admin
```

## 📋 **What to Check in Firestore**

### **Step 1: Go to Firebase Console**

1. URL: https://console.firebase.google.com/
2. Project: `rcbfinal-e7f13`
3. Firestore Database → Collections

### **Step 2: Check admins Collection**

You should see:
- ✅ `admins` collection exists
- ✅ Document with ID = your User UID (from Firebase Auth)

### **Step 3: Verify Document Fields**

Your admin document should have:

```json
{
  "uid": "your_user_id_here",
  "email": "admin@gmail.com",
  "name": "Admin User",
  "role": "admin",
  "isEmailVerified": true,
  "createdAt": "2025-11-26T...",
  "lastLogin": "2025-11-26T..."
}
```

**CRITICAL**: `role` must be exactly `"admin"` (lowercase)

### **Step 4: Find Your User UID**

1. Go to: Authentication → Users
2. Find user with email: admin@gmail.com
3. Copy the User UID
4. This should match the document ID in `admins` collection

## 🧪 **Test Your Admin Account**

### **Step 1: Open App**

1. Open your app in browser
2. Go to Sign In page

### **Step 2: Sign In**

```
Email: admin@gmail.com
Password: admin123
Click: Sign In
```

### **Step 3: Open Console**

1. Press: F12 (or right-click → Inspect)
2. Go to: Console tab

### **Step 4: Check Console Messages**

You should see:

```
🔐 Starting sign in for: admin@gmail.com
✅ Firebase sign in successful: [your_user_id]
📝 Loading user model from Firestore...
📝 Raw admin data from Firestore: {uid: ..., role: "admin", ...}
📝 Role field value: admin
✅ Loaded admin from admins collection
✅ Parsed role: UserRole.admin
✅ Is admin check: true
🔄 Checking role for navigation...
👤 Final is admin: true
🚀 Navigating to admin dashboard
```

### **Step 5: Verify Navigation**

After sign in, you should see:
- ✅ Admin Dashboard (not User Dashboard)
- ✅ Admin-specific features visible

## ⚠️ **If Something Goes Wrong**

### **Issue: "User not found" error**

**Cause**: Firebase Auth user doesn't exist
**Solution**:
1. Go to Authentication → Users
2. Verify admin@gmail.com user exists
3. If not, create it again with password: admin123

### **Issue: Still going to user dashboard**

**Cause**: Firestore document is in wrong collection or role is wrong
**Solution**:
1. Check Firestore console
2. Verify admin document is in `admins` collection
3. Verify `role` field is exactly `"admin"`
4. If wrong, move document to correct collection

### **Issue: Console shows "Loaded user from users collection"**

**Cause**: Admin document is in `users` collection instead of `admins`
**Solution**:
1. Go to Firestore Database
2. Find admin document in `users` collection
3. Copy all fields
4. Delete from `users` collection
5. Create new document in `admins` collection
6. Paste all fields
7. Test sign-in again

### **Issue: Console shows "Is admin: false"**

**Cause**: Role field is not `"admin"` or is missing
**Solution**:
1. Go to Firestore Database
2. Open admin document in `admins` collection
3. Check `role` field
4. Verify it's exactly `"admin"` (lowercase)
5. If wrong, edit it
6. Test sign-in again

## 📊 **Firestore Document Checklist**

- [ ] Document in `admins` collection
- [ ] Document ID = User UID
- [ ] `uid` field = User UID
- [ ] `email` field = admin@gmail.com
- [ ] `name` field = Admin User
- [ ] `role` field = admin (lowercase!)
- [ ] `isEmailVerified` = true
- [ ] `createdAt` field present
- [ ] `lastLogin` field present

## 🎯 **Expected Result**

```
Sign In with admin@gmail.com / admin123
    ↓
Console: "Is admin: true"
    ↓
Admin Dashboard appears ✅
```

## 📝 **Your Admin Account Summary**

| Field | Value |
|-------|-------|
| Email | admin@gmail.com |
| Password | admin123 |
| Role | admin |
| Collection | admins |
| isEmailVerified | true |

## 🚀 **Next Steps**

1. **Verify Firestore document** (follow steps above)
2. **Test sign-in** with your credentials
3. **Check console** for "Is admin: true"
4. **Verify admin dashboard** appears

**Your admin account is ready to use!** ✅
