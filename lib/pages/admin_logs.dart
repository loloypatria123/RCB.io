import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/audit_log_model.dart';
import '../services/audit_service.dart';
import '../services/export_service.dart';
import '../services/export_service_web.dart';

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


class _AdminLogsState extends State<AdminLogs> {
  List<AuditLog> logs = [];
  StreamSubscription<List<AuditLog>>? _logsSub;
  Map<String, int> stats = {};

  String _selectedCategory = 'All';
  String _selectedActor = 'All';
  String _selectedRiskLevel = 'All';
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadLogs();
    _loadStats();
    
    // Log admin access to logs
    AuditService.logAdminAccess(
      action: AuditAction.adminAccessedLogs,
      area: 'System Logs & Audit Trail',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _logsSub?.cancel();
    super.dispose();
  }

  void _loadLogs() {
    _logsSub = AuditService.streamAuditLogs(limit: 500).listen((logsList) {
      setState(() {
        logs = logsList;
      });
    });
  }

  Future<void> _loadStats() async {
    final fetchedStats = await AuditService.getAuditStats();
    setState(() {
      stats = fetchedStats;
    });
  }

  List<AuditLog> get filteredLogs {
    List<AuditLog> filtered = logs;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((l) => l.category == _selectedCategory)
          .toList();
    }

    if (_selectedActor != 'All') {
      filtered = filtered.where((l) => l.actorType == _selectedActor).toList();
    }

    if (_selectedRiskLevel != 'All') {
      filtered = filtered.where((l) => l.riskLevel.toString().split('.').last == _selectedRiskLevel.toLowerCase()).toList();
    }

