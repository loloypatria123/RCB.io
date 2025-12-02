import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';

// Color constants for settings page
class _SettingsColors {
  static const Color bgColor = Color(0xFF0A0E27); // Scaffold background
  static const Color cardBg = Color(0xFF111827); // Card background
  static const Color primaryMedium = Color(0xFF1A1F3A);
  static const Color accent = Color(0xFF4F46E5); // Indigo accent
  static const Color accentSecondary = Color(0xFF06B6D4); // Cyan accent
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFFD1D5DB);
}

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  String _localizedText(BuildContext context, String key) {
    final ui = Provider.of<UIProvider>(context, listen: false);
    final lang = ui.selectedLanguage.toLowerCase();

    // Fallback to English
    String t(Map<String, String> values) =>
        lang.contains('filipino') || lang.contains('tagalog')
        ? values['fil'] ?? values['en']!
        : lang.contains('cebuano') || lang.contains('bisaya')
        ? values['ceb'] ?? values['en']!
        : values['en']!;

    switch (key) {
      case 'settings_title':
        return t({
          'en': 'Settings',
          'fil': 'Mga Setting',
          'ceb': 'Mga Setting',
        });
      case 'account_settings_title':
        return t({
          'en': 'Account & Settings',
          'fil': 'Account at Mga Setting',
          'ceb': 'Account ug Mga Setting',
        });
      case 'account_settings_subtitle':
        return t({
          'en': 'Manage your profile, preferences, and app settings',
          'fil': 'I-manage ang iyong profile, preference, at app settings',
          'ceb': 'I-manage ang imong profile, paborito, ug app settings',
        });
      case 'user_profile_section_title':
        return t({
          'en': 'User Profile',
          'fil': 'Profile ng User',
          'ceb': 'Profile sa Gumagamit',
        });
      case 'view_profile_title':
        return t({
          'en': 'View profile information',
          'fil': 'Tingnan ang impormasyon ng profile',
          'ceb': 'Tan-awa ang impormasyon sa profile',
        });
      case 'app_settings_section_title':
        return t({
          'en': 'App Settings',
          'fil': 'Mga App Setting',
          'ceb': 'Mga App Setting',
        });
      case 'theme_title':
        return t({
          'en': 'Theme (light/dark)',
          'fil': 'Tema (liwanag/dilim)',
          'ceb': 'Tema (hayag/ngitngit)',
        });
      case 'theme_subtitle':
        return t({
          'en': 'Switch between light and dark mode',
          'fil': 'Lumipat sa liwanag o madilim na mode',
          'ceb': 'Ibalhin sa hayag o ngitngit nga mode',
        });
      case 'language_title':
        return t({'en': 'Language', 'fil': 'Wika', 'ceb': 'Pinulongan'});
      case 'language_set_message':
        return t({
          'en': 'Language set to {lang}',
          'fil': 'Naitakda ang wika sa {lang}',
          'ceb': 'Na-set ang pinulongan sa {lang}',
        });
      case 'support_section_title':
        return t({
          'en': 'Support Help Center',
          'fil': 'Support / Help Center',
          'ceb': 'Support / Help Center',
        });
      case 'faqs_title':
        return t({'en': 'FAQs', 'fil': 'FAQs', 'ceb': 'FAQs'});
      case 'faqs_subtitle':
        return t({
          'en': 'Frequently asked questions',
          'fil': 'Mga madalas itanong',
          'ceb': 'Kanunay pangutab-on nga mga pangutana',
        });
      case 'troubleshooting_title':
        return t({
          'en': 'Troubleshooting guide',
          'fil': 'Troubleshooting guide',
          'ceb': 'Troubleshooting guide',
        });
      case 'troubleshooting_subtitle':
        return t({
          'en': 'Solve common problems with the app or robots',
          'fil': 'Ayusin ang karaniwang problema sa app o mga robot',
          'ceb': 'Solbara ang kasagarang problema sa app o sa mga robot',
        });
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SettingsColors.bgColor,
      appBar: AppBar(
        backgroundColor: _SettingsColors.cardBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _localizedText(context, 'settings_title'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _SettingsColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _SettingsColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: Provider.of<AuthProvider>(context, listen: false),
        child: _SettingsContent(
          pulseAnimation: _pulseAnimation,
          rotationAnimation: _rotationAnimation,
          localizedText: _localizedText,
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final Animation<double> rotationAnimation;
  final String Function(BuildContext, String) localizedText;

  const _SettingsContent({
    required this.pulseAnimation,
    required this.rotationAnimation,
    required this.localizedText,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final uiProvider = context.watch<UIProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _SettingsSectionHeader(
            title: localizedText(context, 'account_settings_title'),
            subtitle: localizedText(context, 'account_settings_subtitle'),
          ),
          const SizedBox(height: 20),
          
          // Animated Profile Header Card
          _ProfileHeaderCard(
            authProvider: authProvider,
            pulseAnimation: pulseAnimation,
            rotationAnimation: rotationAnimation,
          ),
          const SizedBox(height: 24),
          
          // User Profile section
          _AnimatedSectionTitle(
            localizedText(context, 'user_profile_section_title'),
            Icons.person,
            _SettingsColors.accent,
            pulseAnimation,
          ),
          const SizedBox(height: 12),
          
          _AnimatedSettingsTile(
            title: localizedText(context, 'view_profile_title'),
            subtitle:
                '${authProvider.userModel?.name ?? 'User'} • ${authProvider.userModel?.email ?? 'N/A'}',
            icon: Icons.account_circle,
            color: _SettingsColors.accent,
            pulseAnimation: pulseAnimation,
          ),
          const SizedBox(height: 12),
          _AnimatedSettingsTile(
            title: 'Update username',
            subtitle: 'Change your display name',
            icon: Icons.edit,
            color: _SettingsColors.accentSecondary,
            pulseAnimation: pulseAnimation,
          ),
          const SizedBox(height: 12),
          _AnimatedSettingsTile(
            title: 'Update email',
            subtitle: 'Change your email address',
            icon: Icons.email,
            color: _SettingsColors.accent,
            pulseAnimation: pulseAnimation,
          ),
          const SizedBox(height: 12),
          _AnimatedSettingsTile(
            title: 'Update password',
            subtitle: 'Change your account password',
            icon: Icons.lock,
            color: _SettingsColors.warningColor,
            pulseAnimation: pulseAnimation,
          ),
          const SizedBox(height: 12),
          _AnimatedSettingsTile(
            title: 'Upload profile image',
            subtitle: 'Add or update your profile picture',
            icon: Icons.camera_alt,
            color: _SettingsColors.successColor,
            pulseAnimation: pulseAnimation,
          ),
          const SizedBox(height: 28),
          
          // App Settings section
          _AnimatedSectionTitle(
            localizedText(context, 'app_settings_section_title'),
            Icons.settings,
            _SettingsColors.accentSecondary,
            pulseAnimation,
          ),
          const SizedBox(height: 12),
          
          _AnimatedSettingsSwitchTile(
            title: localizedText(context, 'theme_title'),
            subtitle: localizedText(context, 'theme_subtitle'),
            icon: Icons.brightness_6,
            value: uiProvider.isDarkMode,
            pulseAnimation: pulseAnimation,
            onChanged: (value) {
              uiProvider.setDarkMode(value);
            },
          ),
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: () async {
              final selected = await _showLanguageDialog(
                context,
                initial: uiProvider.selectedLanguage,
              );
              if (selected != null && selected.isNotEmpty) {
                uiProvider.setSelectedLanguage(selected);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizedText(context, 'language_set_message')
                            .replaceFirst('{lang}', selected),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: _SettingsColors.successColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: _AnimatedSettingsTile(
              title: localizedText(context, 'language_title'),
              subtitle: uiProvider.selectedLanguage,
              icon: Icons.language,
              color: _SettingsColors.accent,
              pulseAnimation: pulseAnimation,
            ),
          ),
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: () {
              _showVersionDialog(context);
            },
            child: _AnimatedSettingsTile(
              title: 'App version info',
              subtitle: 'RoboCleanerBuddy v1.0.0',
              icon: Icons.info,
              color: _SettingsColors.accentSecondary,
              pulseAnimation: pulseAnimation,
            ),
          ),
          const SizedBox(height: 28),
          
          // Support / Help Center
          _AnimatedSectionTitle(
            localizedText(context, 'support_section_title'),
            Icons.support_agent,
            _SettingsColors.successColor,
            pulseAnimation,
          ),
          const SizedBox(height: 12),
          
          _AnimatedSettingsTile(
            title: localizedText(context, 'faqs_title'),
            subtitle: localizedText(context, 'faqs_subtitle'),
            icon: Icons.help_center,
            color: _SettingsColors.successColor,
            pulseAnimation: pulseAnimation,
          ),
          const SizedBox(height: 12),
          _AnimatedSettingsTile(
            title: localizedText(context, 'troubleshooting_title'),
            subtitle: localizedText(context, 'troubleshooting_subtitle'),
            icon: Icons.build_circle,
            color: _SettingsColors.warningColor,
            pulseAnimation: pulseAnimation,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SettingsSectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    _SettingsColors.accent,
                    _SettingsColors.accentSecondary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _SettingsColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: _SettingsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AnimatedSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Animation<double> pulseAnimation;

  const _AnimatedSectionTitle(
    this.title,
    this.icon,
    this.color,
    this.pulseAnimation,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _SettingsColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedSettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Animation<double> pulseAnimation;

  const _AnimatedSettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _SettingsColors.cardBg,
            color.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _SettingsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _SettingsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: color,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _AnimatedSettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Animation<double> pulseAnimation;
  final ValueChanged<bool> onChanged;

  const _AnimatedSettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.pulseAnimation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = value
        ? _SettingsColors.successColor
        : _SettingsColors.textSecondary;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _SettingsColors.cardBg,
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: value ? pulseAnimation.value : 1.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: value
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _SettingsColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _SettingsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: _SettingsColors.successColor,
                activeTrackColor: _SettingsColors.successColor.withOpacity(0.5),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final AuthProvider authProvider;
  final Animation<double> pulseAnimation;
  final Animation<double> rotationAnimation;

  const _ProfileHeaderCard({
    required this.authProvider,
    required this.pulseAnimation,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final name = authProvider.userModel?.name ?? 'User';
    final email = authProvider.userModel?.email ?? 'N/A';

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _SettingsColors.cardBg,
                _SettingsColors.accent.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _SettingsColors.accent.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _SettingsColors.accent.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Animated Avatar
              AnimatedBuilder(
                animation: rotationAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating ring
                      Transform.rotate(
                        angle: rotationAnimation.value * 6.28319,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _SettingsColors.accentSecondary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            children: List.generate(8, (index) {
                              return Transform.rotate(
                                angle: (index * 0.785398),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _SettingsColors.accentSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      // Avatar
                      Transform.scale(
                        scale: pulseAnimation.value,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                _SettingsColors.accent,
                                _SettingsColors.accentSecondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _SettingsColors.accent.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          _SettingsColors.textPrimary,
                          _SettingsColors.accentSecondary,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 14,
                          color: _SettingsColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _SettingsColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _SettingsColors.successColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _SettingsColors.successColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: pulseAnimation.value,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: _SettingsColors.successColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Active User',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _SettingsColors.successColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


Future<String?> _showLanguageDialog(
  BuildContext context, {
  required String initial,
}) async {
  const languages = [
    {'name': 'English', 'icon': '🇺🇸'},
    {'name': 'Filipino', 'icon': '🇵🇭'},
    {'name': 'Cebuano', 'icon': '🇵🇭'},
  ];

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: _SettingsColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _SettingsColors.accent.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _SettingsColors.accent,
                    _SettingsColors.accentSecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Select Language',
              style: GoogleFonts.poppins(
                color: _SettingsColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final isSelected = lang['name'] == initial;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => Navigator.of(ctx).pop(lang['name']),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              _SettingsColors.accent.withOpacity(0.2),
                              _SettingsColors.accentSecondary.withOpacity(0.1),
                            ],
                          )
                        : null,
                    color: isSelected ? null : _SettingsColors.primaryMedium,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _SettingsColors.accent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lang['name']!,
                          style: GoogleFonts.poppins(
                            color: _SettingsColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _SettingsColors.successColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}

void _showVersionDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: _SettingsColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _SettingsColors.accentSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _SettingsColors.accentSecondary,
                    _SettingsColors.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'App Version Info',
              style: GoogleFonts.poppins(
                color: _SettingsColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _SettingsColors.primaryMedium,
                _SettingsColors.accentSecondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _SettingsColors.accentSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVersionInfoRow(Icons.apps, 'App Name', 'RoboCleanerBuddy'),
              const SizedBox(height: 12),
              _buildVersionInfoRow(Icons.tag, 'Version', 'v1.0.0'),
              const SizedBox(height: 12),
              _buildVersionInfoRow(Icons.build, 'Build', '2025.11.29'),
              const SizedBox(height: 12),
              _buildVersionInfoRow(Icons.code, 'Platform', 'Flutter'),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _SettingsColors.accentSecondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildVersionInfoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, color: _SettingsColors.accentSecondary, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: _SettingsColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(
          color: _SettingsColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
