import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import 'sign_in_page.dart';
import '../widgets/animated_robot_logo.dart';
import '../models/user_model.dart';

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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(context: context),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Update context in AuthProvider
          authProvider.setContext(context);
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(gradient: backgroundGradient),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                      // Enhanced Animated Robot Logo with Premium Container
                      Container(
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
                        child: const AnimatedRobotLogo(
                          size: 100,
                          enableCursorTracking: true,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Welcome Text
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join us today',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Name Field
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Enter your name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      _buildPasswordField(),
                      const SizedBox(height: 16),
                      // Terms Agreement
                      Row(
                        children: [
                          Consumer<UIProvider>(
                            builder: (context, uiProvider, _) => Checkbox(
                              value: uiProvider.agreeToTerms,
                              onChanged: (value) {
                                uiProvider.setAgreeToTerms(value ?? false);
                              },
                              activeColor: accentBlue,
                              checkColor: Colors.white,
                              side: BorderSide(color: accentBlue, width: 2),
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'I agree to ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Conditions',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: accentBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: accentBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Sign Up Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) => Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: authProvider.isLoading
                                ? null
                                : buttonGradient,
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
                                : () => _handleSignUp(context, authProvider),
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
                                    'Sign Up',
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
                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SignInPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: primaryMedium.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: primaryMedium.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                              icon: Icons.g_mobiledata,
                              label: 'Google',
                              onTap: () {
                                _showComingSoonDialog('Google Sign Up');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSocialButton(
                              icon: Icons.facebook,
                              label: 'Facebook',
                              onTap: () {
                                _showComingSoonDialog('Facebook Sign Up');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Footer Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Handle terms of service
                            },
                            child: Text(
                              'Terms of Service',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: textMuted,
                              ),
                            ),
                          ),
                          Text(
                            ' • ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle privacy policy
                            },
                            child: Text(
                              'Privacy Policy',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: textMuted,
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
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: cardGradient,
        border: Border.all(color: primaryMedium.withOpacity(0.3), width: 1.5),
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
        controller: controller,
        style: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: cardGradient,
          border: Border.all(color: primaryMedium.withOpacity(0.3), width: 1.5),
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
          controller: _passwordController,
          obscureText: uiProvider.obscurePassword,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: GoogleFonts.poppins(
              color: textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                uiProvider.toggleObscurePassword();
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  uiProvider.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                  size: 20,
                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: surfaceDark.withOpacity(0.6),
          border: Border.all(color: primaryMedium.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryDark.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          feature,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Coming Soon!',
          style: GoogleFonts.poppins(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: accentBlue)),
          ),
        ],
      ),
    );
  }

  void _handleSignUp(BuildContext context, AuthProvider authProvider) async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    print('🚀 Starting sign-up process...');

    final success = await authProvider.signUpWithRole(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: UserRole.user,
    );

    print('📊 Sign-up result: $success');
    print('📊 Error message: ${authProvider.errorMessage}');
    print('📊 Mounted: $mounted');

    if (success && mounted) {
      print('🔄 Navigating to email verification page...');
      Navigator.of(context).pushReplacementNamed(
        '/email-verification',
        arguments: _emailController.text,
      );
      print('✅ Navigation completed');
    } else if (mounted) {
      print('❌ Sign-up failed, showing error message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Sign up failed',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      print('❌ Widget not mounted, cannot show error');
    }
  }
}
