import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import '../constants/app_theme.dart';
import '../utils/platform_widgets.dart';
import '../home_screen.dart';
import 'package:joblog/punch_list_app/screens/punch_list_screen.dart'
    as punch_list_app;
import 'project_management_screen.dart';
import 'project_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  final CameraDescription camera;

  const DashboardScreen({super.key, required this.camera});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardStats stats = DashboardStats(
    photoSummary: PhotoSummaryStats(
      projects: 8,
      todayPhotos: 15,
      thisWeekPhotos: 47,
      recentReports: 3,
    ),
    punchList: PunchListStats(
      totalItems: 23,
      pending: 12,
      inProgress: 6,
      completed: 5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

    return Scaffold(
      backgroundColor:
          isIOS ? AppTheme.backgroundColor : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isIOS),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  children: [
                    _buildPhotoSummaryCard(isIOS),
                    SizedBox(height: AppTheme.spacing16),
                    _buildPunchListCard(isIOS),
                    SizedBox(height: AppTheme.spacing16),
                    _buildQuickActions(isIOS),
                    SizedBox(height: AppTheme.spacing16),
                    _buildRecentActivity(isIOS),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isIOS),
    );
  }

  Widget _buildHeader(bool isIOS) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Construction Manager',
                      style: AppTheme.title1Style.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Your complete site management solution',
                      style: AppTheme.footnoteStyle.copyWith(
                        color: Colors.blue.shade100,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    PlatformWidgets.lightHaptic();
                    // TODO: Navigate to settings
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing16),
            _buildQuickStats(isIOS),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isIOS) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${stats.photoSummary.projects}', 'Active Projects'),
          Container(
              width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatItem('${stats.punchList.pending}', 'Pending Tasks'),
          Container(
              width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatItem('${stats.photoSummary.todayPhotos}', 'Photos Today'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.blue.shade100,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhotoSummaryCard(bool isIOS) {
    return GestureDetector(
      onTap: () {
        PlatformWidgets.mediumHaptic();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(camera: widget.camera),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: isIOS
              ? AppTheme.elevatedShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Purple Header
            Container(
              padding: EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  topRight: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 32),
                      ),
                      SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photo Summary',
                              style: AppTheme.title2Style.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Document & Export Reports',
                              style: AppTheme.subheadStyle.copyWith(
                                color: Colors.purple.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isIOS
                            ? CupertinoIcons.chevron_right
                            : Icons.chevron_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          '${stats.photoSummary.thisWeekPhotos}',
                          'This Week',
                          Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildMiniStat(
                          '${stats.photoSummary.recentReports}',
                          'Reports',
                          Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildMiniStat(
                          '${stats.photoSummary.projects}',
                          'Projects',
                          Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Features Footer
            Container(
              padding: EdgeInsets.all(AppTheme.spacing16),
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                border:
                    Border(top: BorderSide(color: Color(0xFFE9D5FF), width: 2)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Browse by calendar',
                        style: TextStyle(
                            fontSize: 13, color: Colors.purple.shade700),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf,
                          size: 16, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Export to PDF',
                        style: TextStyle(
                            fontSize: 13, color: Colors.purple.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunchListCard(bool isIOS) {
    return GestureDetector(
      onTap: () {
        PlatformWidgets.mediumHaptic();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const punch_list_app.PunchListScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: isIOS
              ? AppTheme.elevatedShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Green Header
            Container(
              padding: EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  topRight: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: const Icon(Icons.check_circle,
                            color: Colors.white, size: 32),
                      ),
                      SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Punch List',
                              style: AppTheme.title2Style.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI-Powered Task Management',
                              style: AppTheme.subheadStyle.copyWith(
                                color: Colors.green.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isIOS
                            ? CupertinoIcons.chevron_right
                            : Icons.chevron_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          '${stats.punchList.pending}',
                          'Pending',
                          Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildMiniStat(
                          '${stats.punchList.inProgress}',
                          'In Progress',
                          Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildMiniStat(
                          '${stats.punchList.completed}',
                          'Completed',
                          Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Features Footer
            Container(
              padding: EdgeInsets.all(AppTheme.spacing16),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                border:
                    Border(top: BorderSide(color: Color(0xFFA7F3D0), width: 2)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt,
                          size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'AI Photo Analysis',
                        style: TextStyle(
                            fontSize: 13, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Track Progress',
                        style: TextStyle(
                            fontSize: 13, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isIOS) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.folder_open,
            title: 'Projects',
            subtitle: 'View all',
            color: Colors.blue,
            onTap: () {
              PlatformWidgets.lightHaptic();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectManagementScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.trending_up,
            title: 'Reports',
            subtitle: 'Analytics',
            color: Colors.orange,
            onTap: () {
              PlatformWidgets.lightHaptic();
              // TODO: Navigate to analytics
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headlineStyle,
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.footnoteStyle
                        .copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isIOS) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Recent Activity',
                style: AppTheme.headlineStyle,
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildActivityItem(
            icon: Icons.image,
            iconColor: Colors.purple,
            title: '15 photos added',
            subtitle: 'Building 3 - Today',
            time: '2h ago',
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: '3 items completed',
            subtitle: 'Punch List - Today',
            time: '4h ago',
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.picture_as_pdf,
            iconColor: Colors.blue,
            title: 'Weekly report exported',
            subtitle: 'Photo Summary',
            time: '1d ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    AppTheme.subheadStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTheme.footnoteStyle
                    .copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTheme.footnoteStyle.copyWith(color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildBottomNav(bool isIOS) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true, isIOS),
              _buildNavItem(Icons.folder_open, 'Projects', false, isIOS),
              _buildNavItem(Icons.calendar_today, 'Calendar', false, isIOS),
              _buildNavItem(Icons.people, 'Team', false, isIOS),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, bool isIOS) {
    return GestureDetector(
      onTap: () {
        PlatformWidgets.lightHaptic();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    final isIOS = Platform.isIOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('The Punch List feature is coming soon!'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                PlatformWidgets.lightHaptic();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('The Punch List feature is coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// Stats Models
class DashboardStats {
  final PhotoSummaryStats photoSummary;
  final PunchListStats punchList;

  DashboardStats({
    required this.photoSummary,
    required this.punchList,
  });
}

class PhotoSummaryStats {
  final int projects;
  final int todayPhotos;
  final int thisWeekPhotos;
  final int recentReports;

  PhotoSummaryStats({
    required this.projects,
    required this.todayPhotos,
    required this.thisWeekPhotos,
    required this.recentReports,
  });
}

class PunchListStats {
  final int totalItems;
  final int pending;
  final int inProgress;
  final int completed;

  PunchListStats({
    required this.totalItems,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });
}
