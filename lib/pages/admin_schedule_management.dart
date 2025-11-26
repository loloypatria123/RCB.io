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

class AdminScheduleManagement extends StatefulWidget {
  const AdminScheduleManagement({super.key});

  @override
  State<AdminScheduleManagement> createState() =>
      _AdminScheduleManagementState();
}

class ScheduleData {
  final String id, name, area, robot, frequency;
  final String startTime, endTime;
  final bool enabled;
  final List<String> daysOfWeek;

  ScheduleData({
    required this.id,
    required this.name,
    required this.area,
    required this.robot,
    required this.frequency,
    required this.startTime,
    required this.endTime,
    required this.enabled,
    required this.daysOfWeek,
  });
}

class _AdminScheduleManagementState extends State<AdminScheduleManagement> {
  final List<ScheduleData> schedules = [
    ScheduleData(
      id: 'SCH-001',
      name: 'Morning Classroom Clean',
      area: 'Classroom A',
      robot: 'ROBOT-001',
      frequency: 'Daily',
      startTime: '08:00 AM',
      endTime: '09:00 AM',
      enabled: true,
      daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    ),
    ScheduleData(
      id: 'SCH-002',
      name: 'Hallway Maintenance',
      area: 'Hallway',
      robot: 'ROBOT-002',
      frequency: 'Weekly',
      startTime: '02:00 PM',
      endTime: '03:30 PM',
      enabled: true,
      daysOfWeek: ['Mon', 'Wed', 'Fri'],
    ),
    ScheduleData(
      id: 'SCH-003',
      name: 'Evening Deep Clean',
      area: 'All Areas',
      robot: 'ROBOT-003',
      frequency: 'Weekly',
      startTime: '06:00 PM',
      endTime: '08:00 PM',
      enabled: false,
      daysOfWeek: ['Sat'],
    ),
  ];

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
                'Cleaning Schedule Management',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddScheduleDialog(),
                icon: const Icon(Icons.add),
                label: Text(
                  'Create Schedule',
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
          _buildSchedulesList(),
          const SizedBox(height: 24),
          _buildUpcomingTimeline(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Schedules',
            '${schedules.length}',
            Icons.schedule,
            _accentPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Enabled',
            '${schedules.where((s) => s.enabled).length}',
            Icons.check_circle,
            _successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Disabled',
            '${schedules.where((s) => !s.enabled).length}',
            Icons.block,
            _warningColor,
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

  Widget _buildSchedulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Schedules',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        ...schedules.map((schedule) => _buildScheduleCard(schedule)),
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleData schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: schedule.enabled
              ? _successColor.withValues(alpha: 0.2)
              : _warningColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: schedule.enabled
                    ? _successColor.withValues(alpha: 0.1)
                    : _warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                schedule.enabled ? Icons.check_circle : Icons.cancel,
                color: schedule.enabled ? _successColor : _warningColor,
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
                  schedule.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: _accentPrimary),
                    const SizedBox(width: 4),
                    Text(
                      schedule.area,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.smart_toy, size: 12, color: _accentSecondary),
                    const SizedBox(width: 4),
                    Text(
                      schedule.robot,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(schedule.frequency, _accentPrimary),
                    const SizedBox(width: 8),
                    _buildBadge(
                      '${schedule.startTime} - ${schedule.endTime}',
                      _accentSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: schedule.daysOfWeek.map((day) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _accentPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _accentPrimary, width: 0.5),
                      ),
                      child: Text(
                        day,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: _accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleScheduleAction(value, schedule),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 16),
                    const SizedBox(width: 8),
                    Text('Edit', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    const Icon(Icons.content_copy, size: 16),
                    const SizedBox(width: 8),
                    Text('Duplicate', style: GoogleFonts.poppins()),
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
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUpcomingTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Schedule Timeline (Next 7 Days)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
              _buildTimelineItem(
                'Today - 08:00 AM',
                'Morning Classroom Clean',
                _successColor,
              ),
              const Divider(color: Color(0xFF2A3040)),
              _buildTimelineItem(
                'Today - 02:00 PM',
                'Hallway Maintenance',
                _accentPrimary,
              ),
              const Divider(color: Color(0xFF2A3040)),
              _buildTimelineItem(
                'Tomorrow - 08:00 AM',
                'Morning Classroom Clean',
                _successColor,
              ),
              const Divider(color: Color(0xFF2A3040)),
              _buildTimelineItem(
                'Wed - 02:00 PM',
                'Hallway Maintenance',
                _accentPrimary,
              ),
              const Divider(color: Color(0xFF2A3040)),
              _buildTimelineItem(
                'Sat - 06:00 PM',
                'Evening Deep Clean',
                _warningColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String time, String name, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleScheduleAction(String action, ScheduleData schedule) {
    if (action == 'edit') {
      _showEditScheduleDialog(schedule);
    } else if (action == 'duplicate') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule duplicated', style: GoogleFonts.poppins()),
          backgroundColor: _successColor,
        ),
      );
    } else if (action == 'delete') {
      _showDeleteConfirm(schedule);
    }
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Create New Schedule',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Schedule Name'),
              const SizedBox(height: 12),
              _buildTextField('Area/Room'),
              const SizedBox(height: 12),
              _buildTextField('Robot ID'),
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
                    'Schedule created',
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
              'Create',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditScheduleDialog(ScheduleData schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Edit Schedule',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Schedule Name', initialValue: schedule.name),
              const SizedBox(height: 12),
              _buildTextField('Area/Room', initialValue: schedule.area),
              const SizedBox(height: 12),
              _buildTextField('Robot ID', initialValue: schedule.robot),
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
                    'Schedule updated',
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

  Widget _buildTextField(String hint, {String initialValue = ''}) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      style: GoogleFonts.poppins(color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: _textSecondary),
        filled: true,
        fillColor: Color(0xFF0A0E1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentPrimary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  void _showDeleteConfirm(ScheduleData schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Delete Schedule',
          style: GoogleFonts.poppins(
            color: _errorColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Delete "${schedule.name}"? This cannot be undone.',
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
                    'Schedule deleted',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _errorColor),
            child: Text(
              'Delete',
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
