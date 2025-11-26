import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  // Email.js configuration - Replace with your actual credentials
  static const String serviceId = 'service_vjt16z8';
  static const String templateId = 'template_8otlueh';
  static const String publicKey = '0u6uDa8ayOth_C76h';
  static const String emailJsUrl =
      'https://api.emailjs.com/api/v1.0/email/send';

  /// Generate a 6-digit verification code
  static String generateVerificationCode() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
  }

  /// Send verification code via Email.js
  static Future<void> sendVerificationCode({
    required String email,
    required String verificationCode,
    required String userName,
  }) async {
    try {
      print('📧 Sending verification code to: $email');
      print('📧 Verification code: $verificationCode');

      final url = Uri.parse(emailJsUrl);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'https://localhost:3000',
          'Access-Control-Allow-Origin': '*',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': email,
            'user_name': userName,
            'verification_code': verificationCode,
            'subject': 'Email Verification Code',
          },
        }),
      );

      print('📧 Email.js response status: ${response.statusCode}');
      print('📧 Email.js response body: ${response.body}');

      if (response.statusCode != 200) {
        print('❌ Email.js error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to send email: ${response.body}');
      }

      print('✅ Verification code sent successfully!');
    } catch (e) {
      print('❌ Error sending verification code: $e');
      rethrow;
    }
  }

  /// Send welcome email
  static Future<void> sendWelcomeEmail({
    required String email,
    required String userName,
  }) async {
    try {
      print('📧 Sending welcome email to: $email');

      final url = Uri.parse(emailJsUrl);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'https://localhost:3000',
          'Access-Control-Allow-Origin': '*',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': email,
            'user_name': userName,
            'subject': 'Welcome to RoboCleanerBuddy!',
          },
        }),
      );

      print('📧 Welcome email response status: ${response.statusCode}');
      print('📧 Welcome email response body: ${response.body}');

      if (response.statusCode != 200) {
        print(
          '❌ Welcome email error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to send welcome email: ${response.body}');
      }

      print('✅ Welcome email sent successfully!');
    } catch (e) {
      print('❌ Error sending welcome email: $e');
      rethrow;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail({
    required String email,
    required String resetLink,
  }) async {
    try {
      print('📧 Sending password reset email to: $email');

      final url = Uri.parse(emailJsUrl);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'https://localhost:3000',
          'Access-Control-Allow-Origin': '*',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': email,
            'reset_link': resetLink,
            'subject': 'Password Reset Request',
          },
        }),
      );

      print('📧 Password reset email response status: ${response.statusCode}');
      print('📧 Password reset email response body: ${response.body}');

      if (response.statusCode != 200) {
        print(
          '❌ Password reset email error: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to send password reset email: ${response.body}',
        );
      }

      print('✅ Password reset email sent successfully!');
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      rethrow;
    }
  }
}
