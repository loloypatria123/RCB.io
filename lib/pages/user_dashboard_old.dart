import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/report_service.dart';
import '../services/schedule_service.dart';
import '../models/notification_model.dart';

// Professional palette aligned with sign-in / sign-up pages
const Color _primaryDark = Color(0xFF0A0E27); // Scaffold background
const Color _primaryMedium = Color(0xFF1A1F3A); // Sub-surfaces / dividers
const Color _cardBg = Color(0xFF111827); // Card background

const Color _accentPrimary = Color(0xFF4F46E5); // Indigo primary accent
const Color _accentSecondary = Color(0xFF06B6D4); // Cyan secondary accent

const Color _warningColor = Color(0xFFF59E0B); // Amber warning
const Color _successColor = Color(0xFF10B981); // Green success
const Color _errorColor = Color(0xFFEF4444); // Red error

const Color _textPrimary = Color(0xFFF9FAFB); // Main text
const Color _textSecondary = Color(0xFFD1D5DB); // Secondary text

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> with TickerProviderStateMixin {
  int _currentPage = 0;

  final List<UserPage> _pages = [
    UserPage(icon: Icons.home, label: 'Dashboard'),
    UserPage(icon: Icons.smart_toy, label: 'Robot Control'),
    UserPage(icon: Icons.monitor_heart, label: 'Live Monitoring'),
    UserPage(icon: Icons.history, label: 'History'),
    UserPage(icon: Icons.event_note, label: 'Admin Scheduling'),
    UserPage(icon: Icons.bug_report, label: 'Report Issue'),
  ];

  // Report issue form state
  final TextEditingController _reportTitleController = TextEditingController();
  final TextEditingController _reportDescriptionController =
      TextEditingController();
  String _selectedReportCategory = 'bug';
  bool _isSubmittingReport = false;

  // Animation controllers for Robot Control
  late AnimationController _robotPulseController;
  late AnimationController _robotRotationController;
  late AnimationController _scanLineController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _robotPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _robotRotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _robotPulseController, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _robotRotationController, curve: Curves.linear),
    );
    
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserAccess();
    });
  }

  Widget _buildNotificationIcon() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Icon(Icons.notifications, color: _accentPrimary);
    }

    return StreamBuilder<List<UserNotification>>(
      stream: ScheduleService.streamUserNotifications(userId, limit: 20),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications
            .where((n) => n.isRead == false)
            .length;

        if (unreadCount == 0) {
          return const Icon(Icons.notifications, color: _accentPrimary);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications, color: _accentPrimary),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _errorColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _reportTitleController.dispose();
    _reportDescriptionController.dispose();
    _robotPulseController.dispose();
    _robotRotationController.dispose();
    _scanLineController.dispose();
    super.dispose();
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
      backgroundColor: _primaryDark,
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
                IconButton(
                  icon: _buildNotificationIcon(),
                  onPressed: () => _showNotificationsDialog(),
                  tooltip: 'Notifications',
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: _accentPrimary),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/UserSettingsPage');
                  },
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
        return _buildAdminSchedulingPage();
      case 5:
        return _buildIssueReportingPage();
      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildAdminSchedulingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Scheduling',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'View and manage cleaning schedules created by admin.',
            style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
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
                  'Upcoming Schedules',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No schedules available yet. Ask an admin to create a schedule.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
            'Welcome',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No dashboard data available yet. Connect to the system to see robot status and activity.',
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
          Text(
            'Robot Status',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryMedium,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No robot status data available.',
                style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
              ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          'No metrics to display yet.',
          style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
        ),
      ),
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
          Center(
            child: Text(
              'No connectivity information available.',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentPrimary.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          'No quick actions configured.',
          style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
        ),
      ),
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
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                    'Robot Control Center',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control and monitor your cleaning robot',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentPrimary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: _accentPrimary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Robot Status Card
          _buildRobotStatusCard(),
          const SizedBox(height: 20),

          // Robot Visualization & Info
          _buildRobotVisualizationCard(),
          const SizedBox(height: 20),

          // Real-time Statistics
          _buildStatisticsGrid(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRobotStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentPrimary.withOpacity(0.15),
            _accentSecondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accentPrimary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Robot Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _successColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _successColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.precision_manufacturing,
                    color: _successColor,
                    size: 36,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // Robot Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [_textPrimary, _accentSecondary],
                  ).createShader(bounds),
                  child: Text(
                    'CleanBot Pro X1',
            style: GoogleFonts.poppins(
              fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: RB-2024-001 • Main Building',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildAnimatedStatusBadge(
                      'ACTIVE',
                      _successColor,
                      Icons.circle,
                    ),
                    const SizedBox(width: 8),
                    _buildAnimatedStatusBadge(
                      'AUTO MODE',
                      _accentSecondary,
                      Icons.auto_mode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Animated Battery Indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.battery_charging_full,
                        color: _successColor,
                        size: 36,
                      ),
                      Positioned(
                        bottom: 6,
                        child: Container(
                          width: 20,
                          height: (_pulseAnimation.value - 0.95) * 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _successColor.withOpacity(0.8),
                                _successColor.withOpacity(0.3),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '87%',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _successColor,
                    ),
                  ),
                  Text(
                    'Battery',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatusBadge(String label, Color color, IconData icon) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(icon, color: color, size: 10),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRobotVisualizationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryMedium,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Robot Tracking',
                style: GoogleFonts.poppins(
                  fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _successColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _successColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _successColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
          Text(
                      'ACTIVE',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: _successColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Animated Robot Visual
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: _primaryMedium,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accentPrimary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated grid pattern background
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(double.infinity, 240),
                        painter: _AnimatedGridPainter(_scanAnimation.value),
                      );
                    },
                  ),
                  
                  // Scanning line effect
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanAnimation.value * 240,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _accentSecondary.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _accentSecondary.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Animated robot with pulse and rotation
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Robot body with rotating rings
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer rotating ring
                                Transform.rotate(
                                  angle: _rotationAnimation.value * 6.28319,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _accentPrimary.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      children: List.generate(8, (index) {
                                        return Transform.rotate(
                                          angle: (index * 0.785398),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: _accentPrimary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                
                                // Inner counter-rotating ring
                                Transform.rotate(
                                  angle: -_rotationAnimation.value * 3.14159,
                                  child: Container(
                                    width: 95,
                                    height: 95,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _accentSecondary.withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      children: List.generate(6, (index) {
                                        return Transform.rotate(
                                          angle: (index * 1.0472),
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              width: 3,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: _accentSecondary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                
                                // Robot core
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        _accentPrimary,
                                        _accentSecondary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _accentPrimary.withOpacity(0.6),
                                        blurRadius: 30,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.precision_manufacturing,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Animated status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _successColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _successColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _successColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.cleaning_services,
                                    size: 14,
                                    color: _successColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Zone A-3 • Cleaning',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: _textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Corner radar indicators - Top Left
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 12,
                        left: 12,
                        child: Opacity(
                          opacity: 0.3 + (_pulseAnimation.value - 0.95) * 5,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _accentSecondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _accentSecondary.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Top Right
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 12,
                        right: 12,
                        child: Opacity(
                          opacity: 0.3 + (_pulseAnimation.value - 0.95) * 5,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _accentSecondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _accentSecondary.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Bottom Left
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        bottom: 12,
                        left: 12,
                        child: Opacity(
                          opacity: 0.3 + (_pulseAnimation.value - 0.95) * 5,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _accentSecondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _accentSecondary.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Bottom Right
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        bottom: 12,
                        right: 12,
                        child: Opacity(
                          opacity: 0.3 + (_pulseAnimation.value - 0.95) * 5,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _accentSecondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _accentSecondary.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Animated position info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryMedium,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _accentPrimary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedPositionInfo('X Position', '12.5m', Icons.swap_horiz),
                _buildAnimatedPositionInfo('Y Position', '8.3m', Icons.swap_vert),
                _buildAnimatedPositionInfo('Angle', '45°', Icons.rotate_right),
                _buildAnimatedPositionInfo('Speed', '0.8m/s', Icons.speed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPositionInfo(String label, String value, IconData icon) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: _accentSecondary,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _accentSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: _textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _accentSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryMedium,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manual Controls',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _warningColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _warningColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
            child: Text(
                  'Manual Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Directional Control Pad
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                children: [
                  // Center
                  Center(
                    child: _buildDirectionalButton(
                      Icons.stop,
                      _errorColor,
                      'Stop',
                      () => _showControlConfirmation('Stop'),
                      60,
                    ),
                  ),
                  // Up
                  Positioned(
                    top: 0,
                    left: 60,
                    child: _buildDirectionalButton(
                      Icons.arrow_upward,
                      _accentPrimary,
                      'Forward',
                      () => _showControlConfirmation('Move Forward'),
                      60,
                    ),
                  ),
                  // Down
                  Positioned(
                    bottom: 0,
                    left: 60,
                    child: _buildDirectionalButton(
                      Icons.arrow_downward,
                      _accentPrimary,
                      'Back',
                      () => _showControlConfirmation('Move Backward'),
                      60,
                    ),
                  ),
                  // Left
                  Positioned(
                    left: 0,
                    top: 60,
                    child: _buildDirectionalButton(
                      Icons.arrow_back,
                      _accentPrimary,
                      'Left',
                      () => _showControlConfirmation('Turn Left'),
                      60,
                    ),
                  ),
                  // Right
                  Positioned(
                    right: 0,
                    top: 60,
                    child: _buildDirectionalButton(
                      Icons.arrow_forward,
                      _accentPrimary,
                      'Right',
                      () => _showControlConfirmation('Turn Right'),
                      60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Primary Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Start Cleaning',
                  Icons.play_circle_filled,
                  _successColor,
                  () => _showControlConfirmation('Start'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Pause',
                  Icons.pause_circle_filled,
                  _warningColor,
                  () => _showControlConfirmation('Pause'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Return Home',
                  Icons.home_rounded,
                  _accentSecondary,
                  () => _showControlConfirmation('Return'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Resume',
                  Icons.replay,
                  _accentPrimary,
                  () => _showControlConfirmation('Resume'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionalButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onTap,
    double size,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-Time Statistics',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Area Cleaned',
              '245 m²',
              Icons.cleaning_services,
              _accentPrimary,
              '85% Complete',
            ),
            _buildStatCard(
              'Runtime',
              '2h 15m',
              Icons.access_time,
              _accentSecondary,
              'Active Session',
            ),
            _buildStatCard(
              'Obstacles',
              '12',
              Icons.sensors,
              _warningColor,
              'Detected',
            ),
            _buildStatCard(
              'Efficiency',
              '94%',
              Icons.speed,
              _successColor,
              'Optimal',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _cardBg,
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ).createShader(bounds),
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionChip(
              'Auto Mode',
              Icons.auto_mode,
              _accentPrimary,
            ),
            _buildQuickActionChip(
              'Spot Clean',
              Icons.center_focus_strong,
              _accentSecondary,
            ),
            _buildQuickActionChip(
              'Edge Mode',
              Icons.border_outer,
              _warningColor,
            ),
            _buildQuickActionChip(
              'Max Power',
              Icons.bolt,
              _errorColor,
            ),
            _buildQuickActionChip(
              'Schedule',
              Icons.event,
              _successColor,
            ),
            _buildQuickActionChip(
              'Settings',
              Icons.settings,
              _textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$label activated',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Monitoring',
            style: GoogleFonts.poppins(
                      fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _successColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _successColor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
          Text(
                        'Real-time tracking active',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentSecondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.monitor_heart,
                  color: _accentSecondary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Real-time Progress Indicator
          _buildRealTimeProgressCard(),
          const SizedBox(height: 20),

          // Cleaning Progress Percentage
          _buildCleaningProgressCard(),
          const SizedBox(height: 20),

          // Path Status
          _buildPathStatusCard(),
          const SizedBox(height: 20),

          // Live Alerts
          _buildLiveAlertsCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRealTimeProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardBg,
            _accentPrimary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accentPrimary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(
                'Robot Activity Monitor',
                  style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _successColor, width: 1),
                ),
                child: Text(
                  'CLEANING',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: _successColor,
                    fontWeight: FontWeight.w700,
                  ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          
          // Activity indicators
          Row(
            children: [
              Expanded(child: _buildActivityIndicator('Cleaning', Icons.cleaning_services, _successColor, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildActivityIndicator('Navigating', Icons.navigation, _accentSecondary, true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActivityIndicator('Sensors', Icons.sensors, _accentPrimary, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildActivityIndicator('Connected', Icons.wifi, _successColor, true)),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Time indicators
          Container(
            padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              color: _primaryMedium,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _accentSecondary.withOpacity(0.3),
                width: 1,
              ),
              ),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                _buildTimeMetric('Session Time', '1:43:22', Icons.timer),
                Container(width: 1, height: 30, color: _textSecondary.withOpacity(0.2)),
                _buildTimeMetric('Remaining', '~25 min', Icons.schedule),
                Container(width: 1, height: 30, color: _textSecondary.withOpacity(0.2)),
                _buildTimeMetric('Distance', '2.8 km', Icons.straighten),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityIndicator(String label, IconData icon, Color color, bool isActive) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(isActive ? 0.5 : 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: isActive ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : [],
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                  decoration: BoxDecoration(
                    color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _accentSecondary, size: 18),
        const SizedBox(height: 6),
                  Text(
          value,
                    style: GoogleFonts.poppins(
            fontSize: 14,
                      fontWeight: FontWeight.w700,
            color: _accentSecondary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: _textSecondary,
            ),
          ),
        ],
    );
  }

  Widget _buildCleaningProgressCard() {
    const double progressValue = 0.72; // 72%
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryMedium,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _successColor.withOpacity(0.1),
            blurRadius: 20,
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
          Text(
            'Cleaning Progress',
            style: GoogleFonts.poppins(
                  fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
            child: Text(
                      '72%',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [_successColor, _accentSecondary],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Animated circular progress
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 6.28319,
                        child: CustomPaint(
                          size: const Size(160, 160),
                          painter: _ProgressRingPainter(
                            progress: 1.0,
                            color: _primaryMedium,
                            strokeWidth: 12,
                          ),
                        ),
                      );
                    },
                  ),
                  // Progress circle
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -1.5708, // -90 degrees to start from top
                        child: CustomPaint(
                          size: const Size(160, 160),
                          painter: _ProgressRingPainter(
                            progress: progressValue,
                            color: _successColor,
                            strokeWidth: 12,
                            gradient: LinearGradient(
                              colors: [_successColor, _accentSecondary],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Inner glow
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _successColor.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: _successColor.withOpacity(0.3 * _pulseAnimation.value),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cleaning_services,
                                color: _successColor,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Active',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Progress details
          Row(
            children: [
              Expanded(
                child: _buildProgressDetail('Completed', '245 m²', _successColor),
              ),
              Expanded(
                child: _buildProgressDetail('Remaining', '95 m²', _warningColor),
              ),
              Expanded(
                child: _buildProgressDetail('Total Area', '340 m²', _accentPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetail(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
            child: Text(
          value,
          style: GoogleFonts.poppins(
              fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPathStatusCard() {
    final pathSteps = [
      {'location': 'Classroom 101', 'status': 'completed', 'icon': Icons.meeting_room},
      {'location': 'Door A', 'status': 'completed', 'icon': Icons.door_front_door},
      {'location': 'Hallway B', 'status': 'current', 'icon': Icons.view_list},
      {'location': 'Trash Bin', 'status': 'pending', 'icon': Icons.delete},
    ];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryMedium,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
                'Route Progress',
            style: GoogleFonts.poppins(
                  fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accentSecondary, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route, color: _accentSecondary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Step 3 of 4',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: _accentSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Path visualization
          ...List.generate(pathSteps.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Connector
              final prevStep = pathSteps[index ~/ 2];
              return _buildPathConnector(prevStep['status'] as String);
            } else {
              // Step
              final step = pathSteps[index ~/ 2];
              return _buildPathStep(
                step['location'] as String,
                step['status'] as String,
                step['icon'] as IconData,
                index ~/ 2,
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPathStep(String location, String status, IconData icon, int stepNumber) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'completed':
        statusColor = _successColor;
        statusText = 'Completed';
        break;
      case 'current':
        statusColor = _accentSecondary;
        statusText = 'In Progress';
        break;
      default:
        statusColor = _textSecondary;
        statusText = 'Pending';
    }
    
    return AnimatedBuilder(
      animation: status == 'current' ? _pulseAnimation : _robotPulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: status == 'current'
                ? LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.15),
                      statusColor.withOpacity(0.05),
                    ],
                  )
                : null,
            color: status != 'current' ? _primaryMedium : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withOpacity(status == 'current' ? 0.6 : 0.3),
              width: status == 'current' ? 2 : 1,
            ),
            boxShadow: status == 'current' ? [
              BoxShadow(
                color: statusColor.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ] : [],
          ),
          child: Row(
      children: [
              Transform.scale(
                scale: status == 'current' ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor,
                        statusColor.withOpacity(0.7),
                      ],
                    ),
            borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                      location,
                style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
                    const SizedBox(height: 4),
                    Row(
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
                          statusText,
                style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
                  ],
                ),
              ),
              if (status == 'completed')
                Icon(Icons.check_circle, color: statusColor, size: 28),
              if (status == 'current')
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 6.28319,
                      child: Icon(Icons.sync, color: statusColor, size: 28),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPathConnector(String prevStatus) {
    final isCompleted = prevStatus == 'completed';
    final color = isCompleted ? _successColor : _textSecondary;
    
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.arrow_downward,
            color: color.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAlertsCard() {
    final alerts = [
      {
        'title': 'Trash Bin 80% Full',
        'message': 'Robot will return to base soon',
        'time': '2 min ago',
        'severity': 'warning',
        'icon': Icons.delete,
      },
      {
        'title': 'Obstacle Detected',
        'message': 'Successfully navigated around object in Hallway B',
        'time': '5 min ago',
        'severity': 'info',
        'icon': Icons.warning,
      },
      {
        'title': 'Battery Optimal',
        'message': '87% remaining - Sufficient for task completion',
        'time': '12 min ago',
        'severity': 'success',
        'icon': Icons.battery_charging_full,
      },
    ];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryMedium,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Alerts',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _warningColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _warningColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _warningColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${alerts.length} Active',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _warningColor,
                            fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...alerts.map((alert) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAlertItem(
              alert['title'] as String,
              alert['message'] as String,
              alert['time'] as String,
              alert['severity'] as String,
              alert['icon'] as IconData,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String message, String time, String severity, IconData icon) {
    Color severityColor;
    
    switch (severity) {
      case 'warning':
        severityColor = _warningColor;
        break;
      case 'success':
        severityColor = _successColor;
        break;
      case 'error':
        severityColor = _errorColor;
        break;
      default:
        severityColor = _accentSecondary;
    }
    
    return AnimatedBuilder(
      animation: severity == 'warning' ? _pulseAnimation : _robotPulseController,
      builder: (context, child) {
    return Container(
          padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                severityColor.withOpacity(0.1),
                severityColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: severityColor.withOpacity(0.3),
              width: 1,
            ),
      ),
      child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Transform.scale(
                scale: severity == 'warning' ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: severity == 'warning' ? [
                      BoxShadow(
                        color: severityColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : [],
                  ),
                  child: Icon(icon, color: severityColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: _textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
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
      },
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
                  'No live camera feed available.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
          Center(
            child: Text(
              'No real-time metrics available.',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
          ),
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
          const SizedBox(height: 20),
          Center(
            child: Text(
              'No cleaning history available.',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
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
        _buildHistoryStatCard('Total Cycles', '127', _accentPrimary, Icons.repeat),
        _buildHistoryStatCard(
          'Total Duration',
          '89 hrs',
          _successColor,
          Icons.schedule,
        ),
        _buildHistoryStatCard(
          'Area Cleaned',
          '12.5 km²',
          _accentSecondary,
          Icons.square_foot,
        ),
      ],
    );
  }

  Widget _buildHistoryStatCard(
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
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Issue',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Help us improve by reporting any issues',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _errorColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _errorColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.bug_report,
                  color: _errorColor,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Report Categories
          _buildQuickReportCategories(),
          const SizedBox(height: 20),

          // Report Form
          _buildReportForm(),
          const SizedBox(height: 20),

          // Tips Section
          _buildReportingTips(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickReportCategories() {
    final categories = [
      {
        'title': 'Bug / Error',
        'icon': Icons.bug_report,
        'color': _errorColor,
        'value': 'bug',
        'description': 'Something isn\'t working',
      },
      {
        'title': 'Feedback',
        'icon': Icons.feedback,
        'color': _accentSecondary,
        'value': 'feedback',
        'description': 'Share your thoughts',
      },
      {
        'title': 'Feature Request',
        'icon': Icons.lightbulb,
        'color': _warningColor,
        'value': 'feature_request',
        'description': 'Suggest improvements',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Category',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map((category) {
          final isSelected = _selectedReportCategory == category['value'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedBuilder(
              animation: isSelected ? _pulseAnimation : _robotPulseController,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReportCategory = category['value'] as String;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                (category['color'] as Color).withOpacity(0.15),
                                (category['color'] as Color).withOpacity(0.05),
                              ],
                            )
                          : null,
                      color: isSelected ? null : _cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (category['color'] as Color)
                            : _primaryMedium,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (category['color'] as Color)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: isSelected ? _pulseAnimation.value : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  category['color'] as Color,
                                  (category['color'] as Color)
                                      .withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: (category['color'] as Color)
                                      .withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category['description'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: category['color'] as Color,
                            size: 28,
                          )
                        else
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _textSecondary,
                                width: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReportForm() {
    Color categoryColor;
    switch (_selectedReportCategory) {
      case 'bug':
        categoryColor = _errorColor;
        break;
      case 'feedback':
        categoryColor = _accentSecondary;
        break;
      case 'feature_request':
        categoryColor = _warningColor;
        break;
      default:
        categoryColor = _accentPrimary;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardBg,
            categoryColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_note,
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Report Details',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Title Field
          Text(
            'Title *',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reportTitleController,
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Brief summary of the issue...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: _textSecondary.withOpacity(0.6),
              ),
              prefixIcon: Icon(
                Icons.title,
                color: categoryColor,
                size: 20,
              ),
              filled: true,
              fillColor: _primaryMedium,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: categoryColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: categoryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: categoryColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Description Field
          Text(
            'Description *',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reportDescriptionController,
            maxLines: 6,
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Describe the issue in detail...\n\nSteps to reproduce:\n1. \n2. \n3. ',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: _textSecondary.withOpacity(0.6),
              ),
              filled: true,
              fillColor: _primaryMedium,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: categoryColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: categoryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: categoryColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Info Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _accentPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  size: 18,
                  color: _accentPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your report will be sent securely to the admin team and reviewed within 24-48 hours.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return ElevatedButton(
                  onPressed: _isSubmittingReport ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: categoryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isSubmittingReport ? 0 : 4,
                    shadowColor: categoryColor.withOpacity(0.5),
                  ),
                  child: _isSubmittingReport
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Submitting Report...',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Submit Report to Admin',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportingTips() {
    final tips = [
      {
        'icon': Icons.description,
        'title': 'Be Specific',
        'description': 'Include details about what happened and when',
        'color': _accentPrimary,
      },
      {
        'icon': Icons.list_alt,
        'title': 'Steps to Reproduce',
        'description': 'List the steps that led to the issue',
        'color': _accentSecondary,
      },
      {
        'icon': Icons.photo_camera,
        'title': 'Include Context',
        'description': 'Mention device type, location, and time',
        'color': _warningColor,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryMedium,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: _warningColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reporting Tips',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (tip['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: tip['color'] as Color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tip['description'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    final title = _reportTitleController.text.trim();
    final description = _reportDescriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all required fields.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: _errorColor,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userName =
        authProvider.userModel?.name ?? authProvider.userModel?.email ?? 'User';
    final uid = authProvider.user?.uid ?? '';

    setState(() => _isSubmittingReport = true);

    try {
      final id = await ReportService.createReport(
        title: title,
        category: _selectedReportCategory,
        description: description,
        submittedBy: userName,
        submittedByUid: uid,
      );

      if (!mounted) return;

      if (id != null) {
        _reportTitleController.clear();
        _reportDescriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report submitted successfully. Our team will review it soon.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: _successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit report. Please try again.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: _errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred. Please try again.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: _errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingReport = false);
      }
    }
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
            ],
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final authProvider = context.read<AuthProvider>();
              final userId = authProvider.user?.uid;

              if (userId == null) {
                return Text(
                  'No notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                );
              }

              return StreamBuilder<List<UserNotification>>(
                stream: ScheduleService.streamUserNotifications(
                  userId,
                  limit: 3,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      'No notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    );
                  }

                  final notifications = snapshot.data!;

                  return Column(
                    children: notifications
                        .map(
                          (n) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationRow(
                              n.title,
                              n.message,
                              _getNotificationColor(n.type),
                              _formatNotificationTime(n.createdAt),
                              isRead: n.isRead,
                              notification: n,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.scheduleAdded:
      case NotificationType.scheduleUpdated:
        return _accentPrimary;
      case NotificationType.scheduleReminder:
        return _warningColor;
      case NotificationType.scheduleCompleted:
        return _successColor;
      case NotificationType.alert:
        return _errorColor;
    }
  }

  String _formatNotificationTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  Widget _buildNotificationRow(
    String title,
    String message,
    Color color,
    String time, {
    bool isRead = false,
    UserNotification? notification,
  }) {
    // Get notification type info
    final typeInfo = _getNotificationTypeInfo(
      notification?.type ?? NotificationType.alert,
      title: notification?.title,
    );
    final isReportReply = notification?.type == NotificationType.alert &&
        notification?.title == 'Reply to your report';
    final reportTitle = notification?.metadata?['reportTitle'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: isRead 
            ? _cardBg.withOpacity(0.5)
            : _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead 
              ? color.withOpacity(0.15) 
              : color.withOpacity(0.3),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: isRead 
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!isRead && notification != null) {
              ScheduleService.markNotificationAsRead(notification.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Type Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    typeInfo['icon'] as IconData,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Type Badge + Time
                      Row(
                        children: [
                          // Notification Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: color.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  typeInfo['icon'] as IconData,
                                  size: 12,
                                  color: color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  typeInfo['label'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Time
                          Text(
                            time,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Unread Indicator
                          if (!isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                          color: isRead ? _textPrimary.withOpacity(0.8) : _textPrimary,
                          height: 1.3,
                        ),
                      ),
                      // Report Title (for admin replies)
                      if (isReportReply && reportTitle != null && reportTitle.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _accentPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _accentPrimary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 14,
                                color: _accentPrimary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  reportTitle,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _accentPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Message Content
                      Container(
                        padding: isReportReply 
                            ? const EdgeInsets.all(10)
                            : EdgeInsets.zero,
                        decoration: isReportReply
                            ? BoxDecoration(
                                color: _cardBg.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _accentPrimary.withOpacity(0.2),
                                  width: 1,
                                ),
                              )
                            : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isReportReply) ...[
                              Icon(
                                Icons.reply,
                                size: 16,
                                color: _accentPrimary,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                message,
                                style: GoogleFonts.poppins(
                                  fontSize: isReportReply ? 12 : 11,
                                  fontWeight: isReportReply 
                                      ? FontWeight.w500 
                                      : FontWeight.normal,
                                  color: isRead 
                                      ? _textSecondary 
                                      : _textPrimary,
                                  height: 1.5,
                                ),
                                maxLines: isReportReply ? null : 3,
                                overflow: isReportReply ? null : TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Mark as Read Button
                if (!isRead) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: color,
                    ),
                    onPressed: () {
                      if (notification != null) {
                        ScheduleService.markNotificationAsRead(notification.id);
                      }
                    },
                    tooltip: 'Mark as read',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getNotificationTypeInfo(NotificationType type, {String? title}) {
    // Check if this is an admin reply
    if (type == NotificationType.alert && title == 'Reply to your report') {
      return {
        'label': 'Admin Reply',
        'icon': Icons.reply,
      };
    }
    
    switch (type) {
      case NotificationType.scheduleAdded:
        return {
          'label': 'Schedule Added',
          'icon': Icons.calendar_today,
        };
      case NotificationType.scheduleUpdated:
        return {
          'label': 'Schedule Updated',
          'icon': Icons.update,
        };
      case NotificationType.scheduleReminder:
        return {
          'label': 'Reminder',
          'icon': Icons.notifications,
        };
      case NotificationType.scheduleCompleted:
        return {
          'label': 'Completed',
          'icon': Icons.check_circle,
        };
      case NotificationType.alert:
        return {
          'label': 'Alert',
          'icon': Icons.info,
        };
    }
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
      builder: (dialogContext) => Dialog(
        backgroundColor: _cardBg,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
              ),
              // Content with Flexible instead of Expanded
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (builderContext) {
                        final authProvider = builderContext.read<AuthProvider>();
                        final userId = authProvider.user?.uid;

                        print('🔍 Notification Dialog - User ID: $userId');

                        if (userId == null) {
                          print('⚠️ Notification Dialog - No user ID found');
                          return Center(
                            child: Text(
                              'No notifications',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                          );
                        }

                        return StreamBuilder<List<UserNotification>>(
                          stream: ScheduleService.streamUserNotifications(userId),
                          builder: (streamContext, snapshot) {
                            print('📊 Dialog Stream - Connection: ${snapshot.connectionState}');
                            print('📊 Dialog Stream - Has Data: ${snapshot.hasData}');
                            print('📊 Dialog Stream - Has Error: ${snapshot.hasError}');
                            
                            if (snapshot.hasError) {
                              print('❌ Dialog Stream Error: ${snapshot.error}');
                              print('   Error details: ${snapshot.error.toString()}');
                            }
                            
                            if (snapshot.hasData) {
                              print('📊 Dialog Stream - Data count: ${snapshot.data!.length}');
                              if (snapshot.data!.isNotEmpty) {
                                snapshot.data!.forEach((n) {
                                  print('   📬 Notification: ${n.title} | isRead: ${n.isRead} | id: ${n.id}');
                                });
                              } else {
                                print('⚠️ Dialog Stream - Empty data list');
                              }
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: _errorColor,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error loading notifications',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: _errorColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        '${snapshot.error}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: _textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (!snapshot.hasData) {
                              print('⚠️ Notification Dialog - No data in snapshot');
                              return Center(
                                child: Text(
                                  'No notifications',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                              );
                            }

                            final notifications = snapshot.data!;
                            
                            if (notifications.isEmpty) {
                              print('⚠️ Notification Dialog - Empty notifications list');
                              return Center(
                                child: Text(
                                  'No notifications',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                              );
                            }

                            print('✅ Notification Dialog - Displaying ${notifications.length} notifications');

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: notifications
                                    .map(
                                      (n) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildNotificationRow(
                                          n.title,
                                          n.message,
                                          _getNotificationColor(n.type),
                                          _formatNotificationTime(n.createdAt),
                                          isRead: n.isRead,
                                          notification: n,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        );
                      },
                    ),
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

// Custom animated painter for grid pattern in robot visualization
class _AnimatedGridPainter extends CustomPainter {
  final double animationValue;

  _AnimatedGridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _accentPrimary.withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = _accentSecondary.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSpacing = 25.0;
    
    // Draw vertical lines with animation
    for (double x = 0; x < size.width; x += gridSpacing) {
      final isHighlight = ((x / gridSpacing) % 4 == (animationValue * 4).floor() % 4);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isHighlight ? highlightPaint : paint,
      );
    }
    
    // Draw horizontal lines with animation
    for (double y = 0; y < size.height; y += gridSpacing) {
      final isHighlight = ((y / gridSpacing) % 4 == (animationValue * 4).floor() % 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isHighlight ? highlightPaint : paint,
      );
    }
    
    // Draw corner accents
    final accentPaint = Paint()
      ..color = _accentPrimary.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    const cornerSize = 15.0;
    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerSize, 0), accentPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerSize), accentPaint);
    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerSize, 0), accentPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), accentPaint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), accentPaint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerSize), accentPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerSize, size.height), accentPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize), accentPaint);
  }

  @override
  bool shouldRepaint(_AnimatedGridPainter oldDelegate) => 
    animationValue != oldDelegate.animationValue;
}

// Custom painter for circular progress ring
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Gradient? gradient;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    } else {
      paint.color = color;
    }

    const startAngle = 0.0;
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
