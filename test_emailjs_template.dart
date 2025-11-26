/// Test script to verify Email.js template configuration
/// Run this script to test your Email.js setup

void main() {
  print('🔍 Email.js Template Verification Test\n');

  // Simulate the data being sent from your Flutter app
  final testData = {
    'service_id': 'service_vjt16z8',
    'template_id': 'template_8otlueh',
    'user_id': '0u6uDa8ayOth_C76h',
    'template_params': {
      'to_email': 'test@example.com',
      'user_name': 'Test User',
      'verification_code': _generateVerificationCode(),
      'subject': 'Email Verification Code',
    },
  };

  print('📧 Email.js Configuration:');
  print('   Service ID: ${testData['service_id']}');
  print('   Template ID: ${testData['template_id']}');
  print('   Public Key: ${testData['user_id']}');
  print('');

  print('📝 Template Parameters Being Sent:');
  final params = testData['template_params'] as Map<String, dynamic>;
  params.forEach((key, value) {
    print('   $key: $value');
  });
  print('');

  print('✅ Required Template Variables Checklist:');
  final requiredVars = [
    'to_email',
    'user_name',
    'verification_code',
    'subject',
  ];

  for (final varName in requiredVars) {
    final hasVar = params.containsKey(varName);
    final status = hasVar ? '✅' : '❌';
    print('   $status {{$varName}} - ${hasVar ? 'PRESENT' : 'MISSING'}');
  }
  print('');

  print('📋 Your Email.js Template Must Include:');
  print('   {{to_email}} - Recipient email address');
  print('   {{user_name}} - User\'s display name');
  print('   {{verification_code}} - 6-digit verification code');
  print('   {{subject}} - Email subject line');
  print('');

  print('🔧 Sample Email Template:');
  print('''   <h2>Hello {{user_name}},</h2>
   <p>Your verification code is:</p>
   <div style="font-size: 24px; font-weight: bold;">
       {{verification_code}}
   </div>
   <p>This code will expire in 10 minutes.</p>''');
  print('');

  print('🌐 Next Steps:');
  print('   1. Go to https://dashboard.emailjs.com/');
  print('   2. Check template: template_8otlueh');
  print('   3. Verify all variables are present');
  print('   4. Test template with sample data');
  print('   5. Ensure template is ACTIVE');
  print('');

  print('📱 Fallback Option:');
  print('   If Email.js fails, your app shows the verification code');
  print('   in a dialog and console logs for manual entry.');
}

String _generateVerificationCode() {
  return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
}
