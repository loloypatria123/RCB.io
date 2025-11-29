import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sign_up_page.dart';

// Professional Award-Winning Color Palette
const Color primaryDark = Color(0xFF0A0E27); // Deep navy - sophisticated base
const Color primaryMedium = Color(0xFF1A1F3A); // Rich navy - depth
const Color primaryLight = Color(0xFF2D3561); // Elegant blue-grey
const Color accentBlue = Color(0xFF4F46E5); // Modern indigo - premium feel
const Color accentCyan = Color(0xFF06B6D4); // Professional cyan - trust
const Color accentPurple = Color(0xFF8B5CF6); // Luxury purple - innovation

// Surface & Background Colors
const Color surfaceDark = Color(0xFF111827); // Card backgrounds - modern
const Color surfaceLight = Color(0xFF1F2937); // Elevated surfaces
const Color surfaceAccent = Color(0xFF374151); // Interactive elements

// Text Colors - High Contrast & Accessibility
const Color textPrimary = Color(0xFFF9FAFB); // Pure white text - clarity
const Color textSecondary = Color(0xFFD1D5DB); // Light grey - readable
const Color textMuted = Color(0xFF9CA3AF); // Muted grey - subtle
const Color textAccent = Color(0xFF60A5FA); // Blue accent text - links

// Status Colors - Professional & Clear
const Color successColor = Color(0xFF10B981); // Modern green - success
const Color warningColor = Color(0xFFF59E0B); // Amber - warnings
const Color errorColor = Color(0xFFEF4444); // Red - errors

// Premium Gradients
const LinearGradient backgroundGradient = LinearGradient(
  colors: [primaryDark, primaryMedium, primaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
);

const LinearGradient buttonGradient = LinearGradient(
  colors: [accentBlue, accentCyan],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient cardGradient = LinearGradient(
  colors: [surfaceDark, surfaceLight],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient accentGradient = LinearGradient(
  colors: [accentPurple, accentBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

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
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                const SizedBox(height: 12),
                // Enhanced Logo Circle with Premium Design
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: accentBlue.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: accentCyan.withOpacity(0.2),
                        blurRadius: 60,
                        offset: const Offset(0, 30),
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: buttonGradient,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'Verify Your Email',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'We sent a verification code to',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: accentBlue,
                  ),
                ),
                const SizedBox(height: 40),
                // Enhanced Verification Code Input
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: cardGradient,
                    border: Border.all(
                      color: primaryMedium.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryDark.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: accentBlue.withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _codeController,
                    style: GoogleFonts.poppins(
                      color: textPrimary,
                      fontSize: 20,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    cursorColor: accentBlue,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: GoogleFonts.poppins(
                        color: textMuted,
                        fontSize: 20,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Verify Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) => Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: authProvider.isLoading ? null : buttonGradient,
                      color: authProvider.isLoading ? textMuted : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: authProvider.isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: primaryMedium.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
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
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
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
                        color: textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isResending ? null : () => _resendCode(context),
                      child: Text(
                        'Resend',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isResending ? textMuted : accentBlue,
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
}
