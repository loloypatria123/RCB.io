import 'package:flutter/material.dart';

/// Application color constants
class AppColors {
  // Previous/Original Color Palette (Indigo/Dark Theme)
  static const Color primaryBlue = Color(0xFF4F46E5); // Indigo
  static const Color accentYellow = Color(0xFF06B6D4); // Cyan (mapped from Yellow for compatibility)
  static const Color primaryDarkBlue = Color(0xFF1A1F3A); // Medium Dark
  static const Color primaryLightBlue = Color(0xFF6366F1); // Lighter Indigo
  static const Color neutralDark = Color(0xFF0A0E27); // Darkest Blue (Scaffold)

  // Mapping to existing names for compatibility
  static const Color darkestBlue = neutralDark;
  static const Color darkBlue = primaryBlue;
  static const Color mediumBlue = primaryDarkBlue;
  static const Color lightBlue = primaryLightBlue;
  static const Color lightestBlue = Color(0xFFE0E7FF); // Very light indigo

  // Background colors
  static const Color scaffoldBg = neutralDark;
  static const Color cardBg = Color(0xFF111827); // Card Background
  static const Color surfaceBg = Color(0xFF1F2937);

  // Primary accent colors
  static const Color accentPrimary = primaryBlue;
  static const Color accentSecondary = accentYellow;
  static const Color accentLight = Color(0xFF22D3EE); // Lighter Cyan

  // Status colors
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color errorColor = Color(0xFFEF4444); // Red

  // Text colors
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFFD1D5DB);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textAccent = accentYellow;

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [neutralDark, Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient robotGradient = LinearGradient(
      colors: [primaryBlue, primaryLightBlue, accentYellow],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryBlue, primaryLightBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient accentButtonGradient = LinearGradient(
    colors: [accentYellow, Color(0xFF22D3EE)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
