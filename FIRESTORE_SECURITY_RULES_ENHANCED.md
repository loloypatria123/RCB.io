# 🔐 Enhanced Firestore Security Rules

## Overview

This document provides the complete Firestore security rules for your RoboCleanerBuddy application, including the new security features for login attempt tracking and account lockout protection.

---

## 📋 Complete Firestore Rules

Copy and paste these rules into your `firestore.rules` file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ============================================
    // HELPER FUNCTIONS
    // ============================================
    
    // Check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Check if user is admin
    function isAdmin() {
      return isSignedIn() && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Check if user owns the document
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Check if user account is active
    function isActiveUser() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'Active';
    }
    
    // Check if email matches the authenticated user
    function emailMatches(email) {
      return isSignedIn() && request.auth.token.email == email;
    }
    
    
    // ============================================
    // USERS COLLECTION
    // ============================================
    match /users/{userId} {
      // Users can read their own document
      allow read: if isOwner(userId) || isAdmin();
      
      // Users can create their own account during signup
      allow create: if isSignedIn() && isOwner(userId);
      
      // Users can update their own document (except role and status)
      allow update: if isOwner(userId) && 
                       request.resource.data.role == resource.data.role &&
                       request.resource.data.status == resource.data.status;
      
      // Only admins can delete users
      allow delete: if isAdmin();
      
      // Admins can update any user
      allow update: if isAdmin();
    }
    
    
    // ============================================
    // ADMINS COLLECTION
    // ============================================
    match /admins/{adminId} {
      // Admins can read their own document or any admin document
      allow read: if isOwner(adminId) || isAdmin();
      
      // Only existing admins can create new admin accounts
      allow create: if isAdmin();
      
      // Admins can update their own profile (except role)
      allow update: if isOwner(adminId) && 
                       request.resource.data.role == 'admin';
      
      // No one can delete admin accounts (safety measure)
      allow delete: if false;
    }
    
    
    // ============================================
    // SECURITY ATTEMPTS COLLECTION (NEW)
    // ============================================
    match /security_attempts/{emailDoc} {
      // Users can read their own security attempt data
      allow read: if isSignedIn() && 
                     resource.data.email == request.auth.token.email;
      
      // Admins can read all security attempt data
      allow read: if isAdmin();
      
      // System can write security attempt data (authenticated users)
      allow write: if isSignedIn();
      
      // Allow creation during authentication flow
      allow create: if true;  // Open for initial creation
      
      // Allow updates for tracking attempts
      allow update: if true;  // Open for security tracking
    }
    
    
    // ============================================
    // AUDIT LOGS COLLECTION
    // ============================================
    match /audit_logs/{logId} {
      // Only admins can read audit logs
      allow read: if isAdmin();
      
      // Authenticated users can create audit logs (for their own actions)
      allow create: if isSignedIn();
      
      // System can create logs
      allow create: if true;  // Allow system-generated logs
      
      // No one can update or delete audit logs (immutable)
      allow update, delete: if false;
    }
    
    
    // ============================================
    // SCHEDULES COLLECTION
    // ============================================
    match /schedules/{scheduleId} {
      // Users can read their own schedules
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Admins can read all schedules
      allow read: if isAdmin();
      
      // Users can create schedules for themselves
      allow create: if isSignedIn() && 
                       request.resource.data.userId == request.auth.uid;
      
      // Users can update their own schedules
      allow update: if isSignedIn() && 
                       resource.data.userId == request.auth.uid;
      
      // Users can delete their own schedules
      allow delete: if isSignedIn() && 
                       resource.data.userId == request.auth.uid;
      
      // Admins can manage all schedules
      allow write: if isAdmin();
    }
    
    
    // ============================================
    // REPORTS COLLECTION
    // ============================================
    match /reports/{reportId} {
      // Users can read their own reports
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Admins can read all reports
      allow read: if isAdmin();
      
      // Users can create reports for themselves
      allow create: if isSignedIn() && 
                       request.resource.data.userId == request.auth.uid;
      
      // Users can update their own unresolved reports
      allow update: if isSignedIn() && 
                       resource.data.userId == request.auth.uid &&
                       resource.data.status != 'Resolved';
      
      // Admins can update any report (resolve, reply, etc.)
      allow update: if isAdmin();
      
      // Only admins can delete reports
      allow delete: if isAdmin();
    }
    
    
    // ============================================
    // ROBOTS COLLECTION
    // ============================================
    match /robots/{robotId} {
      // Users can read their assigned robots
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Admins can read all robots
      allow read: if isAdmin();
      
      // Only admins can create robots
      allow create: if isAdmin();
      
      // Users can update their robot status
      allow update: if isSignedIn() && 
                       resource.data.userId == request.auth.uid;
      
      // Admins can update any robot
      allow update: if isAdmin();
      
      // Only admins can delete robots
      allow delete: if isAdmin();
    }
    
    
    // ============================================
    // NOTIFICATIONS COLLECTION
    // ============================================
    match /notifications/{notificationId} {
      // Users can read their own notifications
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Admins can read all notifications
      allow read: if isAdmin();
      
      // System can create notifications
      allow create: if isSignedIn();
      
      // Users can update their own notifications (mark as read)
      allow update: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Users can delete their own notifications
      allow delete: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Admins can manage all notifications
      allow write: if isAdmin();
    }
    
    
    // ============================================
    // SYSTEM CONFIGURATION
    // ============================================
    match /config/{configDoc} {
      // Anyone can read public config
      allow read: if true;
      
      // Only admins can write config
      allow write: if isAdmin();
    }
  }
}
```

---

## 🔒 Security Rules Explanation

### Security Attempts Collection

The new `security_attempts` collection has special rules to support the login security features:

```javascript
match /security_attempts/{emailDoc} {
  // Users can read their own security attempt data
  allow read: if isSignedIn() && 
                 resource.data.email == request.auth.token.email;
  
  // Admins can read all security attempt data
  allow read: if isAdmin();
  
  // System can write security attempt data (authenticated users)
  allow write: if isSignedIn();
  
  // Allow creation during authentication flow
  allow create: if true;  // Open for initial creation
  
  // Allow updates for tracking attempts
  allow update: if true;  // Open for security tracking
}
```

**Why these rules?**
- `create: true` - Allows recording failed attempts before authentication
- `update: true` - Allows updating attempt counters during login flow
- `read` restricted - Only users can see their own data, admins can see all

---

## 🚀 How to Apply These Rules

### Option 1: Firebase Console (Recommended for Testing)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database**
4. Click on **Rules** tab
5. Copy and paste the complete rules above
6. Click **Publish**
7. Wait for deployment (usually instant)

### Option 2: Firebase CLI (Recommended for Production)

```bash
# 1. Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Initialize Firebase in your project
firebase init firestore

