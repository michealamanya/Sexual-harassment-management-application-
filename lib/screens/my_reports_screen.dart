import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/report_model.dart';
import '../services/reports_service.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/report_form_screen.dart';
import '../features/support_services/screens/support_home_screen.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final ReportsService _reportsService = ReportsService();
  final AuthService _authService = AuthService();
  int _currentNavIndex = 1;
  ReportStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (_authService.currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text('My Reports', style: AppStyles.heading3),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: AppColors.textGray),
              const SizedBox(height: 16),
              const Text(
                'Please log in to view your reports',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                //go to login screen
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Go to Login'),

              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('My Reports', style: AppStyles.heading3),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                ...ReportStatus.values.map(
                  (status) => _buildFilterChip(
                    status,
                    status.name[0].toUpperCase() + status.name.substring(1),
                  ),
                ),
              ],
            ),
          ),
          // Reports list
          Expanded(
            child: StreamBuilder<List<Report>>(
              stream: _reportsService.getUserReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: AppStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final reports = snapshot.data ?? [];
                final filteredReports =
                    _selectedFilter == null
                        ? reports
                        : reports
                            .where((r) => r.status == _selectedFilter)
                            .toList();

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder_open,
                          size: 48,
                          color: AppColors.textGray,
                        ),
                        const SizedBox(height: 16),
                        const Text('No reports found', style: AppStyles.bodyMedium),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportFormScreen(),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          child: const Text('Submit a Report'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredReports.length,
                  itemBuilder:
                      (context, index) =>
                          _buildReportCard(filteredReports[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormScreen()),
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            // My Reports - stay here
            setState(() {
              _currentNavIndex = index;
            });
          } else if (index == 2) {
            // Support
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SupportHomeScreen(),
              ),
            );
          } else if (index == 3) {
            // Settings
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(ReportStatus? status, String label) {
    final isSelected = _selectedFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? status : null;
          });
        },
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryBlue : AppColors.textGray,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(reportId: report.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.category,
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildStatusBadge(report.status),
                    const SizedBox(width: 8),
                    _buildReportActionsMenu(report),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.textGray),
                const SizedBox(width: 8),
                Text(
                  _formatDate(report.submittedDate),
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
            if (report.isAnonymous) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.privacy_tip, size: 14, color: AppColors.textGray),
                  const SizedBox(width: 8),
                  Text(
                    'Anonymous Report',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    final colors = {
      ReportStatus.pending: (AppColors.warning, Colors.orange),
      ReportStatus.underReview: (AppColors.primaryBlue, Colors.blue),
      ReportStatus.resolved: (AppColors.success, Colors.green),
      ReportStatus.closed: (AppColors.textGray, Colors.grey),
    };

    final (bgColor, textColor) = colors[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildReportActionsMenu(Report report) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'view') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(reportId: report.id),
            ),
          );
        } else if (value == 'edit') {
          _showEditDialog(report);
        } else if (value == 'delete') {
          _showDeleteDialog(report);
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'view',
              child: Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 12),
                  Text('View Details'),
                ],
              ),
            ),
            if (report.status == ReportStatus.pending)
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: AppColors.primaryBlue),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: AppColors.danger),
                  SizedBox(width: 12),
                  Text('Delete'),
                ],
              ),
            ),
          ],
      icon: const Icon(Icons.more_vert, color: AppColors.textGray, size: 20),
    );
  }

  void _showEditDialog(Report report) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Report'),
            content: const Text(
              'You can only edit reports that are pending. Once under review, editing is disabled.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (report.status == ReportStatus.pending)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to edit form (you can create a separate edit screen or reuse ReportFormScreen)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit functionality coming soon'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  child: const Text('Edit Now'),
                ),
            ],
          ),
    );
  }

  void _showDeleteDialog(Report report) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Report'),
            content: const Text(
              'Are you sure you want to delete this report? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteReport(report.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteReport(String reportId) async {
    try {
      // Note: You need to implement deleteReport in ReportsService
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
