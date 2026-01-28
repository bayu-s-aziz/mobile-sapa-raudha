// lib/app/modules/student_list/student_list_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/attendance_state_manager.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class StudentListController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Student> allStudents = <Student>[].obs;
  final RxList<Student> filteredStudents = <Student>[].obs;

  final TextEditingController searchController = TextEditingController();
  final RxString selectedGroup = 'A,B'.obs; // default to show both A and B
  late final StudentService _studentService;

  late final ApiClient _api;
  late final AttendanceStateManager _attendanceStateManager;

  /// Compute the effective daily status for a student.
  /// If a cached attendance record exists for today, use it.
  /// Otherwise, if current time in GMT+7 is after 00:01, return belumHadir.
  StudentDailyStatus _computeDailyStatus(int studentId, String? serverStatus) {
    final attendance = _attendanceStateManager.getTodayAttendance(studentId);
    if (attendance != null && attendance['status'] is String) {
      final s = (attendance['status'] as String).toLowerCase();
      switch (s) {
        case 'hadir':
          return StudentDailyStatus.hadir;
        case 'sakit':
          return StudentDailyStatus.sakit;
        case 'izin':
          return StudentDailyStatus.izin;
        case 'alpa':
        case 'alpha':
          return StudentDailyStatus.alpa;
        default:
          return StudentDailyStatus.belumHadir;
      }
    }

    // No attendance record cached for today. Determine if we are past 00:01 GMT+7
    final nowGmt7 = DateTime.now().toUtc().add(const Duration(hours: 7));
    final isAfterCutoff =
        nowGmt7.hour > 0 || (nowGmt7.hour == 0 && nowGmt7.minute >= 1);

    if (isAfterCutoff) {
      return StudentDailyStatus.belumHadir;
    }

    // Otherwise fallback to server-provided status
    return _parseStatus(serverStatus);
  }

  void _recomputeStudentStatuses() {
    final updated = allStudents.map((s) {
      final idInt = int.tryParse(s.id) ?? 0;
      final computed = _computeDailyStatus(idInt, null);
      return Student(
        id: s.id,
        name: s.name,
        studentClass: s.studentClass,
        parentName: s.parentName,
        dailyStatus: computed,
        nisn: s.nisn,
        nis: s.nis,
        gender: s.gender,
        birthPlace: s.birthPlace,
        birthDate: s.birthDate,
        religion: s.religion,
        address: s.address,
        fatherName: s.fatherName,
        motherName: s.motherName,
        fatherJob: s.fatherJob,
        motherJob: s.motherJob,
        guardianName: s.guardianName,
        fatherPhone: s.fatherPhone,
        motherPhone: s.motherPhone,
        guardianPhone: s.guardianPhone,
        photoUrl: s.photoUrl,
      );
    }).toList();

    allStudents.assignAll(updated);
    // Reapply current filter
    filterStudents(searchController.text);
  }

  @override
  void onInit() {
    super.onInit();
    _studentService = Get.find<StudentService>();
    _api = Get.find<ApiClient>();
    _attendanceStateManager = Get.find<AttendanceStateManager>();

    // Recompute statuses whenever today's attendance map changes
    ever(_attendanceStateManager.todayAttendanceMap, (_) {
      _recomputeStudentStatuses();
    });

    fetchStudents();
    // Listener untuk search
    searchController.addListener(() {
      filterStudents(searchController.text);
    });
  }

  Future<void> fetchStudents({String? group}) async {
    isLoading(true);
    try {
      // If group not provided, use selectedGroup default (which may be 'A,B')
      final usedGroup = group ?? selectedGroup.value;
      final studentsData = await _studentService.getStudents(group: usedGroup);

      final students = studentsData.map((data) {
        // Normalize photo URL when possible so Avatar gets an absolute URL
        final rawPhoto =
            data['photo_url'] as String? ??
            data['avatar'] as String? ??
            data['photo'] as String?;
        String? normalizedPhoto;
        try {
          if (rawPhoto != null && rawPhoto.isNotEmpty) {
            normalizedPhoto = rawPhoto.startsWith('http')
                ? rawPhoto
                : _api.buildFullUrl(rawPhoto);
          }
        } catch (e) {
          normalizedPhoto = rawPhoto;
        }

        final idRaw = data['id'];
        final idInt = idRaw is int
            ? idRaw
            : int.tryParse(idRaw?.toString() ?? '') ?? 0;
        final computedStatus = _computeDailyStatus(
          idInt,
          data['daily_status'] as String?,
        );

        return Student(
          id: data['id'].toString(),
          name: data['name'] ?? '',
          studentClass: data['class_name'] ?? 'Belum ada kelas',
          parentName: data['father_name'] ?? data['mother_name'] ?? 'N/A',
          dailyStatus: computedStatus,
          nisn: data['nisn'] ?? '',
          nis: data['nis'],
          gender: data['gender'] == 'L' ? 'Laki-laki' : 'Perempuan',
          birthPlace: data['birth_place'],
          birthDate: data['birth_date'] != null
              ? DateTime.tryParse(data['birth_date'])
              : null,
          religion: data['religion'],
          address: data['address'],
          fatherName: data['father_name'],
          motherName: data['mother_name'],
          fatherJob: data['father_job'],
          motherJob: data['mother_job'],
          guardianName: data['guardian_name'],
          fatherPhone: data['father_phone'],
          motherPhone: data['mother_phone'],
          guardianPhone: data['guardian_phone'],
          photoUrl: normalizedPhoto,
        );
      }).toList();

      allStudents.assignAll(students);
      filteredStudents.assignAll(students);
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data siswa: $e');
    } finally {
      isLoading(false);
    }
  }

  void setGroupFilter(String group) async {
    selectedGroup.value = group;
    // 'all' means no group filter server-side
    final usedGroup = group == 'all' ? null : group;
    await fetchStudents(group: usedGroup);
  }

  StudentDailyStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'hadir':
        return StudentDailyStatus.hadir;
      case 'sakit':
        return StudentDailyStatus.sakit;
      case 'izin':
        return StudentDailyStatus.izin;
      case 'alpa':
        return StudentDailyStatus.alpa;
      default:
        return StudentDailyStatus.belumHadir;
    }
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(allStudents);
    } else {
      filteredStudents.assignAll(
        allStudents
            .where(
              (student) =>
                  student.name.toLowerCase().contains(query.toLowerCase()) ||
                  student.studentClass.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  (student.nisn?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList(),
      );
    }
  }

  void goToStudentDetail(Student student) {
    Get.toNamed(Routes.studentDetail, arguments: student);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
