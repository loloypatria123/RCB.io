import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_dashboard.dart';
import 'admin_user_management.dart';
import 'admin_robot_management.dart';
import 'admin_schedule_management.dart';
import 'admin_notifications.dart';
import 'admin_logs.dart';
import 'admin_reports.dart';
import 'admin_settings.dart';
import 'admin_analytics.dart';
import 'admin_connectivity_settings.dart';

// Professional palette aligned with user dashboard & auth pages
const Color _sidebarBg = Color(0xFF0A0E27); // Sidebar / scaffold background
const Color _cardBg = Color(0xFF111827); // Cards / panels

const Color _accentPrimary = Color(0xFF4F46E5); // Indigo accent
const Color _accentSecondary = Color(0xFF06B6D4); // Cyan accent

const Color _errorColor = Color(0xFFEF4444);
const Color _successColor = Color(0xFF10B981);

const Color _textPrimary = Color(0xFFF9FAFB);
const Color _textSecondary = Color(0xFFD1D5DB);

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      page: const AdminDashboard(),
    ),
    AdminMenuItem(
      icon: Icons.people,
      label: 'User Management',
      page: const AdminUserManagement(),
    ),
    AdminMenuItem(
      icon: Icons.smart_toy,
      label: 'Robot Management',
      page: const AdminRobotManagement(),
    ),
    AdminMenuItem(
      icon: Icons.schedule,
      label: 'Cleaning Schedule',
      page: const AdminScheduleManagement(),
    ),
    AdminMenuItem(
      icon: Icons.notifications,
      label: 'Notifications',
      page: const AdminNotifications(),
    ),
    AdminMenuItem(
      icon: Icons.history,
      label: 'Logs & Audit',
      page: const AdminLogs(),
    ),
    AdminMenuItem(
      icon: Icons.assessment,
      label: 'Reports',
      page: const AdminReports(),
    ),
    AdminMenuItem(
      icon: Icons.analytics,
      label: 'Analytics',
      page: const AdminAnalytics(),
    ),
    AdminMenuItem(
      icon: Icons.settings,
      label: 'Settings',
      page: const AdminSettings(),
    ),
    AdminMenuItem(
      icon: Icons.wifi,
      label: 'Connectivity',
      page: const AdminConnectivitySettings(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminAccess();
    });
  }

  void _checkAdminAccess() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAdmin) {
      Navigator.of(context).pushReplacementNamed('/user-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: _sidebarBg,
      body: Row(
        children: [
          // Sidebar
          if (!isMobile)
            _buildSidebar()
          else
            // On mobile, sidebar is full-width Drawer, always showing text labels
            Drawer(
              backgroundColor: _sidebarBg,
              child: _buildSidebarContent(true),
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isMobile),
                Expanded(child: _menuItems[_selectedIndex].page),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return ClipRect(
      child: AnimatedContainer(
        clipBehavior: Clip.hardEdge,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        width: _sidebarExpanded ? 260 : 88,
        color: _sidebarBg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Only show text labels when there is enough width to avoid overflow
            final bool showText = constraints.maxWidth >= 180;

            return Column(
              children: [
                _buildSidebarHeader(showText),
                Expanded(child: _buildSidebarContent(showText)),
                _buildSidebarFooter(showText),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(bool showText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _accentPrimary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentPrimary, _accentSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (showText) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RoboAdmin',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    'Control Panel',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _textSecondary,
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

  Widget _buildSidebarContent(bool showText) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        final isSelected = _selectedIndex == index;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: showText ? 8 : 4,
            vertical: 4,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                if (MediaQuery.of(context).size.width < 1024) {
                  Navigator.pop(context);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _accentPrimary.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: _accentPrimary, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) {
                        final icon = Icon(
                          item.icon,
                          color: isSelected ? _accentPrimary : _textSecondary,
                          size: 20,
                        );

                        if (showText) {
                          return icon;
                        }

                        // When labels are hidden, show tooltip with label on hover
                        return Tooltip(
                          message: item.label,
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _accentPrimary.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _textPrimary,
                          ),
                          child: icon,
                        );
                      },
                    ),
                    if (showText) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? _accentPrimary : _textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarFooter(bool showText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _accentPrimary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _logout(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.logout, color: _errorColor, size: 20),
                if (showText) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _errorColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(
          bottom: BorderSide(color: _accentPrimary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: _accentPrimary),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          else
            IconButton(
              icon: Icon(
                _sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                color: _accentPrimary,
              ),
              onPressed: () {
                setState(() {
                  _sidebarExpanded = !_sidebarExpanded;
                });
              },
            ),
          Expanded(
            child: Text(
              _menuItems[_selectedIndex].label,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentPrimary, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _successColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'ONLINE',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _successColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _accentSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accentSecondary, width: 1),
                ),
                child: Text(
                  authProvider.userModel?.name ?? 'Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accentSecondary,
                  ),
                ),
              );
            },
          ),
        ],
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
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(color: _textSecondary, fontSize: 14),
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
              style: GoogleFonts.poppins(
                color: _errorColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final String label;
  final Widget page;

  AdminMenuItem({required this.icon, required this.label, required this.page});
}
