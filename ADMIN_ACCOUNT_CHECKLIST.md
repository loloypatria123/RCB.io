# ✅ **ADMIN ACCOUNT CREATION CHECKLIST**

## 🎯 **Your Task**

Create an admin account in Firebase so that when you sign in, you automatically go to the admin dashboard.

## 📋 **Complete Checklist**

### **Phase 1: Firebase Authentication Setup**

- [ ] Go to https://console.firebase.google.com/
- [ ] Select project: `rcbfinal-e7f13`
- [ ] Navigate to: **Build** → **Authentication**
- [ ] Click: **Users** tab
- [ ] Click: **"Add user"** button
- [ ] Enter Email: `admin@example.com`
- [ ] Enter Password: `Admin@123456`
- [ ] Click: **"Create user"**
- [ ] **COPY** the User UID (important!)
- [ ] Save it somewhere safe

### **Phase 2: Firestore Collection Setup**

- [ ] Go to: **Build** → **Firestore Database**
- [ ] Click: **"Create collection"** (or **"Start collection"**)
- [ ] Enter Collection ID: `admins`
- [ ] Click: **"Next"**
- [ ] Click: **"Add document"**
- [ ] Set Document ID to: (paste the User UID from Phase 1)
- [ ] Click: **"Save"**

### **Phase 3: Add Document Fields**

For each field below, click **"Add field"** and enter:

**Field 1:**
- [ ] Name: `uid`
- [ ] Type: String
- [ ] Value: (paste User UID)

**Field 2:**
- [ ] Name: `email`
- [ ] Type: String
- [ ] Value: `admin@example.com`

**Field 3:**
- [ ] Name: `name`
- [ ] Type: String
- [ ] Value: `Admin User`

**Field 4:** ⭐ **CRITICAL**
- [ ] Name: `role`
- [ ] Type: String
- [ ] Value: `admin` (lowercase, no quotes)

**Field 5:**
- [ ] Name: `isEmailVerified`
- [ ] Type: Boolean
- [ ] Value: `true`

**Field 6:**
- [ ] Name: `createdAt`
- [ ] Type: String
- [ ] Value: `2025-11-26T01:36:00.000Z`

**Field 7:**
- [ ] Name: `lastLogin`
- [ ] Type: String
- [ ] Value: `2025-11-26T01:36:00.000Z`

### **Phase 4: Verification**

- [ ] Check: `admins` collection exists
- [ ] Check: Admin document exists with User UID as ID
- [ ] Check: All 7 fields are present
- [ ] Check: `role` field is exactly `"admin"` (lowercase)
- [ ] Check: `isEmailVerified` is `true` (boolean, not string)
- [ ] Check: `email` matches Firebase Auth email

### **Phase 5: Test Sign In**

- [ ] Open your app in browser
- [ ] Go to Sign In page
- [ ] Enter Email: `admin@example.com`
- [ ] Enter Password: `Admin@123456`
- [ ] Open browser console (F12)
- [ ] Click: **"Sign In"** button
- [ ] Check console for: `"Is admin: true"`
- [ ] Verify: You see **Admin Dashboard** (not User Dashboard)

### **Phase 6: Final Verification**

- [ ] Console shows: `🚀 Navigating to admin dashboard`
- [ ] Admin Dashboard page loads
- [ ] You can see admin-specific features
- [ ] Sign out works correctly
- [ ] Can sign back in with same credentials

## 📊 **Expected Console Output**

When you sign in, you should see:

```
🔐 Starting sign in for: admin@example.com
✅ Firebase sign in successful: [uid]
📝 Loading user model from Firestore...
✅ Loaded admin from admins collection
👤 User role: UserRole.admin
👤 Is admin: true
🔄 Checking role for navigation...
👤 Final is admin: true
🚀 Navigating to admin dashboard
```

## 🔐 **Admin Credentials**

```
Email: admin@example.com
Password: Admin@123456
Role: admin
Collection: admins
```

## ⚠️ **Common Mistakes to Avoid**

- ❌ Role is `"Admin"` (capital A) → Use `"admin"` (lowercase)
- ❌ Role is `"admin_user"` → Use exactly `"admin"`
- ❌ Document in `users` collection → Create in `admins` collection
- ❌ isEmailVerified is `false` → Set to `true`
- ❌ Wrong User UID → Copy exact UID from Firebase Auth
- ❌ Missing fields → Add all 7 fields

## 📚 **Reference Documents**

If you need more help:
- `CREATE_ADMIN_ACCOUNT.md` - Detailed step-by-step guide
- `FIREBASE_ADMIN_SETUP_VISUAL.md` - Visual walkthrough
- `ADMIN_SETUP_SUMMARY.md` - Quick reference
- `SEPARATED_COLLECTIONS_GUIDE.md` - Collection structure

## ✅ **Success Criteria**

You'll know it's working when:
1. ✅ Sign in with admin credentials succeeds
2. ✅ Console shows "Is admin: true"
3. ✅ Automatically navigated to admin dashboard
4. ✅ Admin dashboard displays correctly
5. ✅ Can see admin-specific features

## 🎉 **You're Done!**

Once all checkboxes are complete, your admin account is ready to use!

**Admin Dashboard Access:** Automatic on sign-in ✅
