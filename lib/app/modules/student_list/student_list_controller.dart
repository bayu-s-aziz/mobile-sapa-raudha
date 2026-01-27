// lib/app/modules/student_list/student_list_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class StudentListController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Student> allStudents = <Student>[].obs;
  final RxList<Student> filteredStudents = <Student>[].obs;

  final TextEditingController searchController = TextEditingController();
  final RxString selectedGroup = 'A,B'.obs; // default to show both A and B
  late final StudentService _studentService;

  @override
  void onInit() {
    super.onInit();
    _studentService = Get.find<StudentService>();
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
        return Student(
          id: data['id'].toString(),
          name: data['name'] ?? '',
          studentClass: data['class_name'] ?? 'Belum ada kelas',
          parentName: data['father_name'] ?? data['mother_name'] ?? 'N/A',
          dailyStatus: _parseStatus(data['daily_status']),
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
          photoUrl: data['photo_url'],
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
