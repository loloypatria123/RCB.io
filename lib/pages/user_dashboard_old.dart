import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

const Color _cardBg = Color(0xFF131820);
const Color _accentPrimary = Color(0xFF00D9FF);
const Color _accentSecondary = Color(0xFF1E90FF);
const Color _warningColor = Color(0xFFFF6B35);
const Color _successColor = Color(0xFF00FF88);
const Color _errorColor = Color(0xFFFF3333);
const Color _textPrimary = Color(0xFFE8E8E8);
const Color _textSecondary = Color(0xFF8A8A8A);

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentPage = 0;

  final List<UserPage> _pages = [
    UserPage(icon: Icons.home, label: 'Dashboard'),
    UserPage(icon: Icons.smart_toy, label: 'Robot Control'),
    UserPage(icon: Icons.monitor_heart, label: 'Live Monitoring'),
    UserPage(icon: Icons.history, label: 'History'),
    UserPage(icon: Icons.bug_report, label: 'Report Issue'),
    UserPage(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserAccess();
    });
  }

  void _checkUserAccess() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAdmin) {
      Navigator.of(context).pushReplacementNamed('/admin-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAdmin) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/admin-dashboard');
            });
            return const Center(
              child: CircularProgressIndicator(color: _accentPrimary),
            );
          }

          return Column(
            children: [
              _buildTopBar(authProvider),
              Expanded(child: _buildPageContent()),
              _buildBottomNavigation(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(
          bottom: BorderSide(color: _accentPrimary.withOpacity(0.2)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RoboClean',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  authProvider.userModel?.name ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.notifications, color: _accentPrimary),
                  onSelected: (value) {
                    if (value == 'view_all') {
                      _showNotificationsDialog();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'view_all',
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Notifications & Alerts',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildNotificationCard(
                              'Cleaning Completed',
                              'ROBOT-001 finished cleaning Classroom A',
                              'Just now',
                              _successColor,
                              Icons.check_circle,
                            ),
                            const SizedBox(height: 10),
                            _buildNotificationCard(
                              'Trash Container Full',
                              'ROBOT-002 trash at 95% capacity',
                              '15 min ago',
                              _warningColor,
                              Icons.delete_sweep,
                            ),
                            const SizedBox(height: 10),
                            _buildNotificationCard(
                              'Robot is Stuck',
                              'ROBOT-001 detected stuck on carpet in Hallway',
                              '1 hour ago',
                              _errorColor,
                              Icons.warning,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showNotificationsDialog();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentPrimary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  'View All Notifications',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: _errorColor),
                  onPressed: () => _logout(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_currentPage) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return _buildRobotControlPage();
      case 2:
        return _buildLiveMonitoringPage();
      case 3:
        return _buildCleaningHistoryPage();
      case 4:
        return _buildIssueReportingPage();
      case 5:
        return _buildProfilePage();
      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildCurrentRobotStatusCard(),
          const SizedBox(height: 20),
          _buildRobotMetricsGrid(),
          const SizedBox(height: 20),
          _buildConnectivityStatusCard(),
          const SizedBox(height: 20),
          _buildQuickActionsGrid(),
          const SizedBox(height: 20),
          _buildLatestNotificationsCard(),
          const SizedBox(height: 20),
          _buildNextScheduledCleaningCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accentPrimary, _accentSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your cleaning robots are ready to work',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRobotStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _accentPrimary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                    'ROBOT-001',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Classroom A',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _successColor, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CLEANING',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _successColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusIndicator('Idle', Icons.pause, _textSecondary),
                _buildStatusIndicator(
                  'Cleaning',
                  Icons.cleaning_services,
                  _successColor,
                ),
                _buildStatusIndicator('Returning', Icons.home, _accentPrimary),
                _buildStatusIndicator('Error', Icons.error, _errorColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 8,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRobotMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildMetricCard('Battery', '85%', _successColor, Icons.battery_full),
        _buildMetricCard('Trash Level', '45%', _warningColor, Icons.delete),
        _buildMetricCard('Water Tank', '92%', _successColor, Icons.water_drop),
        _buildMetricCard('Uptime', '98%', _successColor, Icons.timer),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: double.parse(value.replaceAll('%', '')) / 100,
              minHeight: 4,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connectivity Status',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildConnectivityItem(
            'WiFi',
            'Connected - 5GHz',
            _successColor,
            Icons.wifi,
          ),
          const SizedBox(height: 10),
          _buildConnectivityItem(
            'Bluetooth',
            'Connected',
            _successColor,
            Icons.bluetooth,
          ),
          const SizedBox(height: 10),
          _buildConnectivityItem(
            'GPS',
            'Active',
            _successColor,
            Icons.location_on,
          ),
          const SizedBox(height: 10),
          _buildConnectivityItem(
            'Cloud Sync',
            'Last sync 2 min ago',
            _accentPrimary,
            Icons.cloud_done,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityItem(
    String name,
    String status,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
              ),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildActionTile(
          'Start Cleaning',
          Icons.play_circle,
          _successColor,
          () {},
        ),
        _buildActionTile('Pause', Icons.pause_circle, _warningColor, () {}),
        _buildActionTile('Stop', Icons.stop_circle, _errorColor, () {}),
        _buildActionTile('Return Home', Icons.home, _accentPrimary, () {}),
      ],
    );
  }

  Widget _buildActionTile(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRobotControlPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Robot Control',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Manage your cleaning robots with precision',
            style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
          ),
          const SizedBox(height: 20),
          _buildRobotControlCard(
            'ROBOT-001',
            'Classroom A',
            _successColor,
            true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRobotControlCard(
    String name,
    String location,
    Color statusColor,
    bool isOnline,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Robot Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Control Buttons
          if (isOnline) ...[
            _buildControlButtonsRow(),
            const SizedBox(height: 12),
            _buildSecondaryControlButtonsRow(),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _errorColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: _errorColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Robot is offline. Cannot send commands.',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButtonsRow() {
    return Column(
      children: [
        Text(
          'Primary Controls',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPrimaryControlButton(
                'Start',
                Icons.play_circle_fill,
                _successColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPrimaryControlButton(
                'Pause',
                Icons.pause_circle_filled,
                _warningColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPrimaryControlButton(
                'Stop',
                Icons.stop_circle,
                _errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryControlButtonsRow() {
    return Column(
      children: [
        Text(
          'Secondary Controls',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryControlButton(
                'Resume',
                Icons.play_arrow,
                _accentPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSecondaryControlButton(
                'Return',
                Icons.home,
                _accentSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryControlButton(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showControlConfirmation(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryControlButton(
    String label,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => _showControlConfirmation(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
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
    );
  }

  void _showControlConfirmation(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          '$action Robot',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Are you sure you want to $action the robot?',
          style: GoogleFonts.poppins(color: _textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Robot $action command sent',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _successColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMonitoringPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Monitoring',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Real-time robot tracking and alerts',
            style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
          ),
          const SizedBox(height: 20),
          _buildLiveCameraCard(),
          const SizedBox(height: 20),
          _buildCleaningProgressCard(),
          const SizedBox(height: 20),
          _buildPathStatusCard(),
          const SizedBox(height: 20),
          _buildLiveAlertsCard(),
          const SizedBox(height: 20),
          _buildRealtimeMetricsCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLiveCameraCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _accentPrimary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, color: _accentPrimary, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Live Camera Feed',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ROBOT-001 • Classroom A',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _successColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _successColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _successColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: _successColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleaningProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                'Cleaning Progress',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Text(
                '68%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _accentPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.68,
              minHeight: 12,
              backgroundColor: _accentPrimary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(_accentPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressMetric('Area Cleaned', '245 m²', _successColor),
              _buildProgressMetric('Time Elapsed', '32 min', _accentPrimary),
              _buildProgressMetric('Est. Remaining', '15 min', _warningColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildPathStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Path Status',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildPathStep('Classroom', Icons.location_on, _successColor, true),
          _buildPathConnector(),
          _buildPathStep('Door', Icons.door_front_door, _successColor, true),
          _buildPathConnector(),
          _buildPathStep(
            'Hallway',
            Icons.directions_walk,
            _accentPrimary,
            false,
          ),
          _buildPathConnector(),
          _buildPathStep('Trash Bin', Icons.delete, _textSecondary, false),
        ],
      ),
    );
  }

  Widget _buildPathStep(
    String name,
    IconData icon,
    Color color,
    bool completed,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, color: color, size: 20),
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
              const SizedBox(height: 2),
              Text(
                completed ? 'Completed' : 'Pending',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: completed ? _successColor : _textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (completed)
          Icon(Icons.check_circle, color: _successColor, size: 20)
        else
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: _textSecondary, width: 2),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildPathConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
      child: Container(
        width: 2,
        height: 20,
        color: _accentPrimary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLiveAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _warningColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: _warningColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Live Alerts',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            'Trash Full',
            'Trash container at 95% capacity',
            _warningColor,
            Icons.delete_sweep,
          ),
          const SizedBox(height: 10),
          _buildAlertItem(
            'Stuck Detection',
            'Robot may be stuck on carpet',
            _errorColor,
            Icons.warning,
          ),
          const SizedBox(height: 10),
          _buildAlertItem(
            'Low Battery',
            'Battery at 25%, returning to base',
            _errorColor,
            Icons.battery_alert,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    String title,
    String message,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Metrics',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricRow('GPS Location', 'Classroom A - 12:45 PM'),
          const SizedBox(height: 10),
          _buildMetricRow('Speed', '0.5 m/s'),
          const SizedBox(height: 10),
          _buildMetricRow('Coverage', '245 m²'),
          const SizedBox(height: 10),
          _buildMetricRow('Battery', '45%'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: _accentPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
    String title,
    String message,
    String time,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notification marked as read',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: _successColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'Mark as read',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notification dismissed',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: _textSecondary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'Dismiss',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: _textSecondary,
                          fontWeight: FontWeight.w600,
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

  Widget _buildCleaningHistoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cleaning History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'View past cleaning sessions and disposal logs',
            style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
          ),
          const SizedBox(height: 20),
          // Statistics Cards
          _buildHistoryStatsCards(),
          const SizedBox(height: 20),
          // Filter Tabs
          _buildHistoryFilterTabs(),
          const SizedBox(height: 16),
          // Cleaning Sessions
          Text(
            'Cleaning Sessions',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _buildCleaningSessionCard(
            'Classroom A',
            '45 min',
            '245 m²',
            'ROBOT-001',
            '2025-11-26',
            'Completed',
          ),
          const SizedBox(height: 10),
          _buildCleaningSessionCard(
            'Library',
            '60 min',
            '320 m²',
            'ROBOT-001',
            '2025-11-24',
            'Completed',
          ),
          const SizedBox(height: 10),
          _buildCleaningSessionCard(
            'Hallway',
            '35 min',
            '200 m²',
            'ROBOT-001',
            '2025-11-23',
            'Completed',
          ),
          const SizedBox(height: 20),
          // Disposal Logs
          Text(
            'Disposal Logs',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _buildDisposalLogCard(
            'ROBOT-001',
            'Trash Disposed',
            '2.5 kg',
            '2025-11-26 14:30',
          ),
          const SizedBox(height: 10),
          _buildDisposalLogCard(
            'ROBOT-001',
            'Trash Disposed',
            '3.2 kg',
            '2025-11-24 15:20',
          ),
          const SizedBox(height: 10),
          _buildDisposalLogCard(
            'ROBOT-001',
            'Trash Disposed',
            '2.8 kg',
            '2025-11-23 13:15',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHistoryStatsCards() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildStatCard('Total Cycles', '127', _accentPrimary, Icons.repeat),
        _buildStatCard(
          'Total Duration',
          '89 hrs',
          _successColor,
          Icons.schedule,
        ),
        _buildStatCard(
          'Area Cleaned',
          '12.5 km²',
          _accentSecondary,
          Icons.square_foot,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: _textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildHistoryFilterTab('Daily', true),
          const SizedBox(width: 8),
          _buildHistoryFilterTab('Weekly', false),
          const SizedBox(width: 8),
          _buildHistoryFilterTab('Monthly', false),
        ],
      ),
    );
  }

  Widget _buildHistoryFilterTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? _accentPrimary.withOpacity(0.2) : _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? _accentPrimary : _textSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? _accentPrimary : _textSecondary,
        ),
      ),
    );
  }

  Widget _buildCleaningSessionCard(
    String location,
    String duration,
    String area,
    String robot,
    String date,
    String status,
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
                    location,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    robot,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _successColor, width: 0.5),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSessionMetric('Duration', duration, Icons.schedule),
              _buildSessionMetric('Area', area, Icons.square_foot),
              _buildSessionMetric('Date', date, Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _accentPrimary, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 8, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildDisposalLogCard(
    String robot,
    String action,
    String weight,
    String timestamp,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _warningColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _warningColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _warningColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(Icons.delete_sweep, color: _warningColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      action,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      weight,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _warningColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      robot,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _textSecondary,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: _textSecondary,
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

  Widget _buildIssueReportingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Issue',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Help us improve by reporting any issues you encounter',
            style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
          ),
          const SizedBox(height: 24),
          // Issue Categories
          Text(
            'Issue Category',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildReportCategoryCard(
            'Robot Stuck',
            'Robot is stuck or unable to move',
            Icons.block,
            _errorColor,
          ),
          const SizedBox(height: 10),
          _buildReportCategoryCard(
            'Navigation Problem',
            'Robot navigation or path issues',
            Icons.map,
            _warningColor,
          ),
          const SizedBox(height: 10),
          _buildReportCategoryCard(
            'Error During Cleaning',
            'Issues during cleaning operation',
            Icons.error,
            _errorColor,
          ),
          const SizedBox(height: 10),
          _buildReportCategoryCard(
            'App Issue',
            'Application or UI problems',
            Icons.bug_report,
            _warningColor,
          ),
          const SizedBox(height: 10),
          _buildReportCategoryCard(
            'Overall Feedback',
            'General feedback or suggestions',
            Icons.feedback,
            _accentSecondary,
          ),
          const SizedBox(height: 24),
          // Quick Report Buttons
          Text(
            'Quick Report',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickReportButton(
            'Robot Not Responding',
            Icons.block,
            _errorColor,
          ),
          const SizedBox(height: 10),
          _buildQuickReportButton('Sensor Error', Icons.warning, _warningColor),
          const SizedBox(height: 10),
          _buildQuickReportButton(
            'Battery Issue',
            Icons.battery_alert,
            _warningColor,
          ),
          const SizedBox(height: 24),
          // Detailed Report Section
          Text(
            'Detailed Report',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailedReportForm(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReportCategoryCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => _showDetailedReportDialog(title),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 22),
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
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: _textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReportButton(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showDetailedReportDialog(label),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: _textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReportForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Your Report',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          // Issue Type Dropdown
          Text(
            'Issue Type',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accentPrimary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select issue type...',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: _accentPrimary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Description Field
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accentPrimary.withOpacity(0.2)),
            ),
            child: TextField(
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 10, color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 10,
                  color: _textSecondary,
                ),
                filled: true,
                fillColor: const Color(0xFF0A0E1A),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Attachment Info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accentPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: _accentPrimary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Include screenshots or logs if possible',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: _accentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Issue submitted successfully! Our team will review it.',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: _successColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Submit Report to Admin',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account & Settings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Manage your profile, preferences, and app settings',
                style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
              ),
              const SizedBox(height: 24),
              // User Profile Section
              Text(
                'User Profile',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildEnhancedProfileCard(authProvider),
              const SizedBox(height: 24),
              // Profile Edit Options
              Text(
                'Profile Settings',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildEditableProfileField(
                'Username',
                authProvider.userModel?.name ?? 'User',
                Icons.person,
              ),
              const SizedBox(height: 10),
              _buildEditableProfileField(
                'Email',
                authProvider.userModel?.email ?? 'N/A',
                Icons.email,
              ),
              const SizedBox(height: 10),
              _buildEditableProfileField('Password', '••••••••', Icons.lock),
              const SizedBox(height: 10),
              _buildUploadProfileImageButton(),
              const SizedBox(height: 24),
              // App Settings Section
              Text(
                'App Settings',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingToggle(
                'Push Notifications',
                true,
                Icons.notifications,
              ),
              const SizedBox(height: 10),
              _buildSettingToggle('Email Alerts', false, Icons.email),
              const SizedBox(height: 10),
              _buildThemeSelector(),
              const SizedBox(height: 24),
              // App Version Section
              Text(
                'App Information',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildAppVersionCard(),
              const SizedBox(height: 24),
              // Help Center Section
              Text(
                'Help & Support',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                'How to start cleaning?',
                'Tap the Start button on the robot control page',
                Icons.play_circle,
              ),
              const SizedBox(height: 10),
              _buildHelpItem(
                'How to check robot status?',
                'Go to Live Monitoring to see real-time data',
                Icons.monitor_heart,
              ),
              const SizedBox(height: 10),
              _buildHelpItem(
                'How to report an issue?',
                'Use the Report Issue page to submit problems',
                Icons.bug_report,
              ),
              const SizedBox(height: 10),
              _buildHelpItem(
                'How to view cleaning history?',
                'Check the History page for past sessions',
                Icons.history,
              ),
              const SizedBox(height: 24),
              // About Section
              Text(
                'About',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildAboutCard(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedProfileCard(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _accentPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _accentPrimary, width: 2),
                      ),
                      child: Icon(
                        Icons.person,
                        color: _accentPrimary,
                        size: 40,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _accentPrimary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _cardBg, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.userModel?.name ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.userModel?.email ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: _accentPrimary.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStatColumn('Member Since', '2025'),
              _buildProfileStatColumn('Account Type', 'Regular'),
              _buildProfileStatColumn('Status', 'Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _accentPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildEditableProfileField(String label, String value, IconData icon) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Edit $label feature coming soon',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: _accentPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentPrimary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _accentPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: _accentPrimary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProfileImageButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile image upload feature coming soon',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: _accentPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentPrimary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.image, color: _accentPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Image',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Upload or change your profile picture',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.upload, color: _accentPrimary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
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
            children: [
              Icon(Icons.palette, color: _accentPrimary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Theme',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Light theme selected',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: _successColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E1A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _textSecondary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.light_mode, color: _textSecondary, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          'Light',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Dark theme selected (current)',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: _successColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _accentPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _accentPrimary, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.dark_mode, color: _accentPrimary, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          'Dark',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _accentPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildAppVersionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _successColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: _successColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'RoboClean App',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVersionRow('Version', '1.0.0'),
          const SizedBox(height: 8),
          _buildVersionRow('Build Number', '2025.11.26'),
          const SizedBox(height: 8),
          _buildVersionRow('Release Date', 'November 26, 2025'),
          const SizedBox(height: 8),
          _buildVersionRow('Developer', 'RoboClean Team'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'You are running the latest version',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: _successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: _textSecondary),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: _textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingToggle(String label, bool value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentPrimary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$label ${value ? 'disabled' : 'enabled'}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _successColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            activeColor: _accentPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentSecondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: _textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _successColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: _successColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'RoboClean App',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAboutRow('Version', '1.0.0'),
          const SizedBox(height: 8),
          _buildAboutRow('Build', '2025.11.26'),
          const SizedBox(height: 8),
          _buildAboutRow('Developer', 'RoboClean Team'),
          const SizedBox(height: 10),
          Text(
            'Professional robot cleaning management system',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: _textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: _textSecondary),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: _textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentPrimary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: _accentPrimary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: List.generate(_pages.length, (index) {
              final isSelected = _currentPage == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentPage = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _accentPrimary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: _accentPrimary.withOpacity(0.4),
                              width: 1,
                            )
                          : null,
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                _accentPrimary.withOpacity(0.1),
                                _accentPrimary.withOpacity(0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Icon Container
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _accentPrimary.withOpacity(0.2)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: _accentPrimary, width: 2)
                                : null,
                          ),
                          child: Icon(
                            _pages[index].icon,
                            color: isSelected ? _accentPrimary : _textSecondary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Label with smooth animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _accentPrimary.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _pages[index].label,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: isSelected
                                  ? _accentPrimary
                                  : _textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              letterSpacing: isSelected ? 0.5 : 0.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showDetailedReportDialog(String issueType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Report: $issueType',
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
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                style: GoogleFonts.poppins(color: _textPrimary, fontSize: 10),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  hintStyle: GoogleFonts.poppins(
                    color: _textSecondary,
                    fontSize: 10,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0A0E1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _accentPrimary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: _accentPrimary, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Include screenshots if possible',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: _accentPrimary,
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
                    'Issue submitted successfully! Our team will review it.',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _successColor,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Submit to Admin',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                'Latest Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => _showNotificationsDialog(),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _accentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationRow(
            'Trash Full',
            'ROBOT-001 trash is at 95%',
            _warningColor,
            '5 min ago',
          ),
          const SizedBox(height: 10),
          _buildNotificationRow(
            'Cleaning Complete',
            'Classroom A cleaning finished',
            _successColor,
            '15 min ago',
          ),
          const SizedBox(height: 10),
          _buildNotificationRow(
            'Low Battery',
            'ROBOT-003 battery at 15%',
            _errorColor,
            '1 hour ago',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationRow(
    String title,
    String message,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
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
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 10, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNextScheduledCleaningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentPrimary.withOpacity(0.15),
            _accentSecondary.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: _accentPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Next Scheduled Cleaning',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E1A),
              borderRadius: BorderRadius.circular(8),
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
                          'Library - Daily Cleaning',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tomorrow at 10:00 AM',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _accentPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _accentPrimary, width: 0.5),
                      ),
                      child: Text(
                        'ROBOT-002',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: _accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                          'Reschedule',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _accentPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: _accentPrimary,
                            fontWeight: FontWeight.w600,
                          ),
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

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardBg,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: _accentPrimary.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications & Alerts',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: _textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Success',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'Cleaning Completed',
                        'ROBOT-001 finished cleaning Classroom A',
                        'Just now',
                        _successColor,
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'Disposal Completed',
                        'Trash disposed successfully at 2:30 PM',
                        '5 min ago',
                        _successColor,
                        Icons.delete_sweep,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Warnings',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'Trash Container Full',
                        'ROBOT-002 trash at 95% capacity',
                        '15 min ago',
                        _warningColor,
                        Icons.delete_sweep,
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'Low Battery',
                        'ROBOT-003 battery at 20%, returning to base',
                        '32 min ago',
                        _warningColor,
                        Icons.battery_alert,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Errors',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'Robot is Stuck',
                        'ROBOT-001 detected stuck on carpet in Hallway',
                        '1 hour ago',
                        _errorColor,
                        Icons.warning,
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'Robot Disconnected',
                        'ROBOT-002 lost connection - last seen 2 hours ago',
                        '2 hours ago',
                        _errorColor,
                        Icons.cloud_off,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Information',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'New Schedule Added',
                        'Daily cleaning scheduled for Library at 10:00 AM',
                        '3 hours ago',
                        _accentPrimary,
                        Icons.schedule,
                      ),
                      const SizedBox(height: 10),
                      _buildNotificationCard(
                        'Admin Announcement',
                        'System maintenance scheduled for tomorrow at 2:00 AM',
                        '5 hours ago',
                        _accentSecondary,
                        Icons.notifications,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure?',
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
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/sign-in');
              }
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: _errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class UserPage {
  final IconData icon;
  final String label;
  UserPage({required this.icon, required this.label});
}
