import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class AdminDashboardController extends GetxController {
  final StudentService _studentService = Get.find<StudentService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();
  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Statistics
  final RxInt totalStudents = 0.obs;
  final RxInt totalClasses = 0.obs;
  final RxInt totalParents = 0.obs;
  final RxInt totalAnnouncements = 0.obs;
  final RxInt pendingPasswordResets = 0.obs;

  // Today's attendance
  final RxInt hadirToday = 0.obs;
  final RxInt sakitToday = 0.obs;
  final RxInt izinToday = 0.obs;
  final RxInt alpaToday = 0.obs;
  final RxInt belumPresensi = 0.obs;
  final RxDouble attendancePercentage = 0.0.obs;

  // Weekly comparison
  final RxDouble weeklyAttendanceChange = 0.0.obs;

  // Recent activities
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;

  // Loading state
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
    fetchPendingPasswordResets();
  }

  Future<void> fetchPendingPasswordResets() async {
    try {
      final response = await _apiClient.get(
        '/api/password-reset-requests/pending-count',
      );
      pendingPasswordResets.value = response['count'] ?? 0;
    } catch (e) {
      pendingPasswordResets.value = 0;
    }
  }

  Future<void> fetchDashboardStats() async {
    isLoading(true);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Calculate last week date
      final lastWeekStart = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 7)));

      // Fetch students
      final students = await _studentService.getStudents();
      totalStudents.value = students.length;

      // Count unique parents (approximate)
      final parentIds = students
          .where((s) => s['father_name'] != null || s['mother_name'] != null)
          .length;
      totalParents.value = parentIds;

      // Fetch classes
      final classes = await _studentService.getClasses();
      totalClasses.value = classes.length;

      // Fetch announcements count
      try {
        final announcements = await _announcementService.getAllAnnouncements();
        totalAnnouncements.value = announcements.length;
      } catch (e) {
        totalAnnouncements.value = 0;
      }

      // Fetch today's attendance summary
      final summary = await _attendanceService.getAttendanceSummary(
        startDate: today,
        endDate: today,
      );

      // Safe conversion from dynamic to int
      hadirToday.value = _toInt(summary['hadir']);
      sakitToday.value = _toInt(summary['sakit']);
      izinToday.value = _toInt(summary['izin']);
      alpaToday.value = _toInt(summary['alpa']);

      // Calculate students who haven't checked in
      final totalPresent =
          hadirToday.value +
          sakitToday.value +
          izinToday.value +
          alpaToday.value;
      belumPresensi.value = totalStudents.value - totalPresent;

      // Calculate attendance percentage
      if (totalStudents.value > 0) {
        attendancePercentage.value =
            (hadirToday.value / totalStudents.value * 100);
      }

      // Fetch last week's attendance for comparison
      try {
        final lastWeekSummary = await _attendanceService.getAttendanceSummary(
          startDate: lastWeekStart,
          endDate: lastWeekStart,
        );
        final lastWeekHadir = _toInt(lastWeekSummary['hadir']);
        final lastWeekPercentage = totalStudents.value > 0
            ? (lastWeekHadir / totalStudents.value * 100)
            : 0.0;
        weeklyAttendanceChange.value =
            attendancePercentage.value - lastWeekPercentage;
      } catch (e) {
        weeklyAttendanceChange.value = 0.0;
      }

      // Generate recent activities
      _generateRecentActivities();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat statistik: $e');
    } finally {
      isLoading(false);
    }
  }

  void _generateRecentActivities() {
    recentActivities.clear();

    if (hadirToday.value > 0) {
      recentActivities.add({
        'title': '${hadirToday.value} siswa hadir hari ini',
        'subtitle':
            'Presensi - ${DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.now())}',
        'icon': Icons.check_circle,
        'color': AppColors.success,
      });
    }

    if (belumPresensi.value > 0) {
      recentActivities.add({
        'title': '${belumPresensi.value} siswa belum presensi',
        'subtitle': 'Perlu tindak lanjut',
        'icon': Icons.warning,
        'color': AppColors.warning,
      });
    }

    if (sakitToday.value > 0 || izinToday.value > 0) {
      recentActivities.add({
        'title': '${sakitToday.value + izinToday.value} siswa sakit/izin',
        'subtitle': 'Sakit: ${sakitToday.value}, Izin: ${izinToday.value}',
        'icon': Icons.info_outline,
        'color': AppColors.accent2,
      });
    }

    if (alpaToday.value > 0) {
      recentActivities.add({
        'title': '${alpaToday.value} siswa tidak hadir tanpa keterangan',
        'subtitle': 'Perlu konfirmasi',
        'icon': Icons.error_outline,
        'color': AppColors.error,
      });
    }

    recentActivities.add({
      'title': 'Total ${totalStudents.value} siswa terdaftar',
      'subtitle': 'Tersebar di ${totalClasses.value} kelas',
      'icon': Icons.school,
      'color': AppColors.accent1,
    });

    if (totalAnnouncements.value > 0) {
      recentActivities.add({
        'title': '${totalAnnouncements.value} pengumuman aktif',
        'subtitle': 'Dapat dilihat oleh semua pengguna',
        'icon': Icons.campaign,
        'color': AppColors.accent3,
      });
    }
  }

  // Helper method to safely convert dynamic to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}
