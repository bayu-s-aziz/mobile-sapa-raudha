// lib/app/modules/home/home_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';
// Impor service dan model pengumuman
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/modules/announcement_list/announcement_list_controller.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';

// --- TAMBAHKAN IMPOR UNTUK ACTION VIEWS ---
import '../create_announcement/create_announcement_view.dart';
import '../confirm_leave/confirm_leave_view.dart';
import '../student_profile/student_profile_view.dart';
import '../attendance_history/attendance_history_view.dart';
import '../announcement_detail/announcement_detail_view.dart';
import '../notification_list/notification_list_view.dart';
// --- AKHIR TAMBAHAN ---

class HomeController extends GetxController {
  final RxString userRole = ''.obs;
  final RxString userName = ''.obs;
  final RxString childStatus = ''.obs;
  final RxString childName = ''.obs;
  final RxString childClass = ''.obs;
  final RxString childTodayStatus = ''.obs;

  final RxInt selectedIndex = 0.obs;

  // State untuk menampung view aksi (seperti Buat Pengumuman, dll)
  final Rxn<Widget> currentActionView = Rxn<Widget>();

  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();
  late final ProfileService _profileService = Get.find<ProfileService>();
  late final AttendanceService _attendanceService =
      Get.find<AttendanceService>();
  late final LeaveService _leaveService = Get.find<LeaveService>();
  late final LocalStorageService _storage = Get.find<LocalStorageService>();

  final RxList<Announcement> recentAnnouncements = <Announcement>[].obs;
  final RxBool isLoadingAnnouncements = true.obs;
  final RxBool isLoadingProfile = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxInt pendingLeaveCount = 0.obs;
  final RxMap<String, int> attendanceStats = <String, int>{}.obs;
  final RxInt unreadAnnouncementCount = 0.obs;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    final storedRole =
        _profileService.getStoredRole() ?? _storage.read<String>('role');
    final roleArg = Get.arguments as String?;
    userRole.value = storedRole ?? roleArg ?? 'default';

    _hydrateFromCache();
    fetchRecentAnnouncements();
    fetchProfile();
    fetchAttendanceStats();
    fetchPendingLeaveCount();
    fetchChildTodayStatus();
  }

  void _hydrateFromCache() {
    final cachedProfile = _profileService.getStoredProfile();
    if (cachedProfile != null) {
      _applyProfile(cachedProfile);
    }
  }

  Future<void> fetchProfile() async {
    isLoadingProfile(true);
    try {
      final profile = await _profileService.fetchProfile();
      _applyProfile(profile);
      fetchChildTodayStatus();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat profil: $e');
    } finally {
      isLoadingProfile(false);
    }
  }

  void _applyProfile(Map<String, dynamic> profile) {
    // Set display name using profile service
    final displayName = _profileService.getUserName() ?? 'Pengguna';
    userName.value = displayName;

    if (userRole.value == 'orangtua') {
      childName.value =
          (profile['student_name'] as String?) ??
          (profile['anak'] as String?) ??
          (profile['userable']?['student']?['name'] as String?) ??
          '';
      childClass.value =
          (profile['class_name'] as String?) ??
          (profile['kelas'] as String?) ??
          (profile['userable']?['student']?['kelas']?['name'] as String?) ??
          '';

      // Simpan NISN anak ke storage dengan multiple fallback
      final nisn =
          (profile['nisn'] as String?) ??
          (profile['student_nisn'] as String?) ??
          (profile['userable']?['student']?['nisn'] as String?) ??
          (profile['anak']?['nisn'] as String?);
      if (nisn != null && nisn.isNotEmpty) {
        _storage.save('nisn', nisn);
      } else {
        // NISN anak tidak ditemukan di profile
      }
      _updateChildStatus();
    }
  }

  void _updateChildStatus({String? statusLabel}) {
    if (childName.value.isEmpty) return;
    final status = statusLabel ?? childTodayStatus.value;
    final classText = childClass.value.isNotEmpty
        ? ' - ${childClass.value}'
        : '';
    final statusText = status.isNotEmpty ? ' - $status' : '';
    childStatus.value = 'Ananda: ${childName.value}$classText$statusText';
  }

  void fetchRecentAnnouncements() {
    isLoadingAnnouncements(true);
    _announcementService
        .getAllAnnouncements(limit: 50)
        .then((data) {
          unreadAnnouncementCount.value = data
              .where((a) => a.isRead == false)
              .length;
          // Simpan hanya 3 terbaru untuk tampilan ringkas
          recentAnnouncements.assignAll(data.take(3).toList());
        })
        .catchError((e) {
          SnackbarHelper.showError('Gagal memuat pengumuman: $e');
        })
        .whenComplete(() => isLoadingAnnouncements(false));
  }

  Future<void> fetchAttendanceStats() async {
    if (userRole.value != 'guru') return;
    isLoadingStats(true);
    try {
      final res = await _attendanceService.getStatsToday();
      attendanceStats.assignAll({
        'total': res['total_students'] as int? ?? 0,
        'present': res['today']?['present'] as int? ?? 0,
        'sick': res['today']?['sick'] as int? ?? 0,
        'permit': res['today']?['permit'] as int? ?? 0,
        'absent': res['today']?['absent'] as int? ?? 0,
      });
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat statistik presensi: $e');
    } finally {
      isLoadingStats(false);
    }
  }

  Future<void> fetchPendingLeaveCount() async {
    if (userRole.value != 'guru') return;
    try {
      final data = await _leaveService.getLeaveRequests(status: 'pending');
      pendingLeaveCount.value = data.length;
    } catch (_) {
      pendingLeaveCount.value = 0;
    }
  }

  Future<void> fetchChildTodayStatus() async {
    if (userRole.value != 'orangtua') return;
    final nisn =
        _profileService.getStoredNisn() ?? _storage.read<String>('nisn');
    if (nisn == null || nisn.isEmpty) {
      return;
    }

    try {
      final today = _dateFormatter.format(DateTime.now());
      final records = await _attendanceService.getStudentHistory(
        nisn,
        startDate: today,
        endDate: today,
        limit: 1,
      );

      if (records.isNotEmpty) {
        final label = _humanStatus(records.first['status']);
        childTodayStatus.value = label;
        _updateChildStatus(statusLabel: label);
      } else {
        childTodayStatus.value = 'Belum absen';
        _updateChildStatus(statusLabel: 'Belum absen');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat status ananda: $e');
    }
  }

  String _humanStatus(dynamic status) {
    switch ((status ?? '').toString().toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'sakit':
        return 'Sakit';
      case 'izin':
        return 'Izin';
      case 'alpa':
        return 'Alpa';
      default:
        return 'Belum absen';
    }
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

  void goToNotifications() {
    currentActionView.value = const NotificationListView();
  }

  // --- MODIFIKASI FUNGSI INI ---
  void goToAnnouncementDetail(String announcementId) {
    if (kDebugMode) {
      print('DEBUG: HomeController received announcement ID: $announcementId');
    }
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
