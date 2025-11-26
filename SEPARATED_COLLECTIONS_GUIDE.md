# ✅ **SEPARATED COLLECTIONS GUIDE**

## 🎯 **Overview**

The app now uses **separate Firestore collections** for admins and users:
- ✅ **`admins`** collection - Stores all admin accounts
- ✅ **`users`** collection - Stores all regular user accounts

## 📋 **Firestore Structure**

### **Users Collection**
```
users/
  ├── user_id_1/
  │   ├── uid: "user_id_1"
  │   ├── email: "user@example.com"
  │   ├── name: "User Name"
  │   ├── role: "user"
  │   ├── isEmailVerified: true
  │   ├── createdAt: "2025-11-26T00:00:00.000Z"
  │   └── lastLogin: "2025-11-26T01:00:00.000Z"
  │
  └── user_id_2/
      └── ... (same structure)
```

### **Admins Collection**
```
admins/
  ├── admin_id_1/
  │   ├── uid: "admin_id_1"
  │   ├── email: "admin@example.com"
  │   ├── name: "Admin Name"
  │   ├── role: "admin"
  │   ├── isEmailVerified: true
  │   ├── createdAt: "2025-11-26T00:00:00.000Z"
  │   └── lastLogin: "2025-11-26T01:00:00.000Z"
  │
  └── admin_id_2/
      └── ... (same structure)
```

## 🔄 **How It Works**

### **Sign Up Flow**
```
User enters: name, email, password, role
  ↓
App creates Firebase Auth user
  ↓
App generates verification code
  ↓
App determines collection based on role:
  - If role == "admin" → Store in "admins" collection
  - If role == "user" → Store in "users" collection
  ↓
Email sent with verification code
  ↓
Navigate to verification page
```

### **Sign In Flow**
```
User enters: email, password
  ↓
Firebase Auth validates credentials
  ↓
App loads user model:
  1. Check "admins" collection first
  2. If not found, check "users" collection
  ↓
App determines dashboard based on role:
  - If role == "admin" → Navigate to /admin-dashboard
  - If role == "user" → Navigate to /user-dashboard
```

### **Email Verification Flow**
```
User enters verification code
  ↓
App checks code against stored code
  ↓
If valid:
  - Determine collection based on role
  - Update correct collection (admins or users)
  - Set isEmailVerified = true
  - Delete verification code fields
  ↓
Navigate to appropriate dashboard
```

## 🔐 **Firestore Security Rules**

Both collections have identical security rules:

```
- Create: ✅ Authenticated users can create their own documents
- Read: ✅ Users can read their own documents
- Update: ✅ Users can update their own documents
- Delete: ✅ Users can delete their own documents
```

## 🎯 **Deployment Steps**

### **Step 1: Deploy Updated Firestore Rules**

1. Go to: https://console.firebase.google.com/
2. Select project: `rcbfinal-e7f13`
3. Go to: **Firestore Database** → **Rules**
4. Replace all content with the new rules
5. Click **"Publish"**
6. Wait 5 minutes for propagation

### **Step 2: Migrate Existing Data (Optional)**

If you have existing users in the `users` collection:

**For Regular Users:**
- Keep them in `users` collection
- Ensure `role` field is `"user"`

**For Admin Users:**
- Move from `users` to `admins` collection
- Ensure `role` field is `"admin"`

### **Step 3: Test the Flows**

#### **Test Regular User Sign Up**
1. Sign up with role: `user`
2. Verify email
3. Sign in
4. Should go to user dashboard

#### **Test Admin Sign Up**
1. Sign up with role: `admin`
2. Verify email
3. Sign in
4. Should go to admin dashboard

## 📊 **Collection Separation Benefits**

- ✅ **Better Organization** - Admins and users are clearly separated
- ✅ **Easier Queries** - Can query admins and users independently
- ✅ **Improved Security** - Can set different rules for each collection
- ✅ **Scalability** - Easier to manage as data grows
- ✅ **Clear Role Management** - Role is implicit in collection name

## 🔍 **Verify Collections in Firestore**

1. Go to Firebase Console
2. Click **Firestore Database**
3. You should see:
   - ✅ `admins` collection (with admin documents)
   - ✅ `users` collection (with user documents)

## 📋 **Document Fields**

Both collections have the same document structure:

```json
{
  "uid": "firebase_user_id",
  "email": "user@example.com",
  "name": "User Name",
  "role": "user" or "admin",
  "isEmailVerified": true/false,
  "verificationCode": "123456" (during signup),
  "verificationCodeExpiry": "2025-11-26T01:00:00.000Z" (during signup),
  "createdAt": "2025-11-26T00:00:00.000Z",
  "lastLogin": "2025-11-26T01:00:00.000Z"
}
```

## ✅ **Final Checklist**

- [ ] Firestore rules deployed
- [ ] Both collections exist in Firestore
- [ ] Admin users in `admins` collection
- [ ] Regular users in `users` collection
- [ ] Test user sign up and sign in
- [ ] Test admin sign up and sign in
- [ ] Verify correct dashboard navigation

**Collections are now properly separated!**
