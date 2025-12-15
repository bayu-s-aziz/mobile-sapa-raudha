import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class AdminStudentManagementController extends GetxController {
  final StudentService _studentService = Get.find<StudentService>();

  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredStudents =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final Rxn<int> selectedClassFilter = Rxn<int>();

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_filterStudents);
    fetchClasses();
    fetchStudents();
  }

  Future<void> fetchClasses() async {
    try {
      final data = await _studentService.getClasses();
      classes.assignAll(data);
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data kelas: $e');
    }
  }

  Future<void> fetchStudents() async {
    isLoading(true);
    try {
      final data = await _studentService.getStudents();
      students.assignAll(data);
      filteredStudents.assignAll(data);
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data siswa: $e');
    } finally {
      isLoading(false);
    }
  }

  void _filterStudents() {
    final query = searchController.text.toLowerCase();
    final classId = selectedClassFilter.value;

    var filtered = students.where((student) {
      final matchesSearch =
          query.isEmpty ||
          (student['name'] ?? '').toLowerCase().contains(query) ||
          (student['nisn'] ?? '').toLowerCase().contains(query) ||
          (student['class_name'] ?? '').toLowerCase().contains(query);

      final matchesClass = classId == null || student['class_id'] == classId;

      return matchesSearch && matchesClass;
    }).toList();

    filteredStudents.assignAll(filtered);
  }

  void filterByClass(int? classId) {
    selectedClassFilter.value = classId;
    _filterStudents();
  }

  void deleteStudent(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus siswa ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _studentService.deleteStudent(id);
                Get.back();
                SnackbarHelper.showSuccess('Siswa berhasil dihapus');
                fetchStudents();
              } catch (e) {
                Get.back();
                SnackbarHelper.showError('Gagal menghapus siswa: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
