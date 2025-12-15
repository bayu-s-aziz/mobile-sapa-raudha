import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/modules/admin_main_layout/admin_main_layout_controller.dart';
import 'package:sapa_raudha/app/modules/admin_attendance_management/admin_attendance_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_student_management/admin_student_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_management/admin_announcement_management_view.dart';

import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Dasbor Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchDashboardStats,
            tooltip: 'Refresh',
          ),
          Obx(
            () => Badge(
              label: Text('${controller.pendingPasswordResets.value}'),
              isLabelVisible: controller.pendingPasswordResets.value > 0,
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  final layoutController =
                      Get.find<AdminMainLayoutController>();
                  layoutController.changePage(
                    6,
                  ); // Index of Password Reset page
                },
                tooltip: 'Permintaan Reset Password',
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = [
          _Stat(
            title: 'Total Siswa',
            value: '${controller.totalStudents.value}',
            subtitle: 'Tersebar di ${controller.totalClasses.value} kelas',
            icon: Icons.school,
            badgeColor: AppColors.accent1,
            trend: null,
          ),
          _Stat(
            title: 'Hadir Hari Ini',
            value: '${controller.hadirToday.value}',
            subtitle:
                '${controller.attendancePercentage.value.toStringAsFixed(0)}% kehadiran',
            icon: Icons.check_circle,
            badgeColor: AppColors.success,
            trend: controller.weeklyAttendanceChange.value != 0
                ? controller.weeklyAttendanceChange.value
                : null,
          ),
          _Stat(
            title: 'Belum Presensi',
            value: '${controller.belumPresensi.value}',
            subtitle: 'Perlu tindak lanjut',
            icon: Icons.warning,
            badgeColor: AppColors.warning,
            trend: null,
          ),
          _Stat(
            title: 'Total Pengumuman',
            value: '${controller.totalAnnouncements.value}',
            subtitle: 'Pengumuman aktif',
            icon: Icons.campaign,
            badgeColor: AppColors.accent3,
            trend: null,
          ),
        ];

        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang kembali, Admin',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau aktivitas sekolah, kelola pengguna, dan buat pengumuman dari satu tempat.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    Text(
                      'Akses Cepat',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 600
                          ? 3
                          : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        _QuickActionCard(
                          title: 'Kelola\nPresensi',
                          icon: Icons.fact_check,
                          color: AppColors.primary,
                          onTap: () => _showPageModal(
                            context,
                            'Kelola Presensi',
                            const AdminAttendanceManagementView(),
                          ),
                        ),
                        _QuickActionCard(
                          title: 'Kelola\nSiswa',
                          icon: Icons.school,
                          color: AppColors.accent1,
                          onTap: () => _showPageModal(
                            context,
                            'Kelola Siswa',
                            const AdminStudentManagementView(),
                          ),
                        ),
                        _QuickActionCard(
                          title: 'Kelola\nPengguna',
                          icon: Icons.people,
                          color: AppColors.accent2,
                          onTap: () => _showPageModal(
                            context,
                            'Kelola Pengguna',
                            const AdminUserManagementView(),
                          ),
                        ),
                        _QuickActionCard(
                          title: 'Kelola\nPengumuman',
                          icon: Icons.campaign,
                          color: AppColors.accent3,
                          onTap: () => _showPageModal(
                            context,
                            'Kelola Pengumuman',
                            const AdminAnnouncementManagementView(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistik',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: stats.asMap().entries.map((entry) {
                                final item = entry.value;
                                final index = entry.key;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: index < stats.length - 1 ? 12 : 0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.alternate,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: item.badgeColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              item.icon,
                                              color: AppColors.primaryText,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            item.title,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  item.value,
                                                  style: textTheme.headlineSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors
                                                            .primaryText,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (item.trend != null) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: item.trend! > 0
                                                        ? AppColors.success
                                                              .withAlpha(25)
                                                        : AppColors.error
                                                              .withAlpha(25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        item.trend! > 0
                                                            ? Icons.arrow_upward
                                                            : Icons
                                                                  .arrow_downward,
                                                        size: 10,
                                                        color: item.trend! > 0
                                                            ? AppColors.success
                                                            : AppColors.error,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${item.trend!.abs().toStringAsFixed(0)}%',
                                                        style: textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color:
                                                                  item.trend! >
                                                                      0
                                                                  ? AppColors
                                                                        .success
                                                                  : AppColors
                                                                        .error,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 9,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.subtitle,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                  fontSize: 11,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ringkasan Harian & Aktivitas Terbaru
                    if (constraints.maxWidth >= 900)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _AttendanceSummaryCard(
                              controller: controller,
                              textTheme: textTheme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _RecentActivitiesCard(
                              controller: controller,
                              textTheme: textTheme,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _AttendanceSummaryCard(
                        controller: controller,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 16),
                      _RecentActivitiesCard(
                        controller: controller,
                        textTheme: textTheme,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showPageModal(BuildContext context, String title, Widget page) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 900),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Tutup',
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: page,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat {
  const _Stat({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.badgeColor,
    this.trend,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color badgeColor;
  final double? trend;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.controller,
    required this.textTheme,
  });

  final AdminDashboardController controller;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ringkasan Presensi Hari Ini',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    final layoutController =
                        Get.find<AdminMainLayoutController>();
                    layoutController.changePage(4);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Lihat Detail'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Hadir',
                    value: '${controller.hadirToday.value}',
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryItem(
                    label: 'Sakit',
                    value: '${controller.sakitToday.value}',
                    icon: Icons.sick,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryItem(
                    label: 'Izin',
                    value: '${controller.izinToday.value}',
                    icon: Icons.event_busy,
                    color: AppColors.accent2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryItem(
                    label: 'Alpa',
                    value: '${controller.alpaToday.value}',
                    icon: Icons.cancel,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  const _RecentActivitiesCard({
    required this.controller,
    required this.textTheme,
  });

  final AdminDashboardController controller;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aktivitas Terbaru',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: controller.fetchDashboardStats,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (controller.recentActivities.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Tidak ada aktivitas',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                )
              else
                ...controller.recentActivities.map(
                  (activity) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (activity['color'] as Color).withAlpha(75),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: activity['color'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity['icon'] as IconData,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activity['subtitle'] as String,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
