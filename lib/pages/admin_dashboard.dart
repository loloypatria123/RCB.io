import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cleaning_schedule_model.dart';
import '../models/audit_log_model.dart';
import '../services/schedule_service.dart';
import 'admin_schedule_creation_dialog.dart';

// Professional palette aligned with user dashboard & auth pages
const Color _cardBg = Color(0xFF111827);

const Color _accentPrimary = Color(0xFF4F46E5); // Indigo
const Color _accentSecondary = Color(0xFF06B6D4); // Cyan
const Color _accentTertiary = Color(0xFF10B981); // Success green

const Color _warningColor = Color(0xFFF59E0B);
const Color _successColor = Color(0xFF10B981);

const Color _textPrimary = Color(0xFFF9FAFB);
const Color _textSecondary = Color(0xFFD1D5DB);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Stream<List<CleaningSchedule>> _todaySchedulesStream;
  late Stream<List<AuditLog>> _auditLogsStream;

  @override
  void initState() {
    super.initState();
    _todaySchedulesStream = ScheduleService.streamTodaySchedules();
    _auditLogsStream = ScheduleService.streamAuditLogs(limit: 10);
  }

  void _showCreateScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => const AdminScheduleCreationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 24),

          // Real-Time Robot Status
          _buildRobotStatusSection(),
          const SizedBox(height: 24),

          // System Metrics (Battery, Trash, Connection)
          _buildMetricsRow(),
          const SizedBox(height: 24),

          // Connection & Battery Status
          _buildConnectionBatterySection(),
          const SizedBox(height: 24),

          // Today's Cleaning Schedule
          _buildScheduleSection(),
          const SizedBox(height: 24),

          // Active Alerts
          _buildAlertsSection(),
          const SizedBox(height: 24),

          // Recent Logs
          _buildLogsSection(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActionsSection(),
        ],
      ),
    );
  }

  Widget _buildRobotStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-Time Robot Status',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _accentPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              'No robot data available',
              style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Metrics',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.battery_full,
                label: 'Battery Level',
                value: '87%',
                status: 'Good',
                statusColor: _successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.delete_outline,
                label: 'Trash Container',
                value: '45%',
                status: 'Normal',
                statusColor: _accentPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.router,
                label: 'WiFi Signal',
                value: '-45 dBm',
                status: 'Strong',
                statusColor: _successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.bluetooth,
                label: 'Bluetooth',
                value: 'Connected',
                status: 'Active',
                statusColor: _accentTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: statusColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor, width: 0.5),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBatterySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection & Power Status',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatusPanel(
                title: 'WiFi Connection',
                status: 'Connected',
                signal: '5G Network',
                icon: Icons.wifi,
                color: _accentPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusPanel(
                title: 'Battery Status',
                status: '87%',
                signal: 'Charging',
                icon: Icons.battery_charging_full,
                color: _successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPanel({
    required String title,
    required String status,
    required String signal,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            signal,
            style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Cleaning Schedule",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<CleaningSchedule>>(
          stream: _todaySchedulesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(_accentPrimary),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _warningColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Error loading schedules',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _warningColor,
                      ),
                    ),
                  ),
                ),
              );
            }

            final schedules = snapshot.data ?? [];

            if (schedules.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No cleaning schedule for today',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _accentPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < schedules.length; i++) ...[
                    _buildScheduleItemWidget(schedules[i]),
                    if (i < schedules.length - 1)
                      const Divider(color: Color(0xFF2A3040), height: 16),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleItemWidget(CleaningSchedule schedule) {
    final statusColor = _getStatusColor(schedule.status);
    final timeStr =
        '${schedule.scheduledTime.hour.toString().padLeft(2, '0')}:${schedule.scheduledTime.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Text(
          timeStr,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _accentPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (schedule.description.isNotEmpty)
                Text(
                  schedule.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: statusColor, width: 0.5),
          ),
          child: Text(
            _getStatusText(schedule.status),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.completed:
        return _successColor;
      case ScheduleStatus.inProgress:
        return _accentPrimary;
      case ScheduleStatus.cancelled:
        return _warningColor;
      case ScheduleStatus.scheduled:
        return _textSecondary;
    }
  }

  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.completed:
        return 'Completed';
      case ScheduleStatus.inProgress:
        return 'In Progress';
      case ScheduleStatus.cancelled:
        return 'Cancelled';
      case ScheduleStatus.scheduled:
        return 'Scheduled';
    }
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Alerts',
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
            color: _warningColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _warningColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _warningColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: _warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trash Container Nearly Full',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Container is at 95% capacity. Please empty soon.',
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
        ),
      ],
    );
  }

  Widget _buildLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity Logs',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<AuditLog>>(
          stream: _auditLogsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(_accentPrimary),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _warningColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Error loading logs',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _warningColor,
                      ),
                    ),
                  ),
                ),
              );
            }

            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No activity logs available',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _accentPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < logs.length; i++) ...[
                    _buildLogItemWidget(logs[i]),
                    if (i < logs.length - 1)
                      const Divider(color: Color(0xFF2A3040), height: 16),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogItemWidget(AuditLog log) {
    final timeStr =
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeStr,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _accentPrimary,
              ),
            ),
            Text(
              dateStr,
              style: GoogleFonts.poppins(fontSize: 10, color: _textSecondary),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.getActionText(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${log.actorName} - ${log.description}',
                style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              icon: Icons.play_arrow,
              label: 'Start Cleaning',
              color: _successColor,
            ),
            _buildActionButton(
              icon: Icons.pause,
              label: 'Pause',
              color: _warningColor,
            ),
            _buildActionButton(
              icon: Icons.home,
              label: 'Return Home',
              color: _accentPrimary,
            ),
            _buildActionButton(
              icon: Icons.settings,
              label: 'Settings',
              color: _accentSecondary,
            ),
            _buildActionButton(
              icon: Icons.add_circle,
              label: 'Create Schedule',
              color: _accentTertiary,
              onPressed: _showCreateScheduleDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
