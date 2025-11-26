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

class AdminLogs extends StatefulWidget {
  const AdminLogs({super.key});

  @override
  State<AdminLogs> createState() => _AdminLogsState();
}

class LogEntry {
  final String id, actor, action, category, timestamp, details;
  final String actorType;

  LogEntry({
    required this.id,
    required this.actor,
    required this.action,
    required this.category,
    required this.timestamp,
    required this.details,
    required this.actorType,
  });
}

class _AdminLogsState extends State<AdminLogs> {
  final List<LogEntry> logs = [
    LogEntry(
      id: 'LOG001',
      actor: 'admin@gmail.com',
      action: 'User Created',
      category: 'user_actions',
      timestamp: '2025-11-26 10:30:15',
      details: 'New user john@example.com created with role: User',
      actorType: 'admin',
    ),
    LogEntry(
      id: 'LOG002',
      actor: 'ROBOT-001',
      action: 'Cleaning Started',
      category: 'cleaning_logs',
      timestamp: '2025-11-26 10:25:42',
      details: 'Classroom A cleaning session initiated. Duration: 45 min',
      actorType: 'robot',
    ),
    LogEntry(
      id: 'LOG003',
      actor: 'ROBOT-002',
      action: 'Disposal Completed',
      category: 'disposal_logs',
      timestamp: '2025-11-26 10:20:08',
      details: 'Trash disposal sequence completed successfully',
      actorType: 'robot',
    ),
    LogEntry(
      id: 'LOG004',
      actor: 'System',
      action: 'Sensor Warning',
      category: 'sensor_warnings',
      timestamp: '2025-11-26 10:15:33',
      details: 'ROBOT-003 line sensor sensitivity below threshold',
      actorType: 'system',
    ),
    LogEntry(
      id: 'LOG005',
      actor: 'ROBOT-001',
      action: 'Connection Lost',
      category: 'connectivity_issues',
      timestamp: '2025-11-26 10:10:22',
      details: 'WiFi connection interrupted for 2 minutes. Reconnected.',
      actorType: 'robot',
    ),
    LogEntry(
      id: 'LOG006',
      actor: 'admin@gmail.com',
      action: 'Schedule Updated',
      category: 'admin_actions',
      timestamp: '2025-11-26 10:05:11',
      details: 'Modified cleaning schedule SCH-001 timing',
      actorType: 'admin',
    ),
    LogEntry(
      id: 'LOG007',
      actor: 'System',
      action: 'System Error',
      category: 'system_errors',
      timestamp: '2025-11-26 09:55:44',
      details: 'Database connection timeout. Retry successful.',
      actorType: 'system',
    ),
    LogEntry(
      id: 'LOG008',
      actor: 'john@example.com',
      action: 'Login',
      category: 'user_actions',
      timestamp: '2025-11-26 09:45:30',
      details: 'User logged in from IP: 192.168.1.100',
      actorType: 'user',
    ),
  ];

  String _selectedCategory = 'All';
  String _selectedActor = 'All';
  String _searchQuery = '';

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LogEntry> get filteredLogs {
    List<LogEntry> filtered = logs;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((l) => l.category == _selectedCategory)
          .toList();
    }

    if (_selectedActor != 'All') {
      filtered = filtered.where((l) => l.actorType == _selectedActor).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (l) =>
                l.actor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.details.toLowerCase().contains(_searchQuery.toLowerCase()),
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
                'System Logs & Audit Trail',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showExportDialog(),
                    icon: const Icon(Icons.download),
                    label: Text(
                      'Export',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentSecondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showRefreshDialog(),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Refresh',
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
            ],
          ),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildFiltersRow(),
          const SizedBox(height: 24),
          _buildLogsTable(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Logs',
            '${logs.length}',
            Icons.description,
            _accentPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Today',
            '${logs.where((l) => l.timestamp.contains('2025-11-26')).length}',
            Icons.calendar_today,
            _successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Errors',
            '${logs.where((l) => l.category == 'system_errors').length}',
            Icons.error,
            _errorColor,
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

  Widget _buildFiltersRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters & Search',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: GoogleFonts.poppins(color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search by actor, action, or details...',
                    hintStyle: GoogleFonts.poppins(color: _textSecondary),
                    prefixIcon: Icon(Icons.search, color: _accentPrimary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                value: _selectedCategory,
                items:
                    [
                      'All',
                      'user_actions',
                      'admin_actions',
                      'robot_actions',
                      'cleaning_logs',
                      'disposal_logs',
                      'sensor_warnings',
                      'connectivity_issues',
                      'system_errors',
                    ].map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat == 'All'
                              ? 'All Categories'
                              : cat.replaceAll('_', ' ').toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
                underline: const SizedBox(),
                dropdownColor: _cardBg,
                style: GoogleFonts.poppins(color: _textPrimary),
                icon: Icon(Icons.filter_list, color: _accentPrimary, size: 18),
              ),
            ),
            const SizedBox(width: 12),
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
                value: _selectedActor,
                items: ['All', 'user', 'admin', 'robot', 'system'].map((actor) {
                  return DropdownMenuItem(
                    value: actor,
                    child: Text(
                      actor == 'All' ? 'All Actors' : actor.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: _textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedActor = value);
                },
                underline: const SizedBox(),
                dropdownColor: _cardBg,
                style: GoogleFonts.poppins(color: _textPrimary),
                icon: Icon(Icons.person, color: _accentPrimary, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogsTable() {
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
                Expanded(flex: 2, child: _buildHeader('Timestamp')),
                Expanded(flex: 1, child: _buildHeader('Actor')),
                Expanded(flex: 2, child: _buildHeader('Action')),
                Expanded(flex: 2, child: _buildHeader('Details')),
                Expanded(flex: 1, child: _buildHeader('Category')),
              ],
            ),
          ),
          if (filteredLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No logs found',
                style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
              ),
            )
          else
            ...filteredLogs.asMap().entries.map((entry) {
              return _buildLogRow(entry.value, entry.key);
            }),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _accentPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLogRow(LogEntry log, int index) {
    final categoryColor = _getCategoryColor(log.category);
    final actorColor = _getActorColor(log.actorType);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.timestamp,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: actorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: actorColor, width: 0.5),
              ),
              child: Text(
                log.actorType.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: actorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.action,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.details,
              style: GoogleFonts.poppins(fontSize: 10, color: _textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: categoryColor, width: 0.5),
              ),
              child: Text(
                log.category.replaceAll('_', '\n'),
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'user_actions':
        return _accentPrimary;
      case 'admin_actions':
        return _accentSecondary;
      case 'robot_actions':
        return _successColor;
      case 'cleaning_logs':
        return _successColor;
      case 'disposal_logs':
        return _warningColor;
      case 'sensor_warnings':
        return _warningColor;
      case 'connectivity_issues':
        return _warningColor;
      case 'system_errors':
        return _errorColor;
      default:
        return _accentPrimary;
    }
  }

  Color _getActorColor(String actor) {
    switch (actor) {
      case 'user':
        return _accentPrimary;
      case 'admin':
        return _accentSecondary;
      case 'robot':
        return _successColor;
      case 'system':
        return _warningColor;
      default:
        return _textSecondary;
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Export Logs',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Export ${filteredLogs.length} logs as:',
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Logs exported as CSV',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            icon: const Icon(Icons.table_chart),
            label: Text(
              'CSV',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Logs exported as PDF',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(
              'PDF',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentSecondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRefreshDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs refreshed', style: GoogleFonts.poppins()),
        backgroundColor: _successColor,
      ),
    );
  }
}
