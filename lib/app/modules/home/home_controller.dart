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
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_state_manager.dart';
import 'dart:developer' as developer;
import '../student_list/student_list_controller.dart';

// --- TAMBAHKAN IMPOR UNTUK ACTION VIEWS ---
import '../create_announcement/create_announcement_view.dart';
import '../confirm_leave/confirm_leave_view.dart';
import '../student_profile/student_profile_view.dart';
import '../attendance_history/attendance_history_view.dart';
import '../announcement_detail/announcement_detail_view.dart';
import '../notification_list/notification_list_view.dart';
// --- AKHIR TAMBAHAN ---

class HomeController extends GetxController with WidgetsBindingObserver {
  final RxString userRole = ''.obs;
  final RxString userName = ''.obs;
  final RxString childStatus = ''.obs;
  final RxString childName = ''.obs;
  final RxString childClass = ''.obs;
  // Default status anak di dashboard orang tua
  final RxString childTodayStatus = 'Belum absen'.obs;

  final RxInt selectedIndex = 0.obs;

  // State untuk menampung view aksi (seperti Buat Pengumuman, dll)
  final Rxn<Widget> currentActionView = Rxn<Widget>();

  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();
  late final ProfileService _profileService = Get.find<ProfileService>();
  late final AttendanceService _attendanceService =
      Get.find<AttendanceService>();
  late final AttendanceStateManager _attendanceStateManager =
      Get.find<AttendanceStateManager>();
  late final StudentService _studentService = Get.find<StudentService>();
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

    // Register lifecycle observer to refresh data when app resumes
    WidgetsBinding.instance.addObserver(this);

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
    final raw = statusLabel ?? childTodayStatus.value;
    final status = (raw.isNotEmpty) ? raw : 'Belum absen';
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
    // Try to determine student ID from cached profile first (safer than relying on NISN)
    final profile = _profileService.getStoredProfile();
    int? studentId;
    if (profile != null) {
      final student = profile['userable'] is Map
          ? profile['userable']['student']
          : null;
      if (student is Map && student['id'] != null) {
        final id = student['id'];
        studentId = id is int ? id : int.tryParse(id?.toString() ?? '');
      }
      studentId ??= profile['student_id'] is int
          ? profile['student_id'] as int
          : (profile['student_id'] is String
                ? int.tryParse(profile['student_id'])
                : null);
      studentId ??= profile['anak'] is Map && profile['anak']['id'] != null
          ? (profile['anak']['id'] is int
                ? profile['anak']['id'] as int
                : int.tryParse(profile['anak']['id'].toString()))
          : null;
    }

    // Fallback: if no studentId, try stored NISN
    final nisn =
        _profileService.getStoredNisn() ?? _storage.read<String>('nisn');
    if (studentId == null && (nisn == null || nisn.isEmpty)) {
      return;
    }

