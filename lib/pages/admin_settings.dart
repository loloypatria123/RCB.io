import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _cardBg = Color(0xFF131820);
const Color _accentPrimary = Color(0xFF00D9FF);
const Color _accentSecondary = Color(0xFF1E90FF);
const Color _warningColor = Color(0xFFFF6B35);
const Color _successColor = Color(0xFF00FF88);
const Color _errorColor = Color(0xFFFF3333);
const Color _textPrimary = Color(0xFFE8E8E8);
const Color _textSecondary = Color(0xFF8A8A8A);

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  bool _darkMode = true;
  String _apiEndpoint = 'https://api.robocleaner.com/v1';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Settings',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 24),
          _buildAdminProfileSection(),
          const SizedBox(height: 24),
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          _buildSchoolInfoSection(),
          const SizedBox(height: 24),
          _buildAPISection(),
          const SizedBox(height: 24),
          _buildDataManagementSection(),
          const SizedBox(height: 24),
          _buildSystemInfoSection(),
        ],
      ),
    );
  }

  Widget _buildAdminProfileSection() {
    return _buildSettingsCard(
      title: 'Admin Profile',
      icon: Icons.admin_panel_settings,
      color: _accentPrimary,
      children: [
        _buildSettingItem(
          'Admin Email',
          'admin@gmail.com',
          Icons.email,
          onTap: () => _showEditProfileDialog(),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          'Admin Name',
          'Administrator',
          Icons.person,
          onTap: () => _showEditProfileDialog(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showChangePasswordDialog(),
          icon: const Icon(Icons.lock),
          label: Text(
            'Change Password',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _warningColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSettingsCard(
      title: 'Appearance',
      icon: Icons.palette,
      color: _accentSecondary,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Currently: ${_darkMode ? 'Enabled' : 'Disabled'}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            Switch(
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
              activeColor: _accentPrimary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _accentPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _accentPrimary, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: _accentPrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Theme changes apply to all users on next login',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolInfoSection() {
    return _buildSettingsCard(
      title: 'School/Classroom Information',
      icon: Icons.school,
      color: _successColor,
      children: [
        _buildSettingItem(
          'School Name',
          'ABC International School',
          Icons.location_city,
          onTap: () => _showEditSchoolDialog(),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          'Location',
          'New York, USA',
          Icons.location_on,
          onTap: () => _showEditSchoolDialog(),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          'Contact Email',
          'contact@abcschool.edu',
          Icons.email,
          onTap: () => _showEditSchoolDialog(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showEditSchoolDialog(),
          icon: const Icon(Icons.edit),
          label: Text(
            'Edit Information',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _successColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAPISection() {
    return _buildSettingsCard(
      title: 'API Configuration',
      icon: Icons.api,
      color: _accentSecondary,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Endpoint',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _accentSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _apiEndpoint,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: _accentSecondary, size: 18),
                    onPressed: () => _showEditAPIDialog(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _successColor, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: _successColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'API connection: Active',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _successColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSettingsCard(
      title: 'Data Management',
      icon: Icons.storage,
      color: _warningColor,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showBackupDialog(),
                icon: const Icon(Icons.backup),
                label: Text(
                  'Backup Data',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showRestoreDialog(),
                icon: const Icon(Icons.restore),
                label: Text(
                  'Restore Data',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showClearCacheDialog(),
          icon: const Icon(Icons.delete_sweep),
          label: Text(
            'Clear System Cache',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _errorColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _warningColor, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: _warningColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Last backup: 2 hours ago',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _warningColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfoSection() {
    return _buildSettingsCard(
      title: 'System Information',
      icon: Icons.info,
      color: _textSecondary,
      children: [
        _buildInfoRow('App Version', 'v2.1.5'),
        const SizedBox(height: 12),
        _buildInfoRow('Build Number', '2025.11.26.001'),
        const SizedBox(height: 12),
        _buildInfoRow('Database Version', 'v1.8.2'),
        const SizedBox(height: 12),
        _buildInfoRow('Last Updated', '2025-11-26 12:00:00'),
        const SizedBox(height: 12),
        _buildInfoRow('Total Users', '342'),
        const SizedBox(height: 12),
        _buildInfoRow('Total Robots', '3'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _successColor, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: _successColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'System Status: All systems operational',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _successColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _accentPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _accentPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: _accentPrimary, size: 18),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (onTap != null)
              Icon(Icons.edit, color: _accentPrimary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: _textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _accentPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _accentPrimary, width: 0.5),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: _accentPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Edit Admin Profile',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Admin Name', 'Administrator'),
              const SizedBox(height: 12),
              _buildTextField('Email', 'admin@gmail.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Profile updated',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Current Password', '', obscure: true),
              const SizedBox(height: 12),
              _buildTextField('New Password', '', obscure: true),
              const SizedBox(height: 12),
              _buildTextField('Confirm Password', '', obscure: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password changed successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _warningColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Update',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSchoolDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Edit School Information',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('School Name', 'ABC International School'),
              const SizedBox(height: 12),
              _buildTextField('Location', 'New York, USA'),
              const SizedBox(height: 12),
              _buildTextField('Contact Email', 'contact@abcschool.edu'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'School information updated',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _successColor,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAPIDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Update API Endpoint',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('API Endpoint', _apiEndpoint),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _warningColor, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: _warningColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Changing API endpoint requires system restart',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: _warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'API endpoint updated',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentSecondary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Update',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Backup Data',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Start backup of all system data? This may take a few minutes.',
          style: GoogleFonts.poppins(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Backup completed successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Start Backup',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Restore Data',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Restore system data from backup? Current data will be replaced.',
          style: GoogleFonts.poppins(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data restored successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentSecondary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Restore',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Clear System Cache',
          style: GoogleFonts.poppins(
            color: _errorColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Clear all cached data? This will improve system performance.',
          style: GoogleFonts.poppins(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cache cleared successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Clear Cache',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    String initialValue, {
    bool obscure = false,
  }) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      obscureText: obscure,
      style: GoogleFonts.poppins(color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: _textSecondary),
        filled: true,
        fillColor: Color(0xFF0A0E1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentPrimary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentPrimary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
