# Email.js Template Configuration Guide

## 📧 Current Email.js Configuration

**Service ID**: `service_vjt16z8`  
**Template ID**: `template_8otlueh`  
**Public Key**: `0u6uDa8ayOth_C76h`

## 🔧 Template Variables Required

Your Email.js template (`template_8otlueh`) MUST include these variables:

### ✅ Required Template Variables:
```
{{to_email}}        - Recipient email address
{{user_name}}       - User's name
{{verification_code}} - 6-digit verification code
{{subject}}         - Email subject line
```

## 📝 Example Email Template

Here's what your Email.js template should look like:

### **HTML Template Example:**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px;">
    <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        <h1 style="color: #5DADE2; text-align: center;">RoboCleanerBuddy</h1>
        <h2 style="color: #333; text-align: center;">Email Verification</h2>
        
        <p>Hello <strong>{{user_name}}</strong>,</p>
        
        <p>Thank you for signing up for RoboCleanerBuddy! To complete your registration, please use the verification code below:</p>
        
        <div style="background-color: #5DADE2; color: white; font-size: 24px; font-weight: bold; text-align: center; padding: 20px; margin: 20px 0; border-radius: 5px; letter-spacing: 5px;">
            {{verification_code}}
        </div>
        
        <p>This code will expire in 10 minutes for security reasons.</p>
        
        <p>If you didn't request this verification, please ignore this email.</p>
        
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        
        <p style="color: #666; font-size: 12px; text-align: center;">
            This is an automated message from RoboCleanerBuddy.<br>
            Please do not reply to this email.
        </p>
    </div>
</body>
</html>
```

### **Plain Text Template Example:**
```
Hello {{user_name}},

Thank you for signing up for RoboCleanerBuddy!

Your verification code is: {{verification_code}}

This code will expire in 10 minutes.

If you didn't request this verification, please ignore this email.

Best regards,
The RoboCleanerBuddy Team
```

## 🔍 How to Check Your Template

1. **Go to Email.js Dashboard**: https://dashboard.emailjs.com/
2. **Sign in** with your account
3. **Navigate to Email Templates**
4. **Select template**: `template_8otlueh`
5. **Verify the variables** are present:
   - `{{to_email}}`
   - `{{user_name}}`
   - `{{verification_code}}`
   - `{{subject}}`

## ⚠️ Common Template Issues

### ❌ Missing Variables:
If your template doesn't include `{{verification_code}}`, the code won't be sent.

### ❌ Incorrect Variable Names:
- Use `{{user_name}}` not `{{userName}}`
- Use `{{verification_code}}` not `{{code}}`

### ❌ Template Not Active:
Make sure your template is **Active** in Email.js dashboard.

## 🚀 How to Fix Template Issues

### **Option 1: Update Existing Template**
1. Go to Email.js Dashboard
2. Edit template `template_8otlueh`
3. Add the required variables
4. Save and activate

### **Option 2: Create New Template**
1. Click "Add New Template" in Email.js
2. Use the HTML template example above
3. Update the template ID in `email_service.dart`

### **Option 3: Test with Different Service**
1. Create a new Email Service
2. Update service ID in `email_service.dart`

## 📱 Testing the Email Service

### **Debug Mode Enabled**
The app now shows debug logs in the browser console:
- `📧 Sending verification code to: email@example.com`
- `📧 Verification code: 123456`
- `📧 Email.js response status: 200`
- `📧 Email.js response body: {"message":"OK"}`

### **Manual Testing**
1. Try to sign up
2. Check browser console (F12)
3. Look for the verification code in console
4. Enter the code manually in verification page

## 🔧 CORS Issues

If you see CORS errors:
1. In Email.js Dashboard → Settings → Authorized Domains
2. Add: `localhost:3000`, `127.0.0.1:3000`
3. Or your actual domain if deployed

## 📞 Email.js Support

If issues persist:
- Check Email.js documentation: https://www.emailjs.com/docs/
- Verify your account is active
- Check email sending limits
- Contact Email.js support

---

## ✅ Quick Checklist

- [ ] Template ID `template_8otlueh` exists
- [ ] Template contains `{{verification_code}}`
- [ ] Template contains `{{user_name}}`
- [ ] Template contains `{{to_email}}`
- [ ] Template is Active
- [ ] Service ID `service_vjt16z8` is active
- [ ] Public key `0u6uDa8ayOth_C76h` is correct
- [ ] Domain is authorized in Email.js settings

Follow this guide to ensure your Email.js template is configured correctly!
