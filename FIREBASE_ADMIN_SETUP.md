# Firebase Admin Account Setup Guide

## Method 2: Creating Admin Accounts Directly in Firebase

### Step 1: Access Firebase Console
1. Open your web browser and go to: https://console.firebase.google.com/
2. Sign in with your Google account
3. Select your project: `rcbfinal-e7f13`

### Step 2: Create Authentication User
1. In the left sidebar, click on **Authentication**
2. Click the **"Get Started"** button if you haven't already
3. Click the **"Add user"** button (top right)
4. Fill in the admin details:
   - **Email address**: admin@example.com (or your desired admin email)
   - **Password**: Create a secure password
5. Click **"Add user"**
6. **Important**: Copy the **User UID** from the user details page
   - It looks like: `aBcDeFgHiJkLmNoPqRsTuVwXyZ123456`
   - You'll need this for the next step

### Step 3: Create Firestore Document
1. In the left sidebar, click on **Firestore Database**
2. If you haven't set up Firestore, click **"Start collection"**
3. **Collection ID**: `users` (exactly this name)
4. Click **"Next"**
5. **Document ID**: Paste the User UID you copied from Step 2
6. Click **"Next"**
7. Add the following fields exactly as shown:

| Field | Type | Value |
|-------|------|-------|
| uid | string | (paste the same UID here) |
| email | string | admin@example.com |
| name | string | Admin User |
| role | string | admin |
| isEmailVerified | boolean | true |
| verificationCode | null | (leave empty) |
| verificationCodeExpiry | null | (leave empty) |
| createdAt | timestamp | (current date/time) |
| lastLogin | null | (leave empty) |

### Step 4: Verify the Setup
1. Click **"Save"** to create the document
2. You should see your admin user in the `users` collection
3. The admin can now sign in with their email and password
4. They will be automatically redirected to the admin dashboard

### Step 5: Test the Admin Account
1. Run your Flutter app
2. Go to the sign-in page
3. Enter the admin email and password
4. You should be redirected to the admin dashboard

---

## Important Notes:

### Security Considerations:
- Always use strong passwords for admin accounts
- Consider implementing two-factor authentication
- Regularly review admin account access
- Change the admin registration code (`ADMIN2025!`) in production

### Multiple Admin Accounts:
You can create multiple admin accounts by repeating these steps:
- Each admin needs a unique email
- Each admin gets their own Firebase Authentication user
- Each admin gets their own Firestore document with `role: "admin"`

### Field Explanations:
- `uid`: Must match the Firebase Authentication UID exactly
- `role`: Must be `"admin"` (lowercase) for admin access
- `isEmailVerified`: Set to `true` since you're creating directly
- `createdAt`: Current timestamp when you create the account
- `lastLogin`: Will be updated automatically when they sign in

### Troubleshooting:
If the admin account doesn't work:
1. Check that the UID matches exactly between Authentication and Firestore
2. Verify the `role` field is `"admin"` (not `"Admin"` or `"ADMIN"`)
3. Ensure the email is verified in Firebase Authentication
4. Check that the Firestore collection name is exactly `users`

---

## Example Complete Admin Document:

```json
{
  "uid": "aBcDeFgHiJkLmNoPqRsTuVwXyZ123456",
  "email": "admin@example.com", 
  "name": "System Administrator",
  "role": "admin",
  "isEmailVerified": true,
  "verificationCode": null,
  "verificationCodeExpiry": null,
  "createdAt": "2025-11-25T15:30:00.000Z",
  "lastLogin": null
}
```

Follow these steps exactly and your admin account will work perfectly!
