import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'home_controller.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';

import '../announcement_list/announcement_list_view.dart';
import '../student_list/student_list_view.dart';
import '../request_leave/request_leave_view.dart';
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
  final int? badgeCount;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badgeCount,
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
      appBar: AppBar(
        // [MODERNISASI] AppBar sekarang ringan (dari theme)
        leading: Obx(() {
          if (controller.currentActionView.value != null) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Kembali',
              onPressed: controller.clearActionView,
            );
          }
          return const SizedBox.shrink();
        }),
        automaticallyImplyLeading: false,
        title: Obx(
          () => Text(
            _getAppBarTitle(
              controller.selectedIndex.value,
              controller.currentActionView.value,
            ),
          ),
        ),
        actions: [
          Obx(() {
            if (controller.selectedIndex.value == 3 &&
                controller.currentActionView.value == null) {
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Profil',
                onPressed: () =>
                    Get.find<ProfileController>().goToEditProfile(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.currentActionView.value != null) {
          return controller.currentActionView.value!;
        }

        final List<Widget> tabPages = [
          _buildHomeDashboardContent(context),
          const AnnouncementListView(),
          controller.userRole.value == 'guru'
              ? const StudentListView()
              : const RequestLeaveView(),
          const ProfileView(),
        ];

        return IndexedStack(
          index: controller.selectedIndex.value,
          children: tabPages,
        );
      }),
      // [MODERNISASI] Membuat BottomNavBar "Floating"
      // 1. Bungkus dengan Padding
      // 2. Bungkus dengan Container untuk shadow dan shape
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
          return 'Beranda Orang Tua';
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
      // [MODERNISASI] Hapus safe area atas karena appbar sudah ringan
      // [MODERNISASI] Tambahkan safe area bawah agar tidak tertutup nav bar floating
      top: false,
      bottom: false, // Di-handle oleh padding di SingleChildScrollView
      child: RefreshIndicator(
        onRefresh: () async {
          controller.refreshAnnouncements();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          // [MODERNISASI] Tambahkan padding bawah agar item terakhir tidak tertutup
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(context),
                const SizedBox(height: 30),
                controller.userRole.value == 'guru'
                    ? _buildGuruDashboardGrid(context)
                    : _buildParentDashboardGrid(context),
                const SizedBox(height: 30),
                _buildRecentInfoSection(context),
              ],
            ),
          ),
        ),
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
              if (controller.userRole.value == 'orangtua' &&
                  controller.childStatus.isNotEmpty) ...[
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.childStatus.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuruDashboardGrid(BuildContext context) {
    int pendingLeaveBadge = 2;
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
          badgeCount: pendingLeaveBadge,
          onTap: controller.goToConfirmLeave,
        ),
        _DashboardCard(
          icon: Icons.group_outlined,
          title: "Data Siswa",
          onTap: controller.goToStudentData,
        ),
      ],
    );
  }

  Widget _buildParentDashboardGrid(BuildContext context) {
    int announcementBadge = 1;
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
          badgeCount: announcementBadge,
          onTap: controller.goToViewAnnouncements,
        ),
        _DashboardCard(
          icon: Icons.person_outline,
          title: "Profil Anak",
          onTap: controller.goToStudentProfile,
        ),
      ],
    );
  }

  Widget _buildRecentInfoSection(BuildContext context) {
    final announcementService = Get.find<AnnouncementService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pengumuman Terbaru",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingAnnouncements.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          if (controller.recentAnnouncements.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Text(
                  "Belum ada pengumuman.",
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ),
            );
          }

          final announcementsToShow = controller.recentAnnouncements;
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcementsToShow.length,
            itemBuilder: (context, index) {
              final announcement = announcementsToShow[index];
              return Card(
                // [MODERNISASI] Hapus margin agar menggunakan CardTheme
                // margin: const EdgeInsets.only(bottom: 0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withAlpha(
                      (255 * 0.1).round(),
                    ),
                    child: const Icon(
                      Icons.campaign_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    announcement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    announcement.content.replaceAll('\n', ' ').length > 60
                        ? '${announcement.content.replaceAll('\n', ' ').substring(0, 60)}...'
                        : announcement.content.replaceAll('\n', ' '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  onTap: () =>
                      controller.goToAnnouncementDetail(announcement.id),
                ),
              );
            },
            // [MODERNISASI] Beri jarak antar card sedikit lebih banyak
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        }),
        Obx(() {
          bool shouldShowButton =
              !controller.isLoadingAnnouncements.value &&
              controller.recentAnnouncements.isNotEmpty &&
              announcementService.getAllAnnouncements().length >
                  controller.recentAnnouncements.length;

          return shouldShowButton
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton(
                      onPressed: controller.goToViewAnnouncements,
                      child: const Text("Lihat Semua"),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}
