import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_schedule_creation_dialog.dart';

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
  final List<ScheduleData> schedules = [];

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

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
          const SizedBox(height: 16),
          Text(
            'Create and manage cleaning schedules for your robots.',
            style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDateLabel() {
    if (_selectedDate == null) return 'Select date';
    return '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeLabel(TimeOfDay? time, String placeholder) {
    if (time == null) return placeholder;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildDatePickerField({String? initialDateLabel}) {
    final label = _selectedDate == null && initialDateLabel != null
        ? initialDateLabel
        : _formatDateLabel();
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 2),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: _accentPrimary,
                  surface: _cardBg,
                  onSurface: _textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _accentPrimary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: _accentPrimary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: _textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeRow({
    String? initialStartLabel,
    String? initialEndLabel,
  }) {
    final startLabel = _selectedStartTime == null && initialStartLabel != null
        ? initialStartLabel
        : _formatTimeLabel(_selectedStartTime, 'Start time');
    final endLabel = _selectedEndTime == null && initialEndLabel != null
        ? initialEndLabel
        : _formatTimeLabel(_selectedEndTime, 'End time');

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: _accentPrimary,
                        surface: _cardBg,
                        onSurface: _textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedStartTime = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _accentPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: _accentPrimary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      startLabel,
                      style: GoogleFonts.poppins(
                        color: _textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: _accentPrimary,
                        surface: _cardBg,
                        onSurface: _textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedEndTime = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _accentPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: _accentSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      endLabel,
                      style: GoogleFonts.poppins(
                        color: _textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
          child: schedules.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No upcoming schedules',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Timeline items will be populated from database
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
      builder: (context) => const AdminScheduleCreationDialog(),
    );
  }

  void _showEditScheduleDialog(ScheduleData schedule) {
    _selectedDate = null;
    _selectedStartTime = null;
    _selectedEndTime = null;
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
              _buildDatePickerField(initialDateLabel: schedule.startTime),
              const SizedBox(height: 12),
              _buildTimeRangeRow(
                initialStartLabel: schedule.startTime,
                initialEndLabel: schedule.endTime,
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
