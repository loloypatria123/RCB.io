# ✅ **CREATE ADMIN ACCOUNT IN FIREBASE**

## 🎯 **Goal**
Create an admin account that will automatically navigate to the admin dashboard upon sign-in.

## 📋 **Step-by-Step Instructions**

### **Step 1: Create Firebase Auth User**

1. Go to: https://console.firebase.google.com/
2. Select project: `rcbfinal-e7f13`
3. Go to: **Authentication** → **Users**
4. Click **"Add user"** or **"Create user"**
5. Enter:
   - **Email**: `admin@example.com` (or your preferred admin email)
   - **Password**: `Admin@123456` (or your preferred password)
6. Click **"Create user"**
7. Copy the **User UID** (you'll need it next)

### **Step 2: Create Admin Document in Firestore**

1. Go to: **Firestore Database** → **Collections**
2. Click **"Create collection"**
3. Enter collection name: `admins`
4. Click **"Next"**
5. Click **"Add document"**
6. Set document ID to the **User UID** from Step 1
7. Add the following fields:

| Field | Type | Value |
|-------|------|-------|
| `uid` | String | (paste the User UID) |
| `email` | String | `admin@example.com` |
| `name` | String | `Admin User` |
| `role` | String | `admin` |
| `isEmailVerified` | Boolean | `true` |
| `createdAt` | String | (current ISO date, e.g., `2025-11-26T01:36:00.000Z`) |
| `lastLogin` | String | (current ISO date, e.g., `2025-11-26T01:36:00.000Z`) |

### **Step 3: Verify Document Structure**

Your admin document should look exactly like this:

```json
{
  "uid": "firebase_user_id_here",
  "email": "admin@example.com",
  "name": "Admin User",
  "role": "admin",
  "isEmailVerified": true,
  "createdAt": "2025-11-26T01:36:00.000Z",
  "lastLogin": "2025-11-26T01:36:00.000Z"
}
```

**IMPORTANT**: The `role` field MUST be exactly `"admin"` (lowercase, as a string).

## 🧪 **Test the Admin Account**

### **Test Sign In**

1. **Open the app** in your browser
2. **Go to Sign In page**
3. **Enter credentials**:
   - Email: `admin@example.com`
   - Password: `Admin@123456`
4. **Click Sign In**
5. **Open browser console** (F12)
6. **Look for these messages**:
   ```
   🔐 Starting sign in for: admin@example.com
   ✅ Firebase sign in successful: [user_id]
   📝 Loading user model from Firestore...
   ✅ Loaded admin from admins collection
   👤 User role: UserRole.admin
   👤 Is admin: true
   🔄 Checking role for navigation...
   👤 Final is admin: true
   🚀 Navigating to admin dashboard
   ```

7. **Should navigate to admin dashboard** automatically ✅

## 📊 **Expected Behavior**

| Step | Expected Result |
|------|-----------------|
| Sign in with admin email | ✅ Firebase authenticates |
| Load user model | ✅ Loads from `admins` collection |
| Check role | ✅ Role is `admin` |
| Navigate | ✅ Goes to `/admin-dashboard` |

## ⚠️ **Troubleshooting**

### **Issue: Still going to user dashboard**
**Cause**: Role field is not `"admin"` or document doesn't exist
**Solution**:
1. Check Firestore console
2. Verify `admins` collection exists
3. Verify `role` field is exactly `"admin"`
4. Refresh browser and try again

### **Issue: "User not found" error**
**Cause**: Firebase Auth user doesn't exist
**Solution**:
1. Go to Authentication → Users
2. Create the user first
3. Copy the User UID
4. Create Firestore document with that UID

### **Issue: Can't find the user in Firestore**
**Cause**: Document doesn't exist in `admins` collection
**Solution**:
1. Go to Firestore Database
2. Check if `admins` collection exists
3. If not, create it
4. Create the admin document

## 🔐 **Security Note**

- ✅ Email verified: `true` (so no verification needed)
- ✅ Role: `admin` (determines dashboard routing)
- ✅ Password: Set in Firebase Auth (not stored in Firestore)

## 📝 **Quick Reference**

**Admin Account Details:**
- Email: `admin@example.com`
- Password: `Admin@123456`
- Role: `admin`
- Collection: `admins`
- isEmailVerified: `true`

## ✅ **Final Checklist**

- [ ] Firebase Auth user created
- [ ] User UID copied
- [ ] `admins` collection created in Firestore
- [ ] Admin document created with correct UID
- [ ] All fields added correctly
- [ ] `role` field is `"admin"`
- [ ] `isEmailVerified` is `true`
- [ ] Sign in test successful
- [ ] Console shows "Is admin: true"
- [ ] Navigated to admin dashboard

**Admin account is ready to use!** 🎉
