// lib/app/modules/student_detail/student_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/attendance_state_manager.dart';
import '../home/home_controller.dart';
import '../student_list/student_list_controller.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class StudentDetailController extends GetxController {
  // Gunakan Rx<Student?> agar bisa null-check
  final Rx<Student?> student = Rx<Student?>(null);
  late final StudentService _studentService;
  late final AttendanceService _attendanceService;
  late final AttendanceStateManager _attendanceStateManager;

  final RxBool isLoadingAttendance = false.obs;
  final Rxn<Map<String, dynamic>> todayAttendance = Rxn<Map<String, dynamic>>();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _studentService = Get.find<StudentService>();
    _attendanceService = Get.find<AttendanceService>();
    _api = Get.find<ApiClient>();
    _attendanceStateManager = Get.find<AttendanceStateManager>();

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
    final idStr = student.value?.id;
    if (idStr == null) return;

    final studentId = int.tryParse(idStr);
    if (studentId == null) return;

    isLoadingAttendance.value = true;
    try {
      // Try to get from shared state manager first
      var attendance = _attendanceStateManager.getTodayAttendance(studentId);

      // If not cached, fetch from API
      attendance ??= await _attendanceStateManager.fetchTodayAttendance(
        studentId,
      );

      todayAttendance.value = attendance;
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat status kehadiran: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  /// Public method to force refresh today's attendance. Call this whenever
  /// the page is shown to ensure the UI displays the latest data.
  Future<void> refreshTodayAttendance() async => await _fetchTodayAttendance();

  Student _mapToStudent(Map<String, dynamic> data, Student current) {
    return Student(
      id: (data['id'] ?? current.id).toString(),
      name: (data['name'] as String?) ?? current.name,
      studentClass: data['kelas'] is Map<String, dynamic>
          ? data['kelas']['name'] ?? current.studentClass
          : (data['class_name'] as String?) ?? current.studentClass,
      parentName: data['parent'] is Map<String, dynamic>
          ? () {
              final parent = data['parent'] as Map<String, dynamic>;

              // Prefer parent's associated user name if present
              if (parent['user'] is Map<String, dynamic>) {
                final user = parent['user'] as Map<String, dynamic>;
                return (user['name'] ?? user['nama'] ?? current.parentName)
                    as String;
              }

              // Fallback to father/mother/guardian names on parent model
              return (parent['father_name'] ??
                      parent['mother_name'] ??
                      parent['guardian_name'] ??
                      current.parentName)
                  as String;
            }()
          : current.parentName,
      // Parent contact fallback (prefer parent.user -> parent model -> top-level fields)
      fatherPhone: data['parent'] is Map<String, dynamic>
          ? (data['parent']['father_phone'] ??
                    data['parent']['fatherPhone'] ??
                    (data['parent']['user'] is Map
                        ? data['parent']['user']['phone']
                        : null) ??
                    data['father_phone'] ??
                    current.fatherPhone)
                as String?
          : (data['father_phone'] as String?) ?? current.fatherPhone,
      motherPhone: data['parent'] is Map<String, dynamic>
          ? (data['parent']['mother_phone'] ??
                    data['parent']['motherPhone'] ??
                    (data['parent']['user'] is Map
                        ? data['parent']['user']['phone']
                        : null) ??
                    data['mother_phone'] ??
                    current.motherPhone)
                as String?
          : (data['mother_phone'] as String?) ?? current.motherPhone,
      photoUrl: () {
        final raw =
            data['photo_url'] as String? ??
            data['avatar'] as String? ??
            data['photo'] as String?;
        if (raw != null && raw.isNotEmpty) {
          try {
            final normalized = raw.startsWith('http')
                ? raw
                : _api.buildFullUrl(raw);

            return normalized;
          } catch (e) {
            return raw;
          }
        }
        // Also try nested parent.student.photo_url fallback
        try {
          final parent = data['parent'] as Map<String, dynamic>?;
          final nested = parent != null
              ? (parent['student'] as Map<String, dynamic>?)
              : null;
          final nestedRaw = nested != null
              ? (nested['photo_url'] as String?)
              : null;
          if (nestedRaw != null && nestedRaw.isNotEmpty) {
            final normalized = nestedRaw.startsWith('http')
                ? nestedRaw
                : _api.buildFullUrl(nestedRaw);

            return normalized;
          }
        } catch (_) {}

        return current.photoUrl;
      }(),
      dailyStatus: current.dailyStatus,
      nisn: (data['nisn'] as String?) ?? current.nisn,
      nis: (data['nis'] as String?) ?? current.nis,
      gender: (data['gender'] as String?) ?? current.gender,
      birthPlace: (data['birth_place'] as String?) ?? current.birthPlace,
      birthDate: current.birthDate,
      religion: (data['religion'] as String?) ?? current.religion,
      address: (data['address'] as String?) ?? current.address,
      fatherName: data['parent'] is Map<String, dynamic>
          ? (data['parent']['father_name'] ??
                    data['parent']['fatherName'] ??
                    data['father_name'] ??
                    current.fatherName)
                as String?
          : (data['father_name'] as String?) ?? current.fatherName,
      motherName: data['parent'] is Map<String, dynamic>
          ? (data['parent']['mother_name'] ??
                    data['parent']['motherName'] ??
                    data['mother_name'] ??
                    current.motherName)
                as String?
          : (data['mother_name'] as String?) ?? current.motherName,
      fatherJob: data['parent'] is Map<String, dynamic>
          ? (data['parent']['father_job'] ??
                    data['parent']['fatherJob'] ??
                    data['father_job'] ??
                    current.fatherJob)
                as String?
          : (data['father_job'] as String?) ?? current.fatherJob,
      motherJob: data['parent'] is Map<String, dynamic>
          ? (data['parent']['mother_job'] ??
                    data['parent']['motherJob'] ??
                    data['mother_job'] ??
                    current.motherJob)
                as String?
          : (data['mother_job'] as String?) ?? current.motherJob,
      guardianName: data['parent'] is Map<String, dynamic>
          ? (data['parent']['guardian_name'] ??
                    data['parent']['guardianName'] ??
                    data['guardian_name'] ??
                    current.guardianName)
                as String?
          : (data['guardian_name'] as String?) ?? current.guardianName,
      guardianJob: data['parent'] is Map<String, dynamic>
          ? (data['parent']['guardian_job'] ??
                    data['parent']['guardianJob'] ??
                    data['guardian_job'] ??
                    current.guardianJob)
                as String?
          : (data['guardian_job'] as String?) ?? current.guardianJob,
      guardianPhone: data['parent'] is Map<String, dynamic>
          ? (data['parent']['guardian_phone'] ??
                    data['parent']['guardianPhone'] ??
                    data['guardian_phone'] ??
                    current.guardianPhone)
                as String?
          : (data['guardian_phone'] as String?) ?? current.guardianPhone,
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
                initialValue: selectedStatus.value,
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
                  // Update existing attendance record if we have an id; otherwise create
                  final attendanceId = todayAttendance.value!['id'];
                  if (attendanceId == null) {
                    // Fallback: no id available, create instead
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
                    await _attendanceService.updateAttendance(attendanceId, {
                      'status': selectedStatus.value,
                      'notes': notesController.text.trim(),
                    });
                    SnackbarHelper.showSuccess(
                      'Status kehadiran berhasil diubah',
                    );
                  }
                }

                // Force refresh attendance data from server (do not rely on cached value)
                final refreshed = await _attendanceStateManager
                    .fetchTodayAttendance(studentId);
                todayAttendance.value = refreshed;

                // Sync to state manager using freshest data
                if (refreshed != null) {
                  await _attendanceStateManager.updateAttendance(
                    studentId,
                    refreshed,
                  );
                } else {
                  // If server returned no record, ensure cache is cleared
                  await _attendanceStateManager.updateAttendance(studentId, {});
                }

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
