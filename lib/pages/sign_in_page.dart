import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/animated_robot_logo.dart';
import '../constants/app_colors.dart';
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.neutralDark,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),
                // Robot Logo Area
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: const AnimatedRobotLogo(
                    size: 80,
                    enableCursorTracking: true,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Welcome Back',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your robot controls',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 48),

                // Form Fields
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email Address',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(),
                
                const SizedBox(height: 24),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Consumer<UIProvider>(
                          builder: (context, uiProvider, _) => SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: uiProvider.rememberMe,
                              onChanged: (value) {
                                uiProvider.setRememberMe(value ?? false);
                              },
                              activeColor: AppColors.accentYellow,
                              checkColor: AppColors.neutralDark,
                              side: BorderSide(
                                color: Colors.grey[500]!,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember Me',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle forgot password
                        _showComingSoonDialog('Forgot Password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.primaryLightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Sign In Button
                Consumer<UIProvider>(
                  builder: (context, uiProvider, _) => Consumer<AuthProvider>(
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
                            : () => _handleSignIn(context, authProvider),
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
                                'SIGN IN',
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
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Colors.grey[400],
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
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentYellow,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Social Login
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[800],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR CONNECT WITH',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.g_mobiledata, () => _showComingSoonDialog('Google Sign In')),
                    const SizedBox(width: 20),
                    _buildSocialButton(Icons.facebook, () => _showComingSoonDialog('Facebook Sign In')),
                  ],
                ),
                SizedBox(height: size.height * 0.05),
              ],
            ),
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
        color: AppColors.neutralDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryDarkBlue,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(
            color: Colors.grey[600],
            fontSize: 15,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryLightBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
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
          color: AppColors.neutralDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryDarkBlue,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _passwordController,
          obscureText: uiProvider.obscurePassword,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: GoogleFonts.roboto(
              color: Colors.grey[600],
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded, 
              color: AppColors.primaryLightBlue
            ),
            suffixIcon: IconButton(
              icon: Icon(
                uiProvider.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[600],
              ),
              onPressed: () => uiProvider.toggleObscurePassword(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.neutralDark,
          border: Border.all(color: AppColors.primaryDarkBlue),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutralDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryDarkBlue),
        ),
        title: Text(
          feature,
          style: GoogleFonts.orbitron(
            color: AppColors.accentYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This feature is coming soon!',
          style: GoogleFonts.roboto(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK', 
              style: TextStyle(color: AppColors.primaryLightBlue),
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
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    print('🔐 Starting sign in...');

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Add delay to ensure user model is fully loaded from Firestore
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final userStatus = authProvider.userModel?.status ?? 'Active';
      if (authProvider.userModel != null && userStatus != 'Active') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your account is inactive. Please contact the administrator.',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: AppColors.warningColor,
          ),
        );
        await authProvider.signOut();
        return;
      }

      // Check if admin account but no Firestore document (missing admin collection)
      if (authProvider.user != null &&
          authProvider.userModel == null &&
          _emailController.text.toLowerCase().contains('admin')) {
        
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
        Navigator.of(context).pushReplacementNamed('/admin-dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/user-dashboard');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Sign in failed',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }
}
