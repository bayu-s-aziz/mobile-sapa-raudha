// lib/app/modules/student_detail/student_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import '../home/home_controller.dart';
import '../student_list/student_list_controller.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class StudentDetailController extends GetxController {
  // Gunakan Rx<Student?> agar bisa null-check
  final Rx<Student?> student = Rx<Student?>(null);
  late final StudentService _studentService;
  late final AttendanceService _attendanceService;

  final RxBool isLoadingAttendance = false.obs;
  final Rxn<Map<String, dynamic>> todayAttendance = Rxn<Map<String, dynamic>>();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    _studentService = Get.find<StudentService>();
    _attendanceService = Get.find<AttendanceService>();
    // Ambil data Student yang dikirim sebagai argumen
    if (Get.arguments != null && Get.arguments is Student) {
      student.value = Get.arguments as Student;
      _refreshStudentFromServer();
      _fetchTodayAttendance();
    } else {
      // Handle jika data tidak ditemukan
      Get.back();
      SnackbarHelper.showError('Gagal memuat data siswa. Silakan coba lagi.');
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

  Future<void> _fetchTodayAttendance() async {
    if (student.value?.nisn == null) return;

    isLoadingAttendance.value = true;
    try {
      final today = _dateFormatter.format(DateTime.now());
      final records = await _attendanceService.getStudentHistory(
        student.value!.nisn!,
        startDate: today,
        endDate: today,
        limit: 1,
      );

      if (records.isNotEmpty) {
        todayAttendance.value = records.first;
      } else {
        todayAttendance.value = null;
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat status kehadiran: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
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

  void updateAttendanceStatus() {
    if (student.value == null) return;

    final selectedStatus = Rxn<String>(todayAttendance.value?['status']);
    final notesController = TextEditingController(
      text: todayAttendance.value?['notes'] ?? '',
    );
    final isNewRecord = todayAttendance.value == null;

    Get.dialog(
      AlertDialog(
        title: Text(
          isNewRecord ? 'Tambah Presensi Hari Ini' : 'Ubah Status Kehadiran',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.value!.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'NISN: ${student.value!.nisn}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedStatus.value,
                decoration: const InputDecoration(
                  labelText: 'Status Kehadiran',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                  DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                  DropdownMenuItem(value: 'izin', child: Text('Izin')),
                  DropdownMenuItem(value: 'alpa', child: Text('Alpa')),
                ],
                onChanged: (value) => selectedStatus.value = value,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Keterangan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus.value == null) {
                SnackbarHelper.showError('Silakan pilih status kehadiran');
                return;
              }

              Get.back();
              isLoadingAttendance.value = true;

              try {
                final today = _dateFormatter.format(DateTime.now());
                final studentId = int.tryParse(student.value!.id);

                if (studentId == null) {
                  throw Exception('Invalid student ID');
                }

                if (isNewRecord) {
                  // Create new attendance record
                  await _attendanceService.createAttendance({
                    'student_id': studentId,
                    'date': today,
                    'status': selectedStatus.value,
                    'notes': notesController.text.trim(),
                  });
                  SnackbarHelper.showSuccess(
                    'Status kehadiran berhasil ditambahkan',
                  );
                } else {
                  // Update existing attendance record
                  final attendanceId = todayAttendance.value!['id'];
                  await _attendanceService.updateAttendance(attendanceId, {
                    'status': selectedStatus.value,
                    'notes': notesController.text.trim(),
                  });
                  SnackbarHelper.showSuccess(
                    'Status kehadiran berhasil diubah',
                  );
                }

                // Refresh attendance data
                await _fetchTodayAttendance();

                // Update home controller if registered
                if (Get.isRegistered<HomeController>()) {
                  final homeController = Get.find<HomeController>();
                  homeController.fetchAttendanceStats();
                }

                // Refresh student list if registered
                if (Get.isRegistered<StudentListController>()) {
                  final studentListController =
                      Get.find<StudentListController>();
                  studentListController.fetchStudents();
                }
              } catch (e) {
                SnackbarHelper.showError(
                  'Gagal menyimpan status kehadiran: $e',
                );
              } finally {
                isLoadingAttendance.value = false;
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
