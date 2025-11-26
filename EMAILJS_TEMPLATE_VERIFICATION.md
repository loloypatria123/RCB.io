# Email.js Template Verification Guide

## 📧 **Current Email.js Configuration**

**Service ID**: `service_vjt16z8`  
**Template ID**: `template_8otlueh`  
**Public Key**: `0u6uDa8ayOth_C76h`  
**Email.js URL**: `https://api.emailjs.com/api/v1.0/email/send`

## 🔍 **Template Variables Being Sent**

Your Flutter app is sending these template parameters to Email.js:

```json
{
  "to_email": "user@example.com",
  "user_name": "John Doe", 
  "verification_code": "123456",
  "subject": "Email Verification Code"
}
```

## ✅ **Required Template Variables Checklist**

Your Email.js template (`template_8otlueh`) **MUST** include these exact variables:

| Variable Name | Value Source | Required? |
|---------------|-------------|-----------|
| `{{to_email}}` | User's email address | ✅ **REQUIRED** |
| `{{user_name}}` | User's display name | ✅ **REQUIRED** |
| `{{verification_code}}` | 6-digit code | ✅ **REQUIRED** |
| `{{subject}}` | Email subject | ✅ **REQUIRED** |

## 📝 **Complete Email Template Examples**

### **HTML Template (Recommended)**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            color: #5DADE2;
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .code-box {
            background-color: #5DADE2;
            color: white;
            font-size: 32px;
            font-weight: bold;
            text-align: center;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
            letter-spacing: 8px;
            text-decoration: none;
        }
        .footer {
            color: #666;
            font-size: 12px;
            text-align: center;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">RoboCleanerBuddy</div>
        
        <h2>Email Verification</h2>
        
        <p>Hello <strong>{{user_name}}</strong>,</p>
        
        <p>Thank you for signing up for RoboCleanerBuddy! To complete your registration, please use the verification code below:</p>
        
        <div class="code-box">
            {{verification_code}}
        </div>
        
        <p>This code will expire in 10 minutes for security reasons.</p>
        
        <p>If you didn't request this verification, please ignore this email.</p>
        
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        
        <div class="footer">
            This is an automated message from RoboCleanerBuddy.<br>
            Please do not reply to this email.
        </div>
    </div>
</body>
</html>
```

### **Plain Text Template (Simple)**
```
Hello {{user_name}},

Thank you for signing up for RoboCleanerBuddy!

Your verification code is: {{verification_code}}

This code will expire in 10 minutes.

If you didn't request this verification, please ignore this email.

Best regards,
The RoboCleanerBuddy Team
```

## 🔧 **How to Verify Your Email.js Template**

### **Step 1: Access Email.js Dashboard**
1. Go to: https://dashboard.emailjs.com/
2. Sign in with your Email.js account
3. Navigate to **Email Templates**

### **Step 2: Check Template `template_8otlueh`**
1. Find and click on template ID: `template_8otlueh`
2. **Verify the template is ACTIVE** (green status)
3. **Check the template content** includes all required variables

### **Step 3: Verify Template Variables**
Your template should contain these exact placeholders:
- ✅ `{{to_email}}` - Recipient email
- ✅ `{{user_name}}` - User's name  
- ✅ `{{verification_code}}` - 6-digit code
- ✅ `{{subject}}` - Email subject line

### **Step 4: Test the Template**
1. In Email.js dashboard, click **"Test"** on your template
2. Enter test values for all variables
3. Send a test email to verify it works

## ⚠️ **Common Template Issues & Fixes**

### **Issue 1: Missing Variables**
**Problem**: Template doesn't include `{{verification_code}}`
**Fix**: Add `{{verification_code}}` to your template content

### **Issue 2: Wrong Variable Names**
**Problem**: Using `{{userName}}` instead of `{{user_name}}`
**Fix**: Use exact variable names from the app

### **Issue 3: Template Inactive**
**Problem**: Template status is "Inactive"
**Fix**: Click "Activate" in Email.js dashboard

### **Issue 4: Service Issues**
**Problem**: Service `service_vjt16z8` is inactive
**Fix**: Check and activate your Email.js service

## 🚀 **Testing Your Template**

### **Test via Flutter App**
1. Run your Flutter app
2. Try to sign up with a real email
3. Check browser console (F12) for debug messages:
   ```
   📧 Sending verification code to: your@email.com
   📧 Verification code: 123456
   📧 Email.js response status: 200
   📧 Email.js response body: {"message":"OK"}
   ```

### **Test via Email.js Dashboard**
1. Go to Email.js dashboard
2. Select your template
3. Click "Test"
4. Fill in test values
5. Send test email

## 📱 **Fallback Verification**

If Email.js doesn't work, your app has a fallback system:
1. Shows verification code in a dialog
2. Displays code in browser console
3. Users can manually complete verification

## 🔐 **Security Considerations**

- ✅ Verification codes expire in 10 minutes
- ✅ Codes are 6 digits (secure enough)
- ✅ Each sign-up generates a new code
- ✅ Codes are stored securely in Firestore

## 📞 **Email.js Support**

If issues persist:
1. Check Email.js documentation: https://www.emailjs.com/docs/
2. Verify your account is active and has credits
3. Check email sending limits
4. Contact Email.js support

---

## ✅ **Final Verification Checklist**

- [ ] Template ID `template_8otlueh` exists and is ACTIVE
- [ ] Template contains `{{to_email}}`
- [ ] Template contains `{{user_name}}`
- [ ] Template contains `{{verification_code}}`
- [ ] Template contains `{{subject}}`
- [ ] Service ID `service_vjt16z8` is ACTIVE
- [ ] Public key `0u6uDa8ayOth_C76h` is correct
- [ ] Domain is authorized in Email.js settings
- [ ] Test email sends successfully
- [ ] All variables are properly formatted

---

## 🎯 **Quick Test Steps**

1. **Check Email.js Dashboard** → Templates → `template_8otlueh`
2. **Verify all 4 variables** are present in template
3. **Test template** with sample data
4. **Run Flutter app** and try sign-up
5. **Check console** for debug messages
6. **Verify email arrives** or use fallback dialog

Follow this guide to ensure your Email.js template is perfectly configured!
