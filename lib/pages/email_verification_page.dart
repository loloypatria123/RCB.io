import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import 'sign_up_page.dart';

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
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.neutralDark,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryDarkBlue.withOpacity(0.3),
                    border: Border.all(
                      color: AppColors.primaryLightBlue.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.accentYellow,
                    size: 60,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Verify Email',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the code sent to',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLightBlue,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Code Input
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutralDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryDarkBlue,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _codeController,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    cursorColor: AppColors.accentYellow,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: GoogleFonts.roboto(
                        color: Colors.grey[700],
                        fontSize: 24,
                        letterSpacing: 8,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 24,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Verify Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) => Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: authProvider.isLoading
                          ? null
                          : const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.primaryDarkBlue,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: authProvider.isLoading ? Colors.grey[700] : null,
                      boxShadow: authProvider.isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _verifyEmail(context, authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accentYellow,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'VERIFY',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Error Message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) =>
                      authProvider.errorMessage != null
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.errorColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            authProvider.errorMessage!,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.errorColor,
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
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Colors.grey[400],
                      ),
                    ),
                    GestureDetector(
                      onTap: _isResending ? null : () => _resendCode(context),
                      child: Text(
                        'Resend',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _isResending ? Colors.grey[600] : AppColors.accentYellow,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
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
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    final enteredCode = _codeController.text.trim();

    if (enteredCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification code must be 6 digits',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    final success = await authProvider.verifyEmail(enteredCode);

    if (success && mounted) {
      if (authProvider.isAdmin) {
        Navigator.of(context).pushReplacementNamed('/admin-dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/user-dashboard');
      }
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
              'Verification code resent',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }
}
