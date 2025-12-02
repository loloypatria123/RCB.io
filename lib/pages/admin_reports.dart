import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import '../models/report_model.dart';
import '../models/audit_log_model.dart';
import '../services/report_service.dart';
import '../services/audit_service.dart';
import '../services/export_service.dart';
import '../services/export_service_web.dart';
=======
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import '../providers/auth_provider.dart';
>>>>>>> a38c3f0e6598ba35966a66d5cde632fab570ef3d

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

class _AdminReportsState extends State<AdminReports> {
<<<<<<< HEAD
  List<ReportData> reports = [];

  StreamSubscription<List<ReportModel>>? _reportsSub;
=======
  List<Report> _reports = [];
>>>>>>> a38c3f0e6598ba35966a66d5cde632fab570ef3d

  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
<<<<<<< HEAD
    _reportsSub = ReportService.streamAllReports().listen((models) {
      setState(() {
        reports = models
            .where((m) => !(m.archived))
            .map(
              (m) => ReportData(
                id: m.id,
                title: m.title,
                category: m.category,
                status: m.status,
                submittedBy: m.submittedBy,
                submittedDate: m.submittedDate,
                description: m.description,
                resolved: m.status == 'Resolved',
                archived: m.archived,
                replies: m.replies,
              ),
            )
            .toList();
      });
    });
    
