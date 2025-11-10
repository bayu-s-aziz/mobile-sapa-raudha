// lib/app/modules/home/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
// Impor service dan model pengumuman
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/modules/announcement_list/announcement_list_controller.dart';

// --- TAMBAHKAN IMPOR UNTUK ACTION VIEWS ---
import '../create_announcement/create_announcement_view.dart';
import '../confirm_leave/confirm_leave_view.dart';
import '../student_profile/student_profile_view.dart';
import '../attendance_history/attendance_history_view.dart';
import '../announcement_detail/announcement_detail_view.dart';
// --- AKHIR TAMBAHAN ---

class HomeController extends GetxController {
  final RxString userRole = ''.obs;
  final RxString userName = ''.obs;
  final RxString childStatus = ''.obs;

  final RxInt selectedIndex = 0.obs;

  // State untuk menampung view aksi (seperti Buat Pengumuman, dll)
  final Rxn<Widget> currentActionView = Rxn<Widget>();

  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();

  final RxList<Announcement> recentAnnouncements = <Announcement>[].obs;
  final RxBool isLoadingAnnouncements = true.obs;

  @override
  void onInit() {
    super.onInit();
    final roleArg = Get.arguments as String?;
    userRole.value = roleArg ?? 'default';
    _loadInitialData();
    fetchRecentAnnouncements();
  }

  void _loadInitialData() {
    if (userRole.value == 'guru') {
      userName.value = "Ibu Guru Hebat";
    } else if (userRole.value == 'orangtua') {
      userName.value = "Bapak Ortu Keren";
      childStatus.value = "Ananda: Budi - Hadir";
    } else {
      userName.value = "Pengguna";
    }
  }

  void fetchRecentAnnouncements() {
    isLoadingAnnouncements(true);
    Future.delayed(const Duration(milliseconds: 600), () {
      recentAnnouncements.assignAll(
        _announcementService.getRecentAnnouncements(count: 3),
      );
      isLoadingAnnouncements(false);
    });
  }

  void refreshAnnouncements() {
    fetchRecentAnnouncements();
    if (Get.isRegistered<AnnouncementListController>()) {
      final listController = Get.find<AnnouncementListController>();
      listController.fetchAnnouncements();
    }
  }

  void changeTabIndex(int index) {
    if (currentActionView.value != null) {
      clearActionView();
    }

    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
  }

  // --- MODIFIKASI FUNGSI INI ---
  void clearActionView() {
    currentActionView.value = null;
    // Get.arguments = null; // <-- HAPUS BARIS INI (PENYEBAB ERROR)
  }
  // --- AKHIR MODIFIKASI ---

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(child: const Text('Batal'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Logout'),
            onPressed: () {
              Get.back(); // Tutup dialog
              Get.offAllNamed(Routes.login); // Kembali ke login
            },
          ),
        ],
      ),
    );
  }

  // --- Navigasi Aksi (Drill-down) ---
  void goToScanPresence() => Get.toNamed(Routes.scanPresence);

  // --- Halaman-halaman ini di-render di dalam HomeView ---
  void goToCreateAnnouncement() {
    currentActionView.value = const CreateAnnouncementView();
  }

  void goToConfirmLeave() {
    currentActionView.value = const ConfirmLeaveView();
  }

  void goToStudentProfile() {
    currentActionView.value = const StudentProfileView();
  }

  void goToAttendanceHistory() {
    currentActionView.value = const AttendanceHistoryView();
  }

  // --- MODIFIKASI FUNGSI INI ---
  void goToAnnouncementDetail(String announcementId) {
    // Get.arguments = announcementId; // <-- HAPUS BARIS INI (PENYEBAB ERROR)

    // Kirim ID melalui constructor
    currentActionView.value = AnnouncementDetailView(
      announcementId: announcementId,
    );
  }
  // --- AKHIR MODIFIKASI ---

  // --- Navigasi Tab (Tetap sama) ---
  void goToStudentData() => changeTabIndex(2);
  void goToRequestLeave() => changeTabIndex(2);
  void goToViewAnnouncements() => changeTabIndex(1);
  void goToProfile() => changeTabIndex(3);
}