    if (_startDate != null) {
      filtered = filtered.where((l) => l.timestamp.isAfter(_startDate!)).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((l) => l.timestamp.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (l) =>
                l.actorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.getActionText().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (l.actorEmail.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                (l.sessionId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy HH:mm').format(timestamp);
    }
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
    final criticalCount = logs.where((l) => l.riskLevel == RiskLevel.critical).length;
    final highRiskCount = logs.where((l) => l.riskLevel == RiskLevel.high).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Logs',
            '${stats['total'] ?? logs.length}',
            Icons.description,
            _accentPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Today',
            '${stats['today'] ?? 0}',
            Icons.calendar_today,
            _successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Critical',
            '$criticalCount',
            Icons.warning,
            _errorColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'High Risk',
            '$highRiskCount',
            Icons.shield,
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
                value: _selectedRiskLevel,
                items: ['All', 'Low', 'Medium', 'High', 'Critical'].map((risk) {
                  return DropdownMenuItem(
                    value: risk,
                    child: Text(
                      risk == 'All' ? 'All Risk Levels' : risk,
                      style: GoogleFonts.poppins(
                        color: _textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRiskLevel = value);
                },
                underline: const SizedBox(),
                dropdownColor: _cardBg,
                style: GoogleFonts.poppins(color: _textPrimary),
                icon: Icon(Icons.shield, color: _accentPrimary, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showDateRangePicker(),
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(
                _startDate != null && _endDate != null
                    ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                    : 'Date Range',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _cardBg,
                foregroundColor: _accentPrimary,
                side: BorderSide(color: _accentPrimary.withValues(alpha: 0.2)),
              ),
            ),
            if (_startDate != null || _endDate != null) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                icon: const Icon(Icons.clear, size: 18),
                label: Text('Clear Dates', style: GoogleFonts.poppins(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _warningColor.withValues(alpha: 0.2),
                  foregroundColor: _warningColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentPrimary,
              surface: _cardBg,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: _cardBg.withValues(alpha: 0.8),
              border: Border(
                bottom: BorderSide(
                  color: _accentPrimary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildHeader('TIMESTAMP'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildHeader('ACTOR'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildHeader('ACTION'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildHeader('DETAILS'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildHeader('RISK'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildHeader('CATEGORY'),
                  ),
                ),
                const SizedBox(width: 52), // Space for info button
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _accentPrimary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildLogRow(AuditLog log, int index) {
    final categoryColor = _getCategoryColor(log.category);
    final actorColor = _getActorColor(log.actorType);
    final riskColor = log.getRiskColor();

    return InkWell(
      onTap: () => _showLogDetails(log),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timestamp Column - More spacing
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTimestamp(log.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, HH:mm:ss').format(log.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actor Badge - Better spacing
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: actorColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: actorColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Text(
                    log.actorType.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: actorColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            
            // Action Column - Better hierarchy
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.getActionText(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.actorName,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSecondary,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Details Column - More spacing
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  log.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondary,
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Risk Badge - Professional design
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: riskColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        log.riskLevel == RiskLevel.critical || log.riskLevel == RiskLevel.high
                            ? Icons.warning_rounded
                            : Icons.shield_outlined,
                        size: 14,
                        color: riskColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          log.riskLevel.toString().split('.').last.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: riskColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Category Badge - Cleaner design
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: categoryColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Text(
                    log.category.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: categoryColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            
            // Info Button - Better spacing
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(Icons.info_outline, color: _accentPrimary, size: 20),
                onPressed: () => _showLogDetails(log),
                tooltip: 'View Details',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          ],
        ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${filteredLogs.length} filtered logs',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accentPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accentPrimary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _accentPrimary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CSV export generates a downloadable file with all log details',
                      style: GoogleFonts.poppins(
                        color: _textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              _exportToCSV();
            },
            icon: const Icon(Icons.table_chart),
            label: Text(
              'Export CSV',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    try {
      // Prepare CSV data
      final headers = [
        'Timestamp',
        'Actor Name',
        'Actor Email',
        'Actor Type',
        'Action',
        'Description',
        'Category',
        'Risk Level',
        'Session ID',
        'IP Address',
        'Success',
        'Execution Time (ms)',
        'Log ID',
      ];
      
      // Build rows
      final rows = filteredLogs.map((log) {
        final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(log.timestamp);
        final riskLevel = log.riskLevel.toString().split('.').last;
        
        return [
          timestamp,
          log.actorName,
          log.actorEmail,
          log.actorType,
          log.getActionText(),
          log.description,
          log.category,
          riskLevel,
          log.sessionId ?? 'N/A',
          log.ipAddress ?? 'N/A',
          log.success.toString(),
          (log.executionTimeMs ?? 0).toString(),
          log.id,
        ];
      }).toList();
      
      // Generate CSV content
      final csvContent = ExportService.generateCSV(
        headers: headers,
        rows: rows,
      );
      
      // Generate filename
      final filename = ExportService.generateFilename('audit_logs');
      
      // Calculate file size
      final fileSize = ExportService.calculateFileSize(csvContent);
      
      // Download file (web-specific)
      ExportServiceWeb.downloadCSV(csvContent, filename);
      
      // Log the export action
      AuditService.logDataExport(
        dataType: 'Audit Logs',
        format: 'CSV',
        recordCount: filteredLogs.length,
      );
      
      print('📄 CSV Downloaded: $filename');
      print('   Records: ${filteredLogs.length}');
      print('   Size: $fileSize');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.download_done, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CSV Downloaded Successfully!',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$filename (${filteredLogs.length} records, $fileSize)',
                      style: GoogleFonts.poppins(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: _successColor,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
    } catch (e) {
      print('❌ Error generating CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error generating CSV: $e',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: _errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showRefreshDialog() {
    _loadStats();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs refreshed', style: GoogleFonts.poppins()),
        backgroundColor: _successColor,
      ),
    );
  }

  void _showLogDetails(AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        log.getActionText(),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: _textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Risk Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: log.getRiskColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: log.getRiskColor()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, color: log.getRiskColor(), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        log.getRiskText(),
                        style: GoogleFonts.poppins(
                          color: log.getRiskColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Details Grid
                _buildDetailSection('Actor Information', [
                  _buildDetailRow('Name', log.actorName),
                  _buildDetailRow('Email', log.actorEmail),
                  _buildDetailRow('Type', log.actorType.toUpperCase()),
                  _buildDetailRow('Actor ID', log.actorId),
                ]),
                
                const SizedBox(height: 16),
                
                _buildDetailSection('Action Details', [
                  _buildDetailRow('Description', log.description),
                  _buildDetailRow('Category', log.category.replaceAll('_', ' ').toUpperCase()),
                  _buildDetailRow('Timestamp', DateFormat('MMM dd, yyyy HH:mm:ss').format(log.timestamp)),
                  _buildDetailRow('Status', log.success ? '✅ Success' : '❌ Failed'),
                  if (log.errorMessage != null) _buildDetailRow('Error', log.errorMessage!),
                ]),
                
                const SizedBox(height: 16),
                
                _buildDetailSection('Technical Details', [
                  _buildDetailRow('Session ID', log.sessionId ?? 'N/A'),
                  _buildDetailRow('IP Address', log.ipAddress ?? 'N/A'),
                  _buildDetailRow('User Agent', log.userAgent ?? 'N/A'),
                  _buildDetailRow('Execution Time', '${log.executionTimeMs ?? 0}ms'),
                  _buildDetailRow('Log ID', log.id),
                ]),
                
                if (log.affectedUserId != null || log.affectedResourceId != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('Affected Resources', [
                    if (log.affectedUserId != null) _buildDetailRow('User ID', log.affectedUserId!),
                    if (log.affectedResourceId != null) _buildDetailRow('Resource ID', log.affectedResourceId!),
                    if (log.scheduleId != null) _buildDetailRow('Schedule ID', log.scheduleId!),
                  ]),
                ],
                
                if (log.changesBefore != null || log.changesAfter != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('Change Tracking', [
                    if (log.changesBefore != null) ...[
                      const SizedBox(height: 8),
                      Text('Before:', style: GoogleFonts.poppins(color: _errorColor, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log.changesBefore.toString(),
                          style: GoogleFonts.poppins(color: _textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                    if (log.changesAfter != null) ...[
                      const SizedBox(height: 12),
                      Text('After:', style: GoogleFonts.poppins(color: _successColor, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log.changesAfter.toString(),
                          style: GoogleFonts.poppins(color: _textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ]),
                ],
                
                if (log.metadata != null && log.metadata!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('Additional Metadata', [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _accentPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log.metadata.toString(),
                        style: GoogleFonts.poppins(color: _textSecondary, fontSize: 11),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _accentPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _accentPrimary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, color: _textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
