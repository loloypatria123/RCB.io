import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/fallback_email_service.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _codeController = TextEditingController();
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    print('📧 Email verification page initialized');
    print('📧 Email: ${widget.email}');
    print('📧 Email length: ${widget.email.length}');

    if (widget.email.isEmpty) {
      print('❌ ERROR: Email is empty!');
    } else {
      print('✅ Email received correctly');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              // Logo Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.mail_outline,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'We sent a verification code to',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5DADE2),
                ),
              ),
              const SizedBox(height: 40),
              // Verification Code Input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12, width: 1.5),
                ),
                child: TextField(
                  controller: _codeController,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                    prefixIcon: const Icon(
                      Icons.vpn_key,
                      color: Colors.white54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Verify Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _verifyEmail(context, authProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DADE2),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Verify Email',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Error Message
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) =>
                    authProvider.errorMessage != null
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          authProvider.errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isResending ? null : () => _resendCode(context),
                    child: Text(
                      'Resend',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isResending
                            ? Colors.grey
                            : const Color(0xFF5DADE2),
                      ),
                    ),
                  ),
                  Text(
                    " or ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showCurrentCode(context),
                    child: Text(
                      'Show Code',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyEmail(BuildContext context, AuthProvider authProvider) async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the verification code',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final enteredCode = _codeController.text.trim();

    print('🔐 User entered code: $enteredCode');
    print('🔐 Code length: ${enteredCode.length}');
    print('🔐 Code type: ${enteredCode.runtimeType}');

    if (enteredCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification code must be 6 digits',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await authProvider.verifyEmail(enteredCode);

    if (success && mounted) {
      // Navigate based on role
      if (authProvider.isAdmin) {
        Navigator.of(context).pushReplacementNamed('/admin-dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/user-dashboard');
      }
    } else if (mounted) {
      print('❌ Verification failed');
    }
  }

  void _resendCode(BuildContext context) async {
    setState(() {
      _isResending = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendVerificationCode(
      widget.email,
      authProvider.userModel?.name ?? 'User',
    );

    if (mounted) {
      setState(() {
        _isResending = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification code resent to ${widget.email}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showCurrentCode(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final verificationCode = authProvider.verificationCode;

    if (verificationCode != null) {
      FallbackEmailService.showVerificationCodeDialog(
        context: context,
        email: widget.email,
        verificationCode: verificationCode,
        userName: authProvider.userModel?.name ?? 'User',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No verification code available. Please request a new one.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
