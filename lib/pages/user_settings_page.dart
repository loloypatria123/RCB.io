import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  // Professional palette aligned with sign-in / sign-up
  static const Color _bgColor = Color(0xFF0A0E27); // Scaffold background
  static const Color _cardBg = Color(0xFF111827); // Card background
  static const Color _accent = Color(0xFF4F46E5); // Indigo accent
  static const Color _accentSecondary = Color(0xFF06B6D4); // Cyan accent
  static const Color _textPrimary = Color(0xFFF9FAFB);
  static const Color _textSecondary = Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: Provider.of<AuthProvider>(context, listen: false),
        child: const _SettingsContent(),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsSectionHeader(
            title: 'Account & Settings',
            subtitle: 'Manage your profile, preferences, and app settings',
          ),
          const SizedBox(height: 16),
          _ProfileHeaderCard(authProvider: authProvider),
          const SizedBox(height: 24),
          // User Profile section
          const _SimpleSectionTitle('User Profile'),
          const SizedBox(height: 12),
          _SettingsTile(
            title: 'View profile information',
            subtitle:
                '${authProvider.userModel?.name ?? 'User'} • ${authProvider.userModel?.email ?? 'N/A'}',
            icon: Icons.person,
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Update username',
            subtitle: 'Change your display name',
            icon: Icons.edit,
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Update email',
            subtitle: 'Change your email address',
            icon: Icons.email,
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Update password',
            subtitle: 'Change your account password',
            icon: Icons.lock,
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Upload profile image',
            subtitle: 'Add or update your profile picture',
            icon: Icons.camera_alt,
          ),
          const SizedBox(height: 28),
          // App Settings section
          const _SimpleSectionTitle('App Settings'),
          const SizedBox(height: 12),
          const _SettingsSwitchTile(
            title: 'Theme (light/dark)',
            subtitle: 'Switch between light and dark mode',
            icon: Icons.brightness_6,
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Language',
            subtitle: 'Choose your preferred language',
            icon: Icons.language,
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'App version info',
            subtitle: 'RoboCleanerBuddy v1.0.0',
            icon: Icons.info,
          ),
          const SizedBox(height: 28),
          // Support / Help Center
          const _SimpleSectionTitle('Support Help Center'),
          const SizedBox(height: 12),
          const _SettingsTile(
            title: 'FAQs',
            subtitle: 'Frequently asked questions',
            icon: Icons.help_center,
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Troubleshooting guide',
            subtitle: 'Solve common problems with the app or robots',
            icon: Icons.build,
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
                gradient: const LinearGradient(
                  colors: [
                    UserSettingsPage._accent,
                    UserSettingsPage._accentSecondary,
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
                color: UserSettingsPage._textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: UserSettingsPage._textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SimpleSectionTitle extends StatelessWidget {
  final String title;

  const _SimpleSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: UserSettingsPage._accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: UserSettingsPage._textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final AuthProvider authProvider;

  const _ProfileHeaderCard({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    final name = authProvider.userModel?.name ?? 'User';
    final email = authProvider.userModel?.email ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UserSettingsPage._cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UserSettingsPage._accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  UserSettingsPage._accent,
                  UserSettingsPage._accentSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: UserSettingsPage._textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: UserSettingsPage._textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UserSettingsPage._cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UserSettingsPage._accent.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: UserSettingsPage._accent.withOpacity(0.14),
            ),
            child: Icon(icon, color: UserSettingsPage._accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: UserSettingsPage._textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: UserSettingsPage._textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: UserSettingsPage._textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UserSettingsPage._cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UserSettingsPage._accent.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: UserSettingsPage._accent.withOpacity(0.14),
            ),
            child: Icon(icon, color: UserSettingsPage._accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: UserSettingsPage._textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: UserSettingsPage._textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (_) {},
            activeColor: UserSettingsPage._accent,
          ),
        ],
      ),
    );
  }
}
