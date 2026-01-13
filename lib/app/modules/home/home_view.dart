import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'home_controller.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';

import '../announcement_list/announcement_list_view.dart';
import '../student_list/student_list_view.dart';
import '../leave_list/leave_list_view.dart';
import '../profile/profile_view.dart';
import '../create_announcement/create_announcement_view.dart';
import '../confirm_leave/confirm_leave_view.dart';
import '../student_profile/student_profile_view.dart';
import '../attendance_history/attendance_history_view.dart';
import '../announcement_detail/announcement_detail_view.dart';
import '../profile/profile_controller.dart';

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? badgeCount = null;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          // [MODERNISASI] Biarkan font diatur oleh theme
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Card(
      // [MODERNISASI] Hapus style lokal agar MENGGUNAKAN CardTheme dari main.dart
      // color: AppColors.secondaryBackground, // Diambil dari theme
      // elevation: 2.0, // Diambil dari theme (0)
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Diambil dari theme (16)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: cardContent),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    badgeCount! > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [MODERNISASI] Hapus AppBar dari Scaffold, pindahkan ke dalam body
      body: Obx(() {
        if (controller.currentActionView.value != null) {
          return controller.currentActionView.value!;
        }

        final List<Widget> tabPages = [
          _buildHomeDashboardContent(context),
          const AnnouncementListView(),
          controller.userRole.value == 'guru'
              ? const StudentListView()
              : const LeaveListView(),
          const ProfileView(),
        ];

        return IndexedStack(
          index: controller.selectedIndex.value,
          children: tabPages,
        );
      }),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.alternate.withAlpha((0.5 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          // Padding untuk safety area (bawah) dan horizontal
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom, // Safety area
            left: 16,
            right: 16,
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTabIndex,
            items: controller.userRole.value == 'guru'
                ? _buildGuruNavItems()
                : _buildParentNavItems(),
            // [MODERNISASI] Hapus background & elevation dari bar itu sendiri
            // agar Container parent yang mengontrol tampilan
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle(int index, Widget? actionView) {
    if (actionView is CreateAnnouncementView) return 'Buat Pengumuman';
    if (actionView is ConfirmLeaveView) return 'Konfirmasi Izin';
    if (actionView is StudentProfileView) return 'Profil Ananda';
    if (actionView is AttendanceHistoryView) return 'Riwayat Absensi';
    if (actionView is AnnouncementDetailView) return 'Detail Pengumuman';

    String role = controller.userRole.value;
    if (role == 'guru') {
      switch (index) {
        case 0:
          return 'Dashboard Guru';
        case 1:
          return 'Pengumuman';
        case 2:
          return 'Data Siswa';
        case 3:
          return 'Profil Saya';
        default:
          return 'Sapa Raudha';
      }
    } else {
      switch (index) {
        case 0:
          return 'Beranda';
        case 1:
          return 'Pengumuman';
        case 2:
          return 'Ajukan Izin';
        case 3:
          return 'Profil Saya';
        default:
          return 'Sapa Raudha';
      }
    }
  }

  Widget _buildHomeDashboardContent(BuildContext context) {
    return SafeArea(
      // [MODERNISASI] AppBar dan konten dalam satu container mengapung
      top: true,
      bottom: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: -20.0, // efek seolah padding bawah -20 agar tertutup navbar
            child: Container(
              // [MODERNISASI] Container mengapung dengan rounded border
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.alternate.withAlpha((0.15 * 255).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: AppColors.alternate.withAlpha((0.1 * 255).round()),
                  width: 1,
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  controller.refreshAnnouncements();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // [MODERNISASI] Padding bawah diperpanjang agar tidak tertutup bottom navbar
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).padding.bottom +
                        kBottomNavigationBarHeight +
                        24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // [MODERNISASI] AppBar custom yang ikut scroll
                      _buildCustomAppBar(context),
                      // [MODERNISASI] Padding dalam untuk konten
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWelcomeHeader(context),
                              const SizedBox(height: 16),
                              controller.userRole.value == 'guru'
                                  ? const SizedBox.shrink()
                                  : _buildChildTodayCard(context),
                              const SizedBox(height: 20),
                              controller.userRole.value == 'guru'
                                  ? _buildGuruDashboardGrid(context)
                                  : _buildParentDashboardGrid(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.alternate.withAlpha((0.1 * 255).round()),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Obx(() {
            if (controller.currentActionView.value != null) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Kembali',
                onPressed: controller.clearActionView,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(
              () => Text(
                _getAppBarTitle(
                  controller.selectedIndex.value,
                  controller.currentActionView.value,
                ),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.selectedIndex.value == 3 &&
                controller.currentActionView.value == null) {
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Profil',
                onPressed: () =>
                    Get.find<ProfileController>().goToEditProfile(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  List<BottomNavigationBarItem> _buildGuruNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.campaign_outlined),
        activeIcon: Icon(Icons.campaign),
        label: 'Pengumuman',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group_outlined),
        activeIcon: Icon(Icons.group),
        label: 'Data Siswa',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
  }

  List<BottomNavigationBarItem> _buildParentNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Beranda',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.campaign_outlined),
        activeIcon: Icon(Icons.campaign),
        label: 'Pengumuman',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.mail_outline),
        activeIcon: Icon(Icons.mail),
        label: 'Izin',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Row(
      children: [
        // [MODERNISASI] Ganti CircleAvatar dengan "Squircle" (kotak bulat)
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0), // Radius 16
          child: Container(
            width: 56, // 28 * 2
            height: 56,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              controller.userRole.value == 'guru'
                  ? Icons.school_outlined
                  : Icons.person_outline,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat datang,",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Obx(
                () => Text(
                  controller.userName.value,
                  // [MODERNISASI] Font akan diatur oleh theme 'Inter'
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChildTodayCard(BuildContext context) {
    return Obx(() {
      if (controller.userRole.value != 'orangtua') {
        return const SizedBox.shrink();
      }

      final statusText = controller.childTodayStatus.value.isNotEmpty
          ? controller.childTodayStatus.value
          : 'Belum ada data';

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((0.12 * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Kehadiran',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGuruDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _DashboardCard(
          icon: Icons.qr_code_scanner,
          title: "Scan Presensi",
          onTap: controller.goToScanPresence,
        ),
        _DashboardCard(
          icon: Icons.campaign_outlined,
          title: "Buat Pengumuman",
          onTap: controller.goToCreateAnnouncement,
        ),
        _DashboardCard(
          icon: Icons.checklist_rtl_outlined,
          title: "Konfirmasi Izin",
          onTap: controller.goToConfirmLeave,
        ),
        _DashboardCard(
          icon: Icons.group_outlined,
          title: "Data Siswa",
          onTap: controller.goToStudentData,
        ),
        _DashboardCard(
          icon: Icons.notifications_outlined,
          title: "Notifikasi",
          onTap: controller.goToNotifications,
        ),
      ],
    );
  }

  Widget _buildParentDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _DashboardCard(
          icon: Icons.calendar_today_outlined,
          title: "Riwayat Absensi",
          onTap: controller.goToAttendanceHistory,
        ),
        _DashboardCard(
          icon: Icons.mail_outline,
          title: "Ajukan Izin",
          onTap: controller.goToRequestLeave,
        ),
        _DashboardCard(
          icon: Icons.campaign_outlined,
          title: "Lihat Pengumuman",
          onTap: controller.goToViewAnnouncements,
        ),
        _DashboardCard(
          icon: Icons.person_outline,
          title: "Profil Anak",
          onTap: controller.goToStudentProfile,
        ),
        _DashboardCard(
          icon: Icons.notifications_outlined,
          title: "Notifikasi",
          onTap: controller.goToNotifications,
        ),
      ],
    );
  }
}
