# ⚡ **QUICK FIX: ADMIN DASHBOARD**

## 🎯 **Problem**
Admin goes to user dashboard instead of admin dashboard.

## 🚀 **Quick Fix (2 Minutes)**

### **Step 1: Check Firestore**

1. Go to: https://console.firebase.google.com/
2. Project: `rcbfinal-e7f13`
3. Firestore Database → Collections
4. Check: Is admin document in `admins` or `users` collection?

### **Step 2: If in WRONG Collection**

If admin document is in `users` collection:

1. Copy all fields from the document
2. Delete from `users` collection
3. Go to `admins` collection
4. Create new document with same User UID
5. Paste all fields

### **Step 3: Verify Role Field**

1. Open admin document
2. Check `role` field
3. Must be exactly: `admin` (lowercase!)
4. NOT: `Admin`, `ADMIN`, `admin_user`, etc.

### **Step 4: Check isEmailVerified**

1. Open admin document
2. Check `isEmailVerified` field
3. Must be: `true` (boolean)

### **Step 5: Test**

1. Sign in with: admin@example.com / Admin@123456
2. Open console (F12)
3. Look for: "Is admin: true"
4. Should go to admin dashboard

## ✅ **Expected Console Output**

```
✅ Loaded admin from admins collection
✅ Parsed role: UserRole.admin
✅ Is admin check: true
🚀 Navigating to admin dashboard
```

## ❌ **Wrong Console Output**

```
✅ Loaded user from users collection  ❌ WRONG
✅ Is admin check: false  ❌ WRONG
🚀 Navigating to user dashboard  ❌ WRONG
```

## 🔧 **Most Common Issue**

**Admin document is in `users` collection instead of `admins` collection.**

**Fix:**
1. Move document from `users` to `admins` collection
2. Verify `role` = `"admin"`
3. Test sign-in

## 📋 **Firestore Document Template**

```
Collection: admins
Document ID: [User_UID]

Fields:
- uid: [User_UID]
- email: admin@example.com
- name: Admin User
- role: admin
- isEmailVerified: true
- createdAt: 2025-11-26T01:36:00.000Z
- lastLogin: 2025-11-26T01:36:00.000Z
```

## 🎯 **Done!**

Admin should now go to admin dashboard on sign-in. ✅
