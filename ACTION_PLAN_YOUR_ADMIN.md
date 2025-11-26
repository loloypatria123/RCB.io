# 🎯 **ACTION PLAN: YOUR ADMIN ACCOUNT**

## 👤 **Your Credentials**

```
Email: admin@gmail.com
Password: admin123
```

## ✅ **Action Checklist**

### **Action 1: Verify Firebase Auth User**

- [ ] Go to: https://console.firebase.google.com/
- [ ] Project: rcbfinal-e7f13
- [ ] Go to: Authentication → Users
- [ ] Find user: admin@gmail.com
- [ ] Copy the User UID
- [ ] Save it somewhere

### **Action 2: Verify Firestore Document**

- [ ] Go to: Firestore Database → Collections
- [ ] Check: `admins` collection exists
- [ ] Find document with ID = User UID
- [ ] Verify all fields:
  - [ ] `uid` = User UID
  - [ ] `email` = admin@gmail.com
  - [ ] `name` = Admin User
  - [ ] `role` = admin (lowercase!)
  - [ ] `isEmailVerified` = true
  - [ ] `createdAt` present
  - [ ] `lastLogin` present

### **Action 3: If Document Doesn't Exist**

- [ ] Create new document in `admins` collection
- [ ] Set Document ID = User UID
- [ ] Add all fields (see template below)

### **Action 4: Test Sign In**

- [ ] Open app in browser
- [ ] Go to Sign In page
- [ ] Enter: admin@gmail.com / admin123
- [ ] Open console (F12)
- [ ] Click Sign In
- [ ] Check console for: "Is admin: true"
- [ ] Verify admin dashboard appears

### **Action 5: If Admin Goes to User Dashboard**

- [ ] Check Firestore document location
- [ ] If in `users` collection → Move to `admins` collection
- [ ] Verify `role` field = "admin"
- [ ] Verify `isEmailVerified` = true
- [ ] Test sign-in again

## 📋 **Firestore Document Template**

If you need to create the document:

```
Collection: admins
Document ID: [Your_User_UID]

Fields:
1. uid (String): [Your_User_UID]
2. email (String): admin@gmail.com
3. name (String): Admin User
4. role (String): admin
5. isEmailVerified (Boolean): true
6. createdAt (String): 2025-11-26T01:56:00.000Z
7. lastLogin (String): 2025-11-26T01:56:00.000Z
```

## 🔍 **Console Output to Look For**

### **✅ Correct (Admin)**
```
✅ Loaded admin from admins collection
✅ Parsed role: UserRole.admin
✅ Is admin check: true
🚀 Navigating to admin dashboard
```

### **❌ Wrong (User Dashboard)**
```
✅ Loaded user from users collection
✅ Is admin check: false
🚀 Navigating to user dashboard
```

## 🎯 **Success Criteria**

You'll know it's working when:
1. ✅ Sign in succeeds with admin@gmail.com / admin123
2. ✅ Console shows "Is admin: true"
3. ✅ Admin dashboard appears (not user dashboard)
4. ✅ Can see admin-specific features

## 📞 **Quick Reference**

| Item | Value |
|------|-------|
| Email | admin@gmail.com |
| Password | admin123 |
| Collection | admins |
| Role | admin |
| isEmailVerified | true |

## 🚀 **Start Here**

1. **Verify Firebase Auth user exists** (admin@gmail.com)
2. **Copy User UID**
3. **Check Firestore document** in `admins` collection
4. **Verify all fields** are correct
5. **Test sign-in**
6. **Check console** for "Is admin: true"

**Your admin account is ready!** ✅
