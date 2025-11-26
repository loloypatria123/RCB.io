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

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class ReportData {
  final String id, title, category, status, submittedBy, submittedDate;
  final String description;
  bool resolved;
  bool archived;
  final List<String> replies;

  ReportData({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.submittedBy,
    required this.submittedDate,
    required this.description,
    this.resolved = false,
    this.archived = false,
    this.replies = const [],
  });
}

class _AdminReportsState extends State<AdminReports> {
  final List<ReportData> reports = [
    ReportData(
      id: 'RPT001',
      title: 'Robot Not Responding',
      category: 'bug',
      status: 'Open',
      submittedBy: 'john@example.com',
      submittedDate: '2025-11-26 14:30',
      description: 'ROBOT-001 is not responding to commands. LED is off.',
      replies: [
        'Checked power supply - working fine',
        'Restarted robot successfully',
      ],
    ),
    ReportData(
      id: 'RPT002',
      title: 'UI Improvement Suggestion',
      category: 'feedback',
      status: 'Open',
      submittedBy: 'jane@example.com',
      submittedDate: '2025-11-26 13:15',
      description:
          'Dashboard could benefit from dark mode toggle for better accessibility.',
      replies: [],
    ),
    ReportData(
      id: 'RPT003',
      title: 'Cleaning Schedule Not Working',
      category: 'bug',
      status: 'Open',
      submittedBy: 'bob@example.com',
      submittedDate: '2025-11-26 12:00',
      description: 'Weekly schedule is not triggering on the specified days.',
      resolved: true,
      replies: ['Updated scheduling logic', 'Issue resolved in v2.1.6'],
    ),
    ReportData(
      id: 'RPT004',
      title: 'Feature Request: Export Data',
      category: 'feature_request',
      status: 'Open',
      submittedBy: 'alice@example.com',
      submittedDate: '2025-11-25 10:45',
      description:
          'Would like ability to export cleaning logs as PDF for reports.',
      replies: ['Added to roadmap for Q1 2026'],
    ),
    ReportData(
      id: 'RPT005',
      title: 'Battery Indicator Inaccurate',
      category: 'bug',
      status: 'Open',
      submittedBy: 'charlie@example.com',
      submittedDate: '2025-11-24 16:20',
      description: 'Robot battery shows 50% but dies within 10 minutes.',
      resolved: true,
      archived: true,
      replies: ['Calibrated battery sensor', 'Resolved and deployed'],
    ),
  ];

  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
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

  List<ReportData> get filteredReports {
    List<ReportData> filtered = reports.where((r) => !r.archived).toList();

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((r) => r.category == _selectedCategory)
          .toList();
    }

    if (_selectedStatus != 'All') {
      filtered = filtered
          .where(
            (r) =>
                r.status == _selectedStatus ||
                (r.resolved && _selectedStatus == 'Resolved'),
          )
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (r) =>
                r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                r.submittedBy.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
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
                'Reports & Feedback Management',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
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
            ],
          ),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildFiltersRow(),
          const SizedBox(height: 24),
          _buildReportsTable(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final openReports = reports.where((r) => !r.resolved && !r.archived).length;
    final resolvedReports = reports
        .where((r) => r.resolved && !r.archived)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Reports',
            '${reports.length}',
            Icons.report,
            _accentPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Open',
            '$openReports',
            Icons.pending,
            _warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Resolved',
            '$resolvedReports',
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
                    hintText: 'Search by title, description, or user...',
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
                items: ['All', 'bug', 'feedback', 'feature_request'].map((cat) {
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
                value: _selectedStatus,
                items: ['All', 'Open', 'Resolved'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(
                        color: _textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedStatus = value);
                },
                underline: const SizedBox(),
                dropdownColor: _cardBg,
                style: GoogleFonts.poppins(color: _textPrimary),
                icon: Icon(Icons.check_circle, color: _accentPrimary, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredReports.isEmpty)
          Center(
            child: Text(
              'No reports found',
              style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
            ),
          )
        else
          ...filteredReports.map((report) => _buildReportCard(report)),
      ],
    );
  }

  Widget _buildReportCard(ReportData report) {
    final categoryColor = _getCategoryColor(report.category);
    final statusColor = report.resolved ? _successColor : _warningColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: categoryColor,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            report.category.replaceAll('_', ' ').toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor, width: 0.5),
                          ),
                          child: Text(
                            report.resolved ? 'RESOLVED' : 'OPEN',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleReportAction(value, report),
                itemBuilder: (_) => [
                  if (!report.resolved)
                    PopupMenuItem(
                      value: 'resolve',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16),
                          const SizedBox(width: 8),
                          Text('Mark Resolved', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'reply',
                    child: Row(
                      children: [
                        const Icon(Icons.reply, size: 16),
                        const SizedBox(width: 8),
                        Text('Reply', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, size: 16),
                        const SizedBox(width: 8),
                        Text('View Details', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.archive,
                          size: 16,
                          color: _warningColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Archive',
                          style: GoogleFonts.poppins(color: _warningColor),
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
          const SizedBox(height: 12),
          Text(
            report.description,
            style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By ${report.submittedBy} • ${report.submittedDate}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: _textSecondary.withOpacity(0.7),
                ),
              ),
              if (report.replies.isNotEmpty)
                Container(
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
                    '${report.replies.length} replies',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: _accentPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bug':
        return _errorColor;
      case 'feedback':
        return _accentPrimary;
      case 'feature_request':
        return _accentSecondary;
      default:
        return _textSecondary;
    }
  }

  void _handleReportAction(String action, ReportData report) {
    if (action == 'resolve') {
      setState(() => report.resolved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report marked as resolved',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _successColor,
        ),
      );
    } else if (action == 'reply') {
      _showReplyDialog(report);
    } else if (action == 'view') {
      _showDetailsDialog(report);
    } else if (action == 'archive') {
      setState(() => report.archived = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report archived', style: GoogleFonts.poppins()),
          backgroundColor: _warningColor,
        ),
      );
    }
  }

  void _showReplyDialog(ReportData report) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Reply to Report',
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
                'Report: ${report.title}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: replyController,
                maxLines: 4,
                style: GoogleFonts.poppins(color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type your reply...',
                  hintStyle: GoogleFonts.poppins(color: _textSecondary),
                  filled: true,
                  fillColor: Color(0xFF0A0E1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _accentPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _accentPrimary.withValues(alpha: 0.3),
                    ),
                  ),
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
                    'Reply sent to user',
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
              'Send Reply',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(ReportData report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          report.title,
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
              _buildDetailRow(
                'Category',
                report.category.replaceAll('_', ' ').toUpperCase(),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Status', report.resolved ? 'RESOLVED' : 'OPEN'),
              const SizedBox(height: 12),
              _buildDetailRow('Submitted By', report.submittedBy),
              const SizedBox(height: 12),
              _buildDetailRow('Date', report.submittedDate),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                style: GoogleFonts.poppins(fontSize: 11, color: _textPrimary),
              ),
              if (report.replies.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Replies (${report.replies.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...report.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accentPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _accentPrimary, width: 0.5),
                      ),
                      child: Text(
                        reply,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
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
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 11, color: _textPrimary),
        ),
      ],
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Export Reports',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Export ${filteredReports.length} reports as:',
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
                    'Reports exported as CSV',
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
                    'Reports exported as PDF',
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
}
