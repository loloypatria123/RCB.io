import 'package:flutter/material.dart';

/// Application color constants
class AppColors {
  // Blue gradient palette from design (darkest to lightest)
  static const Color darkestBlue = Color(0xFF021024); // #021024
  static const Color darkBlue = Color(0xFF052659); // #052659
  static const Color mediumBlue = Color(0xFF5483B3); // #5483B3
  static const Color lightBlue = Color(0xFF7DA0CA); // #7DA0CA
  static const Color lightestBlue = Color(0xFFC1E8FF); // #C1E8FF

  // Background colors
  static const Color scaffoldBg = Color(0xFF021024); // Darkest blue
  static const Color cardBg = Color(0xFF052659); // Dark blue
  static const Color surfaceBg = Color(0xFF0A1A3A); // Between dark and medium

  // Primary accent colors
  static const Color accentPrimary = Color(0xFF5483B3); // Medium blue
  static const Color accentSecondary = Color(0xFF7DA0CA); // Light blue
  static const Color accentLight = Color(0xFFC1E8FF); // Lightest blue

  // Status colors
  static const Color warningColor = Color(0xFFFF6B35);
  static const Color successColor = Color(0xFF00FF88);
  static const Color errorColor = Color(0xFFFF3333);

  // Text colors
  static const Color textPrimary = Color(
    0xFFC1E8FF,
  ); // Lightest blue for primary text
  static const Color textSecondary = Color(
    0xFF7DA0CA,
  ); // Light blue for secondary text
  static const Color textMuted = Color(
    0xFF5483B3,
  ); // Medium blue for muted text

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [darkBlue, mediumBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [darkestBlue, darkBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [mediumBlue, lightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
