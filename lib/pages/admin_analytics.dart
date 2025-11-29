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

class AdminAnalytics extends StatefulWidget {
  const AdminAnalytics({super.key});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  String _selectedPeriod = 'Monthly';

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
                'Analytics & Reports',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                children: [
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
                      value: _selectedPeriod,
                      items: ['Weekly', 'Monthly', 'Yearly'].map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(
                            period,
                            style: GoogleFonts.poppins(
                              color: _textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedPeriod = value);
                      },
                      underline: const SizedBox(),
                      dropdownColor: _cardBg,
                      style: GoogleFonts.poppins(color: _textPrimary),
                      icon: Icon(
                        Icons.calendar_today,
                        color: _accentPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
            ],
          ),
          const SizedBox(height: 24),
          _buildKPICards(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildCleaningPerformanceChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildDisposalFrequencyChart()),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildAlertTrendChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildRobotUptimeChart()),
            ],
          ),
          const SizedBox(height: 24),
          _buildUserActivityChart(),
          const SizedBox(height: 24),
          _buildMonthlyInsights(),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            'Total Cleanings',
            '--',
            Icons.cleaning_services,
            _accentPrimary,
            'No data',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            'Avg. Performance',
            '--',
            Icons.trending_up,
            _successColor,
            'No data',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            'Robot Uptime',
            '--',
            Icons.check_circle,
            _successColor,
            'No data',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            'Active Alerts',
            '--',
            Icons.warning,
            _warningColor,
            'No data',
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    IconData icon,
    Color color,
    String trend,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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
            style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCleaningPerformanceChart() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cleaning Performance',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mon',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Tue',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Wed',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Thu',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Fri',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Sat',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Sun',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisposalFrequencyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _accentSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disposal Frequency',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mon',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Tue',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Wed',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Thu',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Fri',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Sat',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Sun',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTrendChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _warningColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alert Trend Statistics',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mon',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Tue',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Wed',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Thu',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Fri',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Sat',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
              Text(
                'Sun',
                style: GoogleFonts.poppins(fontSize: 9, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRobotUptimeChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _successColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Robot Uptime vs Downtime',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivityChart() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Activity Analytics',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 0.5),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyInsights() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly/Weekly Cleaning Insights',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No insights available',
              style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accentPrimary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleBarChart(List<int> values, Color color) {
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: values.map((value) {
        final height = (value / maxValue) * 100;
        return Column(
          children: [
            Container(
              width: 20,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Export Analytics Report',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Export $_selectedPeriod analytics as:',
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
                    'Report exported as PDF',
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
                    'Report exported as Excel',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            icon: const Icon(Icons.table_chart),
            label: Text(
              'Excel',
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
