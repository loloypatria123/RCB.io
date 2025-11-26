import 'package:flutter/material.dart';

class FallbackEmailService {
  /// Show verification code in dialog instead of sending email
  static void showVerificationCodeDialog({
    required BuildContext context,
    required String email,
    required String verificationCode,
    required String userName,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: Text(
          'Verification Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email service is currently unavailable.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              'Please use this verification code:',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF5DADE2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Code:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    verificationCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Email: $email',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              'Name: $userName',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'I\'ve copied the code',
              style: TextStyle(color: Color(0xFF5DADE2)),
            ),
          ),
        ],
      ),
    );
  }

  /// Copy verification code to clipboard
  static void copyToClipboard(String verificationCode) {
    // In a real app, you'd use flutter/services to copy to clipboard
    print('📋 Verification code copied to clipboard: $verificationCode');
  }
}
