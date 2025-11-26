import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                child: const Icon(Icons.pets, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 32),
              // Welcome Text
              Text(
                'Welcome to Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buddy!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5DADE2),
                ),
              ),
              const SizedBox(height: 40),
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
              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Consumer<UIProvider>(
                        builder: (context, uiProvider, _) => Checkbox(
                          value: uiProvider.rememberMe,
                          onChanged: (value) {
                            uiProvider.setRememberMe(value ?? false);
                          },
                          activeColor: const Color(0xFF5DADE2),
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF5DADE2),
                            width: 2,
                          ),
                        ),
                      ),
                      Text(
                        'Remember Me',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF5DADE2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Sign In Button
              Consumer<UIProvider>(
                builder: (context, uiProvider, _) => Consumer<AuthProvider>(
                  builder: (context, authProvider, _) => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleSignIn(context, authProvider),
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
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5DADE2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Divider
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Colors.white12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: Colors.white12)),
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
                        _showComingSoonDialog('Google Sign In');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      onTap: () {
                        _showComingSoonDialog('Facebook Sign In');
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
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  Text(
                    ' • ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white54,
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
                        color: Colors.white54,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12, width: 1.5),
        ),
        child: TextField(
          controller: _passwordController,
          obscureText: uiProvider.obscurePassword,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
            suffixIcon: GestureDetector(
              onTap: () {
                uiProvider.toggleObscurePassword();
              },
              child: Icon(
                uiProvider.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white54,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
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
        backgroundColor: const Color(0xFF1A1F2E),
        title: Text(
          feature,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Coming Soon!',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFF5DADE2)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignIn(BuildContext context, AuthProvider authProvider) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
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

    print('🔐 Starting sign in...');

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    print('✅ Sign in result: $success');
    print('👤 User role: ${authProvider.userRole}');
    print('👤 Is admin: ${authProvider.isAdmin}');
    print('👤 User model: ${authProvider.userModel}');

    if (success && mounted) {
      // Add delay to ensure user model is fully loaded from Firestore
      await Future.delayed(const Duration(milliseconds: 1000));

      print('🔄 Checking role for navigation...');
      print('👤 Final user role: ${authProvider.userRole}');
      print('👤 Final is admin: ${authProvider.isAdmin}');
      print('👤 Final user model: ${authProvider.userModel}');

      // Check if admin account but no Firestore document (missing admin collection)
      if (authProvider.user != null &&
          authProvider.userModel == null &&
          _emailController.text.toLowerCase().contains('admin')) {
        print('⚠️ Admin account detected but Firestore document missing!');
        print('🔄 Showing admin recovery page...');

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/admin-recovery',
            arguments: {
              'uid': authProvider.user!.uid,
              'email': _emailController.text.trim(),
            },
          );
        }
        return;
      }

      // Navigate based on role
      if (authProvider.isAdmin) {
        print('🚀 Navigating to admin dashboard');
        Navigator.of(context).pushReplacementNamed('/admin-dashboard');
      } else {
        print('🚀 Navigating to user dashboard');
        Navigator.of(context).pushReplacementNamed('/user-dashboard');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Sign in failed',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }
}
