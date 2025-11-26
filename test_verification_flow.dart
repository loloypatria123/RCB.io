/// Test script to verify the verification code flow
/// This will help us understand why you're not receiving verification codes

void main() {
  print('🔍 Testing Verification Code Flow\n');

  // Test 1: Generate verification code (same as your app)
  final verificationCode = generateVerificationCode();
  print('✅ Generated verification code: $verificationCode');
  print('   Code length: ${verificationCode.length}');
  print('   Is numeric: ${int.tryParse(verificationCode) != null}');
  print('');

  // Test 2: Check Email.js configuration
  print('📧 Email.js Configuration:');
  print('   Service ID: service_vjt16z8');
  print('   Template ID: template_8otlueh');
  print('   Public Key: 0u6uDa8ayOth_C76h');
  print('');

  // Test 3: Check template parameters being sent
  print('📝 Template Parameters Being Sent:');
  final templateParams = {
    'to_email': 'test@example.com',
    'user_name': 'Test User',
    'verification_code': verificationCode,
    'subject': 'Email Verification Code',
  };

  templateParams.forEach((key, value) {
    print('   $key: $value');
  });
  print('');

  // Test 4: Check if template variables are correct
  print('✅ Your Email.js Template Must Include:');
  print('   {{to_email}} - Recipient email');
  print('   {{user_name}} - User name');
  print('   {{verification_code}} - Verification code');
  print('   {{subject}} - Email subject');
  print('');

  print('🔍 Troubleshooting Steps:');
  print('1. Check Email.js dashboard: https://dashboard.emailjs.com/');
  print('2. Verify template template_8otlueh exists and is ACTIVE');
  print('3. Ensure template has all 4 variables above');
  print('4. Check if service service_vjt16z8 is ACTIVE');
  print('5. Verify domain authorization (localhost:3000)');
  print('6. Check Email.js credits/account status');
  print('');

  print('📱 Fallback Options:');
  print('- Check browser console (F12) for verification code');
  print('- Use "Show Code" button on verification page');
  print('- Look for verification code dialog');
  print('');

  print('🎯 Quick Test:');
  print('Try signing up and check browser console for:');
  print('📧 Sending verification code to: your@email.com');
  print('📧 Verification code: 123456');
  print('📧 Email.js response status: 200');
  print('✅ Verification code sent successfully!');
}

String generateVerificationCode() {
  return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
}
