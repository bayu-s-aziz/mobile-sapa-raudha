// lib/app/modules/student_detail/student_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import '../home/home_controller.dart';

class StudentDetailController extends GetxController {
  // Gunakan Rx<Student?> agar bisa null-check
  final Rx<Student?> student = Rx<Student?>(null);
  late final StudentService _studentService;

  @override
  void onInit() {
    super.onInit();
    _studentService = Get.find<StudentService>();
    // Ambil data Student yang dikirim sebagai argumen
    if (Get.arguments != null && Get.arguments is Student) {
      student.value = Get.arguments as Student;
      _refreshStudentFromServer();
    } else {
      // Handle jika data tidak ditemukan
      Get.back();
      Get.snackbar(
        'Error',
        'Gagal memuat data siswa. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _refreshStudentFromServer() async {
    if (student.value == null) return;
    final id = int.tryParse(student.value!.id);
    if (id == null) return;

    final detail = await _studentService.getStudentById(id);
    if (detail == null) return;

    student.value = _mapToStudent(detail, student.value!);
  }

  Student _mapToStudent(Map<String, dynamic> data, Student current) {
    return Student(
      id: (data['id'] ?? current.id).toString(),
      name: (data['name'] as String?) ?? current.name,
      studentClass: (data['class_name'] as String?) ?? current.studentClass,
      parentName: current.parentName,
      photoUrl: (data['photo_url'] as String?) ?? current.photoUrl,
      dailyStatus: current.dailyStatus,
      nisn: (data['nisn'] as String?) ?? current.nisn,
      nis: (data['nis'] as String?) ?? current.nis,
      gender: (data['gender'] as String?) ?? current.gender,
      birthPlace: (data['birth_place'] as String?) ?? current.birthPlace,
      birthDate: current.birthDate,
      religion: (data['religion'] as String?) ?? current.religion,
      address: (data['address'] as String?) ?? current.address,
      fatherName: data['father_name'] as String? ?? current.fatherName,
      motherName: data['mother_name'] as String? ?? current.motherName,
      fatherJob: data['father_job'] as String? ?? current.fatherJob,
      motherJob: data['mother_job'] as String? ?? current.motherJob,
      guardianName: data['guardian_name'] as String? ?? current.guardianName,
      guardianJob: data['guardian_job'] as String? ?? current.guardianJob,
      fatherPhone: data['father_phone'] as String? ?? current.fatherPhone,
      motherPhone: data['mother_phone'] as String? ?? current.motherPhone,
      guardianPhone: data['guardian_phone'] as String? ?? current.guardianPhone,
    );
  }

  // Placeholder untuk navigasi ke riwayat absensi spesifik siswa
  void goToStudentAttendanceHistory() {
    if (student.value == null) return;

    // Tutup halaman detail siswa dan tunggu hingga frame selesai
    Get.back();

    // Gunakan WidgetsBinding untuk memastikan navigasi selesai sebelum aksi berikutnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        home.changeTabIndex(0);

        // Delay kecil untuk memastikan tab sudah beralih
        Future.delayed(const Duration(milliseconds: 50), () {
          home.goToAttendanceHistory();
        });
      }
    });
  }

  // Placeholder untuk aksi lain
  void callParent() {
    final data = student.value;
    if (data == null) return;

    final phone = _pickAvailablePhone(data);
    if (phone == null) {
      Get.dialog(
        AlertDialog(
          title: const Text('Hubungi Orang Tua'),
          content: Text(
            'Nomor telepon orang tua untuk ${data.name} tidak tersedia.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
          ],
        ),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Hubungi Orang Tua'),
        content: Text('Gunakan nomor: $phone'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
        ],
      ),
    );
  }

  String? _pickAvailablePhone(Student data) {
    final candidates = [data.fatherPhone, data.motherPhone, data.guardianPhone];
    for (final phone in candidates) {
      final trimmed = phone?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
