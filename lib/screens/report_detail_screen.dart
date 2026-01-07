import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/report_model.dart';
import '../services/reports_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ReportsService _reportsService = ReportsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report Details', style: AppStyles.heading3),
        centerTitle: true,
      ),
      body: StreamBuilder<Report?>(
        stream: _reportsService.watchReport(widget.reportId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final report = snapshot.data;
          if (report == null) {
            return const Center(child: Text('Report not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                _buildStatusCard(report),
                const SizedBox(height: 20),
                // Report information
                _buildSectionTitle('Report Information'),
                _buildInfoField('Report ID', report.id),
                _buildInfoField('Category', report.category),
                _buildInfoField('Submitted', _formatDate(report.submittedDate)),
                const SizedBox(height: 20),
                // Incident details
                _buildSectionTitle('Incident Details'),
                _buildInfoField('Title', report.title),
                _buildInfoField(
                  'Description',
                  report.description,
                  multiline: true,
                ),
                if (report.incidentDate != null)
                  _buildInfoField(
                    'Incident Date',
                    _formatDate(report.incidentDate!),
                  ),
                if (report.location != null)
                  _buildInfoField('Location', report.location!),
                if (report.respondentName != null)
                  _buildInfoField('Respondent Name', report.respondentName!),
                const SizedBox(height: 20),
                // Resolution (if resolved)
                if (report.status == ReportStatus.resolved &&
                    report.resolution != null) ...[
                  _buildSectionTitle('Resolution'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resolution',
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(report.resolution!, style: AppStyles.bodySmall),
                        const SizedBox(height: 12),
                        Text(
                          'Resolved on ${_formatDate(report.resolvedDate!)}',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Privacy notice
                if (report.isAnonymous)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.privacy_tip, color: AppColors.primaryBlue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This is an anonymous report. Your identity is protected.',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Report report) {
    final statusInfo = {
      ReportStatus.pending: (
        'Pending',
        AppColors.warning,
        'Your report is waiting to be reviewed.',
      ),
      ReportStatus.underReview: (
        'Under Review',
        AppColors.primaryBlue,
        'Our team is investigating your report.',
      ),
      ReportStatus.resolved: (
        'Resolved',
        AppColors.success,
        'Your report has been resolved.',
      ),
      ReportStatus.closed: (
        'Closed',
        AppColors.textGray,
        'This report is closed.',
      ),
    };

    final (statusLabel, statusColor, statusMessage) =
        statusInfo[report.status]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                statusLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusMessage,
            style: AppStyles.bodySmall.copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppStyles.heading3),
    );
  }

  Widget _buildInfoField(String label, String value, {bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              value,
              style: AppStyles.bodySmall,
              maxLines: multiline ? null : 1,
              overflow:
                  multiline ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year} at $hour:$minute';
  }
}