    // Log admin access to reports
    AuditService.logAdminAccess(
      action: AuditAction.adminAccessedReports,
      area: 'Reports & Feedback Management',
    );
=======
    _loadReports();
  }

  void _loadReports() {
    ReportService.getAllReports().listen((reports) {
      if (mounted) {
        setState(() {
          _reports = reports;
        });
      }
    });
>>>>>>> a38c3f0e6598ba35966a66d5cde632fab570ef3d
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reportsSub?.cancel();
    super.dispose();
  }

  List<Report> get filteredReports {
    List<Report> filtered = _reports.where((r) => !r.archived).toList();

    if (_selectedCategory != 'All') {
      ReportCategory? selectedCat;
      switch (_selectedCategory) {
        case 'Robot Stuck':
          selectedCat = ReportCategory.robotStuck;
          break;
        case 'Navigation Problem':
          selectedCat = ReportCategory.navigationProblem;
          break;
        case 'Cleaning Error':
          selectedCat = ReportCategory.cleaningError;
          break;
        case 'App Issue':
          selectedCat = ReportCategory.appIssue;
          break;
        case 'Battery Issue':
          selectedCat = ReportCategory.batteryIssue;
          break;
        case 'Sensor Error':
          selectedCat = ReportCategory.sensorError;
          break;
        case 'Other':
          selectedCat = ReportCategory.other;
          break;
      }
      if (selectedCat != null) {
        filtered = filtered.where((r) => r.category == selectedCat).toList();
      }
    }

    if (_selectedStatus != 'All') {
      if (_selectedStatus == 'Open') {
        filtered = filtered.where((r) => r.status == ReportStatus.open).toList();
      } else if (_selectedStatus == 'Resolved') {
        filtered =
            filtered.where((r) => r.status == ReportStatus.resolved).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (r) =>
                r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                r.userName.toLowerCase().contains(
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
    final openReports = _reports
        .where((r) => r.status == ReportStatus.open && !r.archived)
        .length;
    final resolvedReports = _reports
        .where((r) => r.status == ReportStatus.resolved && !r.archived)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Reports',
            '${_reports.length}',
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
                items: [
                  'All',
                  'Robot Stuck',
                  'Navigation Problem',
                  'Cleaning Error',
                  'App Issue',
                  'Battery Issue',
                  'Sensor Error',
                  'Other'
                ].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      cat == 'All' ? 'All Categories' : cat,
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

  Widget _buildReportCard(Report report) {
    final categoryColor = _getCategoryColor(report.category);
    final statusColor = report.status == ReportStatus.resolved
        ? _successColor
        : _warningColor;

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
                            report.categoryDisplayName.toUpperCase(),
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
                            report.statusDisplayName.toUpperCase(),
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
                  if (report.status != ReportStatus.resolved)
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
                'By ${report.userName} • ${_formatDate(report.createdAt)}',
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

  Color _getCategoryColor(ReportCategory category) {
    switch (category) {
      case ReportCategory.robotStuck:
      case ReportCategory.cleaningError:
        return _errorColor;
      case ReportCategory.navigationProblem:
      case ReportCategory.batteryIssue:
      case ReportCategory.sensorError:
        return _warningColor;
      case ReportCategory.appIssue:
        return _accentSecondary;
      case ReportCategory.other:
        return _accentPrimary;
    }
  }

<<<<<<< HEAD
  Future<void> _handleReportAction(String action, ReportData report) async {
    if (action == 'resolve') {
      setState(() => report.resolved = true);
      await ReportService.markResolved(report.id, true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report marked as resolved',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _successColor,
        ),
=======
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _handleReportAction(String action, Report report) async {
    if (action == 'resolve') {
      final success = await ReportService.updateReportStatus(
        report.id,
        ReportStatus.resolved,
>>>>>>> a38c3f0e6598ba35966a66d5cde632fab570ef3d
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report marked as resolved',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _successColor,
          ),
        );
      }
    } else if (action == 'reply') {
      _showReplyDialog(report);
    } else if (action == 'view') {
      _showDetailsDialog(report);
    } else if (action == 'archive') {
<<<<<<< HEAD
      setState(() => report.archived = true);
      await ReportService.archive(report.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report archived', style: GoogleFonts.poppins()),
          backgroundColor: _warningColor,
        ),
      );
=======
      final success = await ReportService.archiveReport(report.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report archived', style: GoogleFonts.poppins()),
            backgroundColor: _warningColor,
          ),
        );
      }
>>>>>>> a38c3f0e6598ba35966a66d5cde632fab570ef3d
    }
  }

  void _showReplyDialog(Report report) {
    final replyController = TextEditingController();
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
            onPressed: () async {
<<<<<<< HEAD
              final reply = replyController.text.trim();
              if (reply.isEmpty) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
              await ReportService.addReply(report.id, reply);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Reply sent to user',
                    style: GoogleFonts.poppins(),
=======
              if (replyController.text.trim().isEmpty) {
                return;
              }

              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please log in to reply',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: _errorColor,
>>>>>>> a38c3f0e6598ba35966a66d5cde632fab570ef3d
                  ),
                );
                return;
              }

              final adminName = authProvider.userModel?.name ?? 
                                user.displayName ?? 
                                'Admin';
              final adminEmail = user.email ?? 
                                authProvider.userModel?.email ?? 
                                '';

              final success = await ReportService.addReply(
                reportId: report.id,
                adminId: user.uid,
                adminName: adminName,
                adminEmail: adminEmail,
                message: replyController.text.trim(),
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Reply sent to user'
                          : 'Failed to send reply',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor:
                        success ? _successColor : _errorColor,
                  ),
                );
              }
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

  void _showDetailsDialog(Report report) {
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
              _buildDetailRow('Category', report.categoryDisplayName),
              const SizedBox(height: 12),
              _buildDetailRow('Status', report.statusDisplayName),
              const SizedBox(height: 12),
              _buildDetailRow('Submitted By', report.userName),
              const SizedBox(height: 12),
              _buildDetailRow('Email', report.userEmail),
              const SizedBox(height: 12),
              _buildDetailRow('Date', _formatDate(report.createdAt)),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${reply.adminName} (${_formatDate(reply.createdAt)})',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: _accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reply.message,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _textPrimary,
                            ),
                          ),
                        ],
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
              _exportReportsToCSV();
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
              _exportReportsToPDF();
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

  void _exportReportsToCSV() {
    try {
      // Prepare CSV data
      final headers = [
        'Report ID',
        'Title',
        'Category',
        'Status',
        'Submitted By',
        'Submitted Date',
        'Description',
        'Replies Count',
        'Resolved',
        'Archived',
      ];
      
      // Build rows
      final rows = filteredReports.map((report) {
        return [
          report.id,
          report.title,
          report.category,
          report.status,
          report.submittedBy,
          report.submittedDate,
          report.description,
          report.replies.length.toString(),
          report.resolved.toString(),
          report.archived.toString(),
        ];
      }).toList();
      
      // Generate CSV content
      final csvContent = ExportService.generateCSV(
        headers: headers,
        rows: rows,
      );
      
      // Generate filename
      final filename = ExportService.generateFilename('reports');
      
      // Calculate file size
      final fileSize = ExportService.calculateFileSize(csvContent);
      
      // Download file (web-specific)
      ExportServiceWeb.downloadCSV(csvContent, filename);
      
      // Log export action
      AuditService.logDataExport(
        dataType: 'Reports',
        format: 'CSV',
        recordCount: filteredReports.length,
      );
      
      print('📄 CSV Downloaded: $filename');
      print('   Records: ${filteredReports.length}');
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
                      '$filename (${filteredReports.length} reports, $fileSize)',
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

  void _exportReportsToPDF() {
    // PDF export placeholder - would require pdf package
    AuditService.logDataExport(
      dataType: 'Reports',
      format: 'PDF',
      recordCount: filteredReports.length,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'PDF export coming soon! Use CSV export for now.',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: _accentSecondary,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
