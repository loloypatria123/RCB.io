import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _cardBg = Color(0xFF131820);
const Color _accentPrimary = Color(0xFF00D9FF);
const Color _warningColor = Color(0xFFFF6B35);
const Color _successColor = Color(0xFF00FF88);
const Color _errorColor = Color(0xFFFF3333);
const Color _textPrimary = Color(0xFFE8E8E8);
const Color _textSecondary = Color(0xFF8A8A8A);

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({super.key});

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class NotificationData {
  final String id, title, message, type, timestamp;
  bool acknowledged;
  bool resolved;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.acknowledged = false,
    this.resolved = false,
  });
}

class _AdminNotificationsState extends State<AdminNotifications> {
  final List<NotificationData> notifications = [];

  String _selectedFilter = 'All';
  String _sortBy = 'Date';

  List<NotificationData> get filteredNotifications {
    List<NotificationData> filtered = notifications;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((n) => n.type == _selectedFilter).toList();
    }

    if (_sortBy == 'Date') {
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
                'Notifications Management',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showClearConfirm(),
                icon: const Icon(Icons.delete_sweep),
                label: Text(
                  'Clear All',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _errorColor,
                  foregroundColor: Colors.white,
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
          _buildFilterAndSort(),
          const SizedBox(height: 24),
          _buildNotificationsList(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final unresolved = notifications.where((n) => !n.resolved).length;
    final acknowledged = notifications.where((n) => n.acknowledged).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Alerts',
            '${notifications.length}',
            Icons.notifications,
            _accentPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Unresolved',
            '$unresolved',
            Icons.warning,
            _warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Acknowledged',
            '$acknowledged',
            Icons.check_circle,
            _successColor,
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

  Widget _buildFilterAndSort() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
              items:
                  [
                    'All',
                    'trash_full',
                    'robot_stuck',
                    'low_battery',
                    'disposal_completed',
                    'cleaning_completed',
                  ].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type == 'All'
                            ? 'All Types'
                            : type.replaceAll('_', ' ').toUpperCase(),
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
              isExpanded: true,
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
            value: _sortBy,
            items: ['Date', 'Type'].map((sort) {
              return DropdownMenuItem(
                value: sort,
                child: Text(
                  sort,
                  style: GoogleFonts.poppins(color: _textPrimary),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _sortBy = value);
            },
            underline: const SizedBox(),
            dropdownColor: _cardBg,
            style: GoogleFonts.poppins(color: _textPrimary),
            icon: Icon(Icons.sort, color: _accentPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Alerts',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        if (filteredNotifications.isEmpty)
          Center(
            child: Text(
              'No notifications',
              style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
            ),
          )
        else
          ...filteredNotifications.map(
            (notification) => _buildNotificationCard(notification),
          ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationData notification) {
    final typeColor = _getTypeColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.resolved
              ? _successColor.withValues(alpha: 0.2)
              : typeColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: typeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    if (notification.acknowledged)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _successColor, width: 0.5),
                        ),
                        child: Text(
                          'Acknowledged',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (notification.resolved)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _accentPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _accentPrimary, width: 0.5),
                        ),
                        child: Text(
                          'Resolved',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _accentPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timestamp,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleNotificationAction(value, notification),
            itemBuilder: (_) => [
              if (!notification.acknowledged)
                PopupMenuItem(
                  value: 'acknowledge',
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 16),
                      const SizedBox(width: 8),
                      Text('Acknowledge', style: GoogleFonts.poppins()),
                    ],
                  ),
                ),
              if (!notification.resolved)
                PopupMenuItem(
                  value: 'resolve',
                  child: Row(
                    children: [
                      const Icon(Icons.done_all, size: 16),
                      const SizedBox(width: 8),
                      Text('Resolve', style: GoogleFonts.poppins()),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 16, color: _errorColor),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: GoogleFonts.poppins(color: _errorColor),
                    ),
                  ],
                ),
              ),
            ],
            color: _cardBg,
            icon: Icon(Icons.more_vert, color: _accentPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'trash_full':
        return _warningColor;
      case 'robot_stuck':
        return _errorColor;
      case 'low_battery':
        return _warningColor;
      case 'disposal_completed':
        return _successColor;
      case 'cleaning_completed':
        return _successColor;
      default:
        return _accentPrimary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'trash_full':
        return Icons.delete;
      case 'robot_stuck':
        return Icons.block;
      case 'low_battery':
        return Icons.battery_alert;
      case 'disposal_completed':
        return Icons.done;
      case 'cleaning_completed':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  void _handleNotificationAction(String action, NotificationData notification) {
    if (action == 'acknowledge') {
      setState(() => notification.acknowledged = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notification acknowledged',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _successColor,
        ),
      );
    } else if (action == 'resolve') {
      setState(() => notification.resolved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification resolved', style: GoogleFonts.poppins()),
          backgroundColor: _successColor,
        ),
      );
    } else if (action == 'delete') {
      setState(() => notifications.remove(notification));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification deleted', style: GoogleFonts.poppins()),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  void _showClearConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Clear All Notifications',
          style: GoogleFonts.poppins(
            color: _errorColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will delete all notifications. This cannot be undone.',
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
              setState(() => notifications.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications cleared',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _errorColor),
            child: Text(
              'Clear All',
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
