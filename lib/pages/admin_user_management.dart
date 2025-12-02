import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_management_service.dart';

const Color _cardBg = Color(0xFF131820);
const Color _accentPrimary = Color(0xFF00D9FF);
const Color _accentSecondary = Color(0xFF1E90FF);
const Color _warningColor = Color(0xFFFF6B35);
const Color _successColor = Color(0xFF00FF88);
const Color _textPrimary = Color(0xFFE8E8E8);
const Color _textSecondary = Color(0xFF8A8A8A);

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class UserData {
  final String id, name, email, role, status, joinDate, lastLogin;
  final int activityCount;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.lastLogin,
    required this.activityCount,
  });
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final List<UserData> users = [];

  bool _isLoading = false;

  late TextEditingController _searchController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserData> get filteredUsers {
    List<UserData> filtered = users;
    if (_selectedFilter != 'All') {
      filtered = filtered.where((u) => u.status == _selectedFilter).toList();
    }
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (u) =>
                u.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                u.email.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.add),
                label: Text(
                  'Add User',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildSearchAndFilter(),
          const SizedBox(height: 24),
          _buildUsersTable(),
        ],
      ),
    );
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await UserManagementService.getAllAccounts();

      users
        ..clear()
        ..addAll(
          accounts.map(
            (u) => UserData(
              id: u.uid,
              name: u.name,
              email: u.email,
              role: u.role == UserRole.admin ? 'Admin' : 'User',
              status: u.status,
              joinDate:
                  '${u.createdAt.year}-${u.createdAt.month.toString().padLeft(2, '0')}-${u.createdAt.day.toString().padLeft(2, '0')}',
              lastLogin: u.lastLogin != null
                  ? '${u.lastLogin!.year}-${u.lastLogin!.month.toString().padLeft(2, '0')}-${u.lastLogin!.day.toString().padLeft(2, '0')}'
                  : 'Never',
              activityCount: u.activityCount ?? 0,
            ),
          ),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load users: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _warningColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Users',
            '${users.length}',
            Icons.people,
            _accentPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active',
            '${users.where((u) => u.status == 'Active').length}',
            Icons.check_circle,
            _successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Inactive',
            '${users.where((u) => u.status == 'Inactive').length}',
            Icons.block,
            _warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Admins',
            '${users.where((u) => u.role == 'Admin').length}',
            Icons.admin_panel_settings,
            _accentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _accentPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: GoogleFonts.poppins(color: _textSecondary),
                prefixIcon: Icon(Icons.search, color: _accentPrimary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _accentPrimary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedFilter,
            items: ['All', 'Active', 'Inactive'].map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status,
                  style: GoogleFonts.poppins(color: _textPrimary),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedFilter = value);
            },
            underline: const SizedBox(),
            dropdownColor: _cardBg,
            style: GoogleFonts.poppins(color: _textPrimary),
            icon: Icon(Icons.filter_list, color: _accentPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTable() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _accentPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _accentPrimary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeader('Name')),
                Expanded(flex: 2, child: _buildHeader('Email')),
                Expanded(flex: 1, child: _buildHeader('Role')),
                Expanded(flex: 1, child: _buildHeader('Status')),
                Expanded(flex: 1, child: _buildHeader('Last Login')),
                Expanded(flex: 1, child: _buildHeader('Actions')),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(_accentPrimary),
                ),
              ),
            )
          else if (filteredUsers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No users found',
                style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
              ),
            )
          else
            ...filteredUsers.asMap().entries.map((entry) {
              return _buildTableRow(entry.value, entry.key);
            }),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _accentPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTableRow(UserData user, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: index.isEven ? _cardBg : _cardBg.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: _accentPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              user.name,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.email,
              style: GoogleFonts.poppins(fontSize: 13, color: _textSecondary),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildBadge(
              user.role,
              user.role == 'Admin' ? _accentSecondary : _accentPrimary,
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildBadge(
              user.status,
              user.status == 'Active' ? _successColor : _warningColor,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              user.lastLogin,
              style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PopupMenuButton<String>(
                onSelected: (value) => _handleUserAction(value, user),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: user.status == 'Active'
                        ? 'set_inactive'
                        : 'set_active',
                    child: Row(
                      children: [
                        Icon(
                          user.status == 'Active'
                              ? Icons.block
                              : Icons.check_circle,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.status == 'Active'
                              ? 'Set Inactive'
                              : 'Set Active',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: user.role == 'Admin' ? 'make_user' : 'make_admin',
                    child: Row(
                      children: [
                        Icon(
                          user.role == 'Admin'
                              ? Icons.person
                              : Icons.admin_panel_settings,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.role == 'Admin'
                              ? 'Demote to User'
                              : 'Promote to Admin',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                ],
                color: _cardBg,
                icon: Icon(Icons.more_vert, color: _accentPrimary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Add New User',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Add user functionality',
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
        ],
      ),
    );
  }

  Future<void> _handleUserAction(String action, UserData user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Current admin not authenticated',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _warningColor,
        ),
      );
      return;
    }

    final adminId = currentUser.uid;
    final adminEmail = currentUser.email ?? 'unknown@email.com';
    final adminName = currentUser.displayName ?? 'Admin User';

    if (action == 'set_active' || action == 'set_inactive') {
      final newStatus = action == 'set_active' ? 'Active' : 'Inactive';

      final success = await UserManagementService.updateUserStatus(
        targetUserId: user.id,
        isAdmin: user.role == 'Admin',
        newStatus: newStatus,
        adminId: adminId,
        adminEmail: adminEmail,
        adminName: adminName,
      );

      if (success) {
        await _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User status updated to $newStatus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update user status',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _warningColor,
          ),
        );
      }
    } else if (action == 'make_admin' || action == 'make_user') {
      final makeAdmin = action == 'make_admin';

      final success = await UserManagementService.updateUserRole(
        targetUserId: user.id,
        currentIsAdmin: user.role == 'Admin',
        makeAdmin: makeAdmin,
        adminId: adminId,
        adminEmail: adminEmail,
        adminName: adminName,
      );

      if (success) {
        await _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              makeAdmin
                  ? 'User promoted to admin successfully'
                  : 'Admin demoted to user successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update user role',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _warningColor,
          ),
        );
      }
    }
  }
}