    try {
      final today = _dateFormatter.format(DateTime.now());

      // Cek cache lokal dulu (AttendanceStateManager) karena student id adalah kunci yang reliable
      if (studentId != null) {
        // Coba ambil dari cache terlebih dahulu
        var localAttendance = _attendanceStateManager.getTodayAttendance(
          studentId,
        );
        developer.log(
          'HomeController: localAttendance (before fetch) for studentId=$studentId => $localAttendance',
          name: 'HomeController',
        );
        if (localAttendance == null) {
          // Jika belum ada di cache, fetch dari API untuk student ini dan cache
          try {
            localAttendance = await _attendanceStateManager
                .fetchTodayAttendance(studentId);
            developer.log(
              'HomeController: fetched attendance for studentId=$studentId => $localAttendance',
              name: 'HomeController',
            );
          } catch (e) {
            developer.log(
              'HomeController: error fetching attendance for studentId=$studentId: $e',
              name: 'HomeController',
            );
            localAttendance = null;
          }
        }
        if (localAttendance != null) {
          final label = _humanStatus(localAttendance['status']);
          childTodayStatus.value = label;
          _updateChildStatus(statusLabel: label);
          return;
        }
      } else if (nisn != null && nisn.isNotEmpty) {
        // Coba resolve studentId dari NISN agar bisa cek cache
        try {
          final student = await _studentService.getStudentByNisn(nisn);
          developer.log(
            'HomeController: resolved student from nisn=$nisn => $student',
            name: 'HomeController',
          );
          if (student != null && student['id'] != null) {
            final sid = student['id'] is int
                ? student['id'] as int
                : int.tryParse(student['id'].toString());
            if (sid != null) {
              var localAttendance = _attendanceStateManager.getTodayAttendance(
                sid,
              );
              developer.log(
                'HomeController: localAttendance (by sid) for sid=$sid => $localAttendance',
                name: 'HomeController',
              );
              if (localAttendance == null) {
                try {
                  localAttendance = await _attendanceStateManager
                      .fetchTodayAttendance(sid);
                  developer.log(
                    'HomeController: fetched attendance for sid=$sid => $localAttendance',
                    name: 'HomeController',
                  );
                } catch (e) {
                  developer.log(
                    'HomeController: error fetching attendance for sid=$sid: $e',
                    name: 'HomeController',
                  );
                  localAttendance = null;
                }
              }

              if (localAttendance != null) {
                final label = _humanStatus(localAttendance['status']);
                childTodayStatus.value = label;
                _updateChildStatus(statusLabel: label);
                return;
              }
            }
          } else {
            developer.log(
              'HomeController: no student found for nisn=$nisn',
              name: 'HomeController',
            );
          }
        } catch (e) {
          developer.log(
            'HomeController: error resolving student by nisn=$nisn: $e',
            name: 'HomeController',
          );
        }
      }

      // Jika tidak ada di cache, lakukan panggilan API spesifik ke service
      final records = await _attendanceService.getStudentHistory(
        studentId ?? nisn,
        startDate: today,
        endDate: today,
        limit: 1,
      );

      if (records.isNotEmpty) {
        final label = _humanStatus(records.first['status']);
        childTodayStatus.value = label;
        _updateChildStatus(statusLabel: label);
        return;
      }

      // Tidak ada record presensi hari ini — periksa pengajuan izin yang mencakup hari ini
      try {
        // Gunakan studentId yang telah difetch dari profile jika ada
        int? sid = studentId;
        if (sid == null && nisn != null && nisn.isNotEmpty) {
          final student = await _studentService.getStudentByNisn(nisn);
          if (student != null && student['id'] != null) {
            sid = student['id'] is int
                ? student['id'] as int
                : int.tryParse(student['id'].toString());
          }
        }

        if (sid != null) {
          final leaves = await _leaveService.getByStudent(sid);
          if (leaves.isNotEmpty) {
            for (final item in leaves) {
              final startRaw =
                  item['start_date'] ?? item['request_date'] ?? item['date'];
              final endRaw =
                  item['end_date'] ?? item['request_date'] ?? item['date'];

              DateTime? s;
              DateTime? e;
              try {
                s = startRaw != null
                    ? DateTime.parse(startRaw.toString())
                    : null;
              } catch (_) {
                s = null;
              }
              try {
                e = endRaw != null ? DateTime.parse(endRaw.toString()) : null;
              } catch (_) {
                e = null;
              }

              final todayDt = DateTime.parse(today);
              final coversToday =
                  (s != null &&
                      e != null &&
                      !todayDt.isBefore(s) &&
                      !todayDt.isAfter(e)) ||
                  (s != null &&
                      e == null &&
                      s.year == todayDt.year &&
                      s.month == todayDt.month &&
                      s.day == todayDt.day) ||
                  (s == null &&
                      e == null &&
                      (item['request_date']?.toString() == today));

              if (!coversToday) continue;

              final status = (item['status'] ?? '').toString().toLowerCase();
              String label;
              if (status == 'approved') {
                final ltype = (item['leave_type'] ?? item['type'] ?? '')
                    .toString()
                    .toLowerCase();
                final reason = (item['reason'] ?? '').toString().toLowerCase();
                if (ltype.contains('sakit') || reason.contains('sakit')) {
                  label = 'Sakit';
                } else {
                  label = 'Izin';
                }
              } else if (status == 'pending') {
                label = 'Izin (Menunggu)';
              } else {
                continue; // rejected or other
              }

              childTodayStatus.value = label;
              _updateChildStatus(statusLabel: label);
              return;
            }
          }
        }
      } catch (_) {}

      childTodayStatus.value = 'Belum absen';
      _updateChildStatus(statusLabel: 'Belum absen');
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

    // Prepare tab change: for student list, make sure attendance & students are reloaded
    _prepareTabChange(index);
  }

  // Helper to prepare the tab change and perform async reloads
  void _prepareTabChange(int index) async {
    try {
      if (index == 2 && userRole.value == 'guru') {
        if (Get.isRegistered<AttendanceStateManager>()) {
          await Get.find<AttendanceStateManager>().fetchAllTodayAttendance();
        }
        if (Get.isRegistered<StudentListController>()) {
          await Get.find<StudentListController>().fetchStudents();
        }
      }
    } catch (_) {}

    // Finally set the selected index so the view becomes visible
    selectedIndex.value = index;
  }

  // --- MODIFIKASI FUNGSI INI ---
  void clearActionView() {
    currentActionView.value = null;
    // Get.arguments = null; // <-- HAPUS BARIS INI (PENYEBAB ERROR)
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && userRole.value == 'orangtua') {
      // Saat aplikasi kembali ke foreground, sinkronkan status anak hari ini
      fetchChildTodayStatus();
    }
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
