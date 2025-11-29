import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Professional palette aligned with admin dashboard & user dashboard
const Color _darkBg = Color(0xFF0A0E27);
const Color _cardBg = Color(0xFF111827);
const Color _accentPrimary = Color(0xFF4F46E5); // Indigo
const Color _accentSecondary = Color(0xFF06B6D4); // Cyan
const Color _warningColor = Color(0xFFF59E0B);
const Color _errorColor = Color(0xFFEF4444);
const Color _successColor = Color(0xFF10B981);
const Color _textPrimary = Color(0xFFF9FAFB);
const Color _textSecondary = Color(0xFFD1D5DB);

class AdminRobotManagement extends StatefulWidget {
  const AdminRobotManagement({super.key});

  @override
  State<AdminRobotManagement> createState() => _AdminRobotManagementState();
}

class RobotData {
  final String id, name, status, location, firmware;
  final double battery, motorHealth, sensorHealth;
  final int speed, cleaningMode;

  RobotData({
    required this.id,
    required this.name,
    required this.status,
    required this.location,
    required this.firmware,
    required this.battery,
    required this.motorHealth,
    required this.sensorHealth,
    required this.speed,
    required this.cleaningMode,
  });
}

class _AdminRobotManagementState extends State<AdminRobotManagement> {
  final List<RobotData> robots = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Robot Management',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 24),
          _buildRobotsGrid(),
        ],
      ),
    );
  }

  Widget _buildRobotsGrid() {
    if (robots.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: robots.length,
      itemBuilder: (context, index) {
        return _buildRobotCard(robots[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentPrimary.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Illustration circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_accentPrimary, _accentSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accentPrimary.withOpacity(0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No robots connected yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Once your RoboCleaner units are online, they will appear here with real‑time status, health, and controls.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: Text(
                        'Add Robot',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.menu_book,
                        size: 16,
                        color: _accentSecondary,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _accentSecondary,
                      ),
                      label: Text(
                        'View connection guide',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotCard(RobotData robot) {
    final statusColor = robot.status == 'Online'
        ? _successColor
        : robot.status == 'Charging'
        ? _warningColor
        : _errorColor;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: statusColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        robot.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        robot.id,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor, width: 0.5),
                  ),
                  child: Text(
                    robot.status,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSensorRow('Location', robot.location, _accentPrimary),
                  const SizedBox(height: 12),
                  _buildSensorRow(
                    'Battery',
                    '${robot.battery.toStringAsFixed(0)}%',
                    _successColor,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthBar('Motor Health', robot.motorHealth),
                  const SizedBox(height: 12),
                  _buildHealthBar('Sensor Health', robot.sensorHealth),
                  const SizedBox(height: 12),
                  _buildSensorRow('Speed', '${robot.speed}%', _accentSecondary),
                  const SizedBox(height: 12),
                  _buildSensorRow(
                    'Mode',
                    'Mode ${robot.cleaningMode}',
                    _warningColor,
                  ),
                  const SizedBox(height: 12),
                  _buildSensorRow('Firmware', robot.firmware, _textSecondary),
                  const SizedBox(height: 16),
                  _buildActionButtons(robot),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthBar(String label, double value) {
    final color = value >= 90
        ? _successColor
        : value >= 75
        ? _warningColor
        : _errorColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: _darkBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RobotData robot) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallButton(
                'Calibrate',
                Icons.tune,
                _accentPrimary,
                () => _showCalibrateDialog(robot),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallButton(
                'Settings',
                Icons.settings,
                _accentSecondary,
                () => _showSettingsDialog(robot),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSmallButton(
                'Reset',
                Icons.restart_alt,
                _warningColor,
                () => _showResetDialog(robot),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallButton(
                'Reboot',
                Icons.power_settings_new,
                _errorColor,
                () => _showRebootDialog(robot),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 0.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalibrateDialog(RobotData robot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Arm Calibration & Line Sensor Tuning',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalibrationSection('Arm Calibration', [
                'Calibrate X-axis',
                'Calibrate Y-axis',
                'Calibrate Z-axis',
                'Test arm movement',
              ]),
              const SizedBox(height: 16),
              _buildCalibrationSection('Line Sensor Tuning', [
                'Auto-detect sensitivity',
                'Adjust threshold',
                'Test line detection',
                'Save calibration',
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _successColor, width: 0.5),
                ),
                child: Text(
                  '✓ Calibration Status: Ready',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _successColor,
                    fontWeight: FontWeight.w600,
                  ),
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
                    'Calibration started',
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
              'Start Calibration',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: _successColor),
                const SizedBox(width: 8),
                Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showSettingsDialog(RobotData robot) {
    int speed = robot.speed;
    int mode = robot.cleaningMode;
    int disposalTiming = 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _cardBg,
          title: Text(
            'Robot Settings',
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingSlider('Robot Speed', speed, 20, 100, (value) {
                  setState(() => speed = value.toInt());
                }),
                const SizedBox(height: 16),
                _buildModeSelector('Cleaning Mode', mode, (value) {
                  setState(() => mode = value);
                }),
                const SizedBox(height: 16),
                _buildSettingSlider(
                  'Disposal Timing (sec)',
                  disposalTiming,
                  10,
                  60,
                  (value) {
                    setState(() => disposalTiming = value.toInt());
                  },
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
                      'Settings updated',
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
                'Save Settings',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSlider(
    String label,
    int value,
    int min,
    int max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _accentPrimary, width: 0.5),
              ),
              child: Text(
                '$value',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _accentPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min) ~/ 5,
          activeColor: _accentPrimary,
          inactiveColor: _accentPrimary.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildModeSelector(
    String label,
    int selected,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: _textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildModeButton(
                'Mode 1',
                1,
                selected == 1,
                () => onChanged(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                'Mode 2',
                2,
                selected == 2,
                () => onChanged(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                'Mode 3',
                3,
                selected == 3,
                () => onChanged(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(
    String label,
    int mode,
    bool selected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? _accentPrimary.withOpacity(0.2) : _darkBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? _accentPrimary
                  : _accentPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: selected ? _accentPrimary : _textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(RobotData robot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Reset Robot Connection',
          style: GoogleFonts.poppins(
            color: _warningColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Reset connection for ${robot.name}? The robot will restart.',
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
                    'Connection reset initiated',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _warningColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _warningColor),
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRebootDialog(RobotData robot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Reboot Robot System',
          style: GoogleFonts.poppins(
            color: _errorColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Reboot ${robot.name}? This will stop all current operations.',
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
                    'Robot rebooting...',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _errorColor),
            child: Text(
              'Reboot',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
