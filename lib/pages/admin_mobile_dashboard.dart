import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Professional palette aligned with user dashboard & auth pages
const Color _bgPrimary = Color(0xFF0A0E27);
const Color _cardBg = Color(0xFF111827);

const Color _accentPrimary = Color(0xFF4F46E5); // Indigo
const Color _accentSecondary = Color(0xFF06B6D4); // Cyan

const Color _warningColor = Color(0xFFF59E0B);
const Color _errorColor = Color(0xFFEF4444);
const Color _successColor = Color(0xFF10B981);

const Color _textPrimary = Color(0xFFF9FAFB);
const Color _textSecondary = Color(0xFFD1D5DB);

class AdminMobileDashboard extends StatefulWidget {
  const AdminMobileDashboard({super.key});

  @override
  State<AdminMobileDashboard> createState() => _AdminMobileDashboardState();
}

class _AdminMobileDashboardState extends State<AdminMobileDashboard> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _buildDashboardPage(),
            _buildRobotsPage(),
            _buildUsersPage(),
            _buildReportsPage(),
            _buildSettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Admin Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'System Overview',
            style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 20),

          // Quick Stats
          _buildQuickStatsGrid(),
          const SizedBox(height: 20),

          // Robot Status
          _buildRobotStatusCard(),
          const SizedBox(height: 16),

          // System Metrics
          _buildMetricsCards(),
          const SizedBox(height: 16),

          // Active Alerts
          _buildAlertsSection(),
          const SizedBox(height: 16),

          // Recent Activity
          _buildRecentActivitySection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('Total Robots', '1', _accentPrimary, Icons.smart_toy),
        _buildStatCard('Active Users', '45', _successColor, Icons.people),
        _buildStatCard('Tasks Today', '12', _accentSecondary, Icons.task),
        _buildStatCard(
          'System Health',
          '98%',
          _successColor,
          Icons.health_and_safety,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRobotStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Robot Status',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _successColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _accentPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accentPrimary),
                ),
                child: Icon(Icons.smart_toy, color: _accentPrimary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROBOT-001',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      'Classroom A • Online',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: _successColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: _successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Column(
      children: [
        _buildMetricRow(
          'Battery Level',
          '85%',
          _accentPrimary,
          Icons.battery_full,
        ),
        const SizedBox(height: 10),
        _buildMetricRow(
          'Trash Container',
          '45%',
          _warningColor,
          Icons.delete_sweep,
        ),
        const SizedBox(height: 10),
        _buildMetricRow(
          'Connection',
          'Excellent',
          _successColor,
          Icons.cloud_done,
        ),
      ],
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(color: color, height: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Alerts',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          'Trash Container Full',
          'ROBOT-001 trash at 95%',
          _warningColor,
          Icons.delete_sweep,
        ),
        const SizedBox(height: 8),
        _buildAlertCard(
          'Low Battery',
          'ROBOT-001 battery at 20%',
          _errorColor,
          Icons.battery_alert,
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    String title,
    String message,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildActivityItem(
          'Cleaning Completed',
          'ROBOT-001 finished Classroom A',
          '5 min ago',
          _successColor,
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          'User Login',
          'Admin logged in',
          '15 min ago',
          _accentPrimary,
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          'System Update',
          'Software updated to v1.0.1',
          '1 hour ago',
          _accentSecondary,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _textSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 8, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Robot Management',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage all robots',
            style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 20),
          _buildRobotCard(
            'ROBOT-001',
            'Classroom A',
            'Online',
            85,
            _successColor,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRobotCard(
    String name,
    String location,
    String status,
    int battery,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    location,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Battery',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _textSecondary,
                    ),
                  ),
                  Text(
                    '$battery%',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: battery / 100,
                  minHeight: 6,
                  backgroundColor: _textSecondary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_accentPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Control',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentSecondary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage system users',
            style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 20),
          _buildUserStats(),
          const SizedBox(height: 20),
          _buildUserListItem(
            'John Doe',
            'john@example.com',
            'Active',
            _successColor,
          ),
          const SizedBox(height: 10),
          _buildUserListItem(
            'Jane Smith',
            'jane@example.com',
            'Active',
            _successColor,
          ),
          const SizedBox(height: 10),
          _buildUserListItem(
            'Mike Johnson',
            'mike@example.com',
            'Inactive',
            _textSecondary,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accentPrimary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  '45',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _accentPrimary,
                  ),
                ),
                Text(
                  'Total Users',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _successColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  '42',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _successColor,
                  ),
                ),
                Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserListItem(
    String name,
    String email,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _textSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: _accentPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports & Issues',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View user reports',
            style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 20),
          _buildReportCard(
            'Robot Stuck',
            'ROBOT-001 stuck in Classroom A',
            'Pending',
            _warningColor,
          ),
          const SizedBox(height: 10),
          _buildReportCard(
            'Navigation Error',
            'Path planning failed',
            'Resolved',
            _successColor,
          ),
          const SizedBox(height: 10),
          _buildReportCard(
            'App Crash',
            'User reported app crash',
            'In Progress',
            _accentSecondary,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'System configuration',
            style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 20),
          _buildSettingItem('System Notifications', Icons.notifications, true),
          const SizedBox(height: 10),
          _buildSettingItem('Email Alerts', Icons.email, false),
          const SizedBox(height: 10),
          _buildSettingItem('Dark Mode', Icons.dark_mode, true),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _textSecondary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Version',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0 (Build 2025.11.26)',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, IconData icon, bool value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentPrimary, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Switch(value: value, onChanged: (_) {}, activeColor: _accentPrimary),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: _accentPrimary.withOpacity(0.2))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildNavItem(0, 'Dashboard', Icons.dashboard),
            _buildNavItem(1, 'Robots', Icons.smart_toy),
            _buildNavItem(2, 'Users', Icons.people),
            _buildNavItem(3, 'Reports', Icons.bug_report),
            _buildNavItem(4, 'Settings', Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _accentPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _accentPrimary : _textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: isSelected ? _accentPrimary : _textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