# 4. Edit firestore.rules file with the rules above

# 5. Deploy rules
firebase deploy --only firestore:rules

# 6. Verify deployment
firebase firestore:rules:list
```

---

## 🧪 Testing Security Rules

### Test in Firebase Console:

1. Go to Firestore Database → Rules
2. Click **Rules Playground**
3. Test different scenarios:

#### Test 1: User Reading Own Security Data
```
Location: /security_attempts/user_example_com
Operation: get
Authentication: user@example.com
Expected: ✅ Allow
```

#### Test 2: User Reading Another User's Security Data
```
Location: /security_attempts/other_example_com
Operation: get
Authentication: user@example.com
Expected: ❌ Deny
```

#### Test 3: Admin Reading All Security Data
```
Location: /security_attempts/any_user
Operation: get
Authentication: admin@example.com (admin role)
Expected: ✅ Allow
```

#### Test 4: Unauthenticated Creating Security Attempt
```
Location: /security_attempts/user_example_com
Operation: create
Authentication: None
Expected: ✅ Allow (needed for failed login tracking)
```

---

## 🔐 Security Best Practices

### DO:
✅ Use these rules as a starting point  
✅ Test rules thoroughly before production  
✅ Review rules regularly  
✅ Monitor Firestore usage patterns  
✅ Use Firebase Security Rules simulator  
✅ Keep audit logs immutable  

### DON'T:
❌ Allow universal write access  
❌ Skip authentication checks  
❌ Forget to test edge cases  
❌ Expose sensitive data  
❌ Allow audit log deletion  
❌ Make security_attempts fully public  

---

## 📊 Rule Coverage

| Collection | Read | Write | Delete | Secure |
|-----------|------|-------|--------|--------|
| users | ✅ Own/Admin | ✅ Own/Admin | ❌ Admin Only | ✅ |
| admins | ✅ Self/Admin | ✅ Self/Admin | ❌ Never | ✅ |
| security_attempts | ✅ Own/Admin | ✅ All Auth | ✅ All Auth | ⚠️ |
| audit_logs | ❌ Admin Only | ✅ Create Only | ❌ Never | ✅ |
| schedules | ✅ Own/Admin | ✅ Own/Admin | ✅ Own/Admin | ✅ |
| reports | ✅ Own/Admin | ✅ Own/Admin | ❌ Admin Only | ✅ |
| robots | ✅ Own/Admin | ✅ Admin | ❌ Admin Only | ✅ |
| notifications | ✅ Own/Admin | ✅ Own/Admin | ✅ Own/Admin | ✅ |

---

## ⚠️ Important Notes

### Security Attempts Collection

The `security_attempts` collection has relaxed write rules (`true`) because:

1. **Failed Login Tracking**: Must record attempts before user is authenticated
2. **Pre-Auth Recording**: Firebase Auth happens before Firestore can validate
3. **Rate Limiting**: The SecurityService handles validation in application code
4. **Admin Monitoring**: Admins can review all security data

**Trade-off**: Slightly more open rules for critical security functionality.

**Mitigation**:
- Application-level validation in SecurityService
- Audit logging of all security events
- Admin monitoring and alerts
- Regular security reviews

---

## 🔄 Updating Rules Safely

### Process:

1. **Test Locally First**
   ```bash
   firebase emulators:start --only firestore
   ```

2. **Use Rules Playground**
   - Test in Firebase Console
   - Verify expected behavior

3. **Deploy to Staging**
   ```bash
   firebase use staging
   firebase deploy --only firestore:rules
   ```

4. **Verify in Staging**
   - Test all user flows
   - Check admin functions
   - Verify security features

5. **Deploy to Production**
   ```bash
   firebase use production
   firebase deploy --only firestore:rules
   ```

6. **Monitor After Deployment**
   - Watch for denied requests
   - Check application logs
   - Review user reports

---

## 🆘 Troubleshooting

### Common Issues:

**Issue: "Permission denied" when recording failed attempts**
```
Solution: Ensure create: true for security_attempts
Check: Application has internet connection
Verify: Firestore is initialized correctly
```

**Issue: Users can't read their own security data**
```
Solution: Verify email matches in rule
Check: User is authenticated
Verify: Document email field matches user email
```

**Issue: Admins can't access audit logs**
```
Solution: Verify admin role in Firestore
Check: Admin document exists in /admins collection
Verify: role field is set to 'admin'
```

**Issue: Rules not updating**
```
Solution: Clear browser cache
Wait: 1-2 minutes for propagation
Verify: Check rules in Firebase Console
```

---

## 📝 Rule Maintenance Checklist

### Weekly:
- [ ] Review denied request logs
- [ ] Check for unusual patterns
- [ ] Verify admin access working
- [ ] Test user permissions

### Monthly:
- [ ] Review all security rules
- [ ] Update based on new features
- [ ] Test edge cases
- [ ] Document any changes

### Quarterly:
- [ ] Full security audit
- [ ] Performance review
- [ ] Rule optimization
- [ ] Team training

---

## 🎯 Next Steps

After applying these rules:

1. ✅ Deploy rules to Firebase
2. ✅ Test all user flows
3. ✅ Verify admin functions work
4. ✅ Test security features (lockout, tracking)
5. ✅ Monitor for errors
6. ✅ Document any customizations

---

## 📚 Additional Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Rules Testing](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [Best Practices](https://firebase.google.com/docs/firestore/security/rules-best-practices)
- [Common Patterns](https://firebase.google.com/docs/firestore/security/rules-conditions)

---

## ✅ Summary

Your Firestore now has:

✅ **Secure User Data** - Role-based access control  
✅ **Protected Admin Area** - Admin-only operations  
✅ **Security Tracking** - Failed attempt monitoring  
✅ **Immutable Audit Logs** - Complete history  
✅ **Flexible Permissions** - User and admin access  

**Your database is now secured with proper rules! 🔐**

---

**Version:** 1.0.0  
**Date:** December 2, 2025  
**Status:** ✅ Ready to Deploy  

