// lib/app/modules/student_profile/student_profile_controller.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_state_manager.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class StudentProfileController extends GetxController {
  final Rx<Student?> student = Rx<Student?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  late final ProfileService _profileService = Get.find<ProfileService>();
  late final StudentService _studentService = Get.find<StudentService>();
  late final AttendanceStateManager _attendanceStateManager =
      Get.find<AttendanceStateManager>();
  final Rxn<Map<String, dynamic>> todayAttendance = Rxn<Map<String, dynamic>>();
  late final LocalStorageService _storage = Get.find<LocalStorageService>();

  @override
  void onInit() {
    super.onInit();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    isLoading(true);
    errorMessage('');

    try {
      Map<String, dynamic>? profile = _profileService.getStoredProfile();
      if (profile == null || profile.isEmpty) {
        profile = await _profileService.fetchProfile();
      }

      // Coba ambil NISN dengan multiple fallback
      String? nisn = profile['nisn'] as String?;
      if (nisn == null || nisn.isEmpty) {
        nisn = _profileService.getStoredNisn();
      }
      if (nisn == null || nisn.isEmpty) {
        nisn = _storage.read<String>('nisn');
      }
      if (nisn == null || nisn.isEmpty) {
        throw Exception(
          'NISN anak tidak ditemukan. Pastikan data anak sudah terdaftar.',
        );
      }

      final detail = await _studentService.getStudentByNisn(nisn);
      if (detail == null) {
        throw Exception('Data siswa tidak ditemukan untuk NISN: $nisn.');
      }

      student.value = _mapToStudent(detail, profile);

      // Setelah detail student didapat, fetch today's attendance untuk ditampilkan
      final id = int.tryParse(student.value!.id);
      if (id != null) {
        try {
          final attendance = await _attendanceStateManager.fetchTodayAttendance(
            id,
          );
          todayAttendance.value = attendance;
        } catch (_) {
          todayAttendance.value = null;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      SnackbarHelper.showError('Gagal memuat profil ananda: $e');
    } finally {
      isLoading(false);
    }
  }

  Student _mapToStudent(
    Map<String, dynamic> data,
    Map<String, dynamic> profile,
  ) {
    final parent = data['parent'] as Map<String, dynamic>?;
    final parentUser = parent != null && parent['user'] is Map<String, dynamic>
        ? parent['user'] as Map<String, dynamic>
        : null;

    return Student(
      id: data['id'].toString(),
      name: (data['name'] as String?) ?? '-',
      studentClass:
          (data['class_name'] as String?) ??
          ((data['kelas'] != null && data['kelas'] is Map)
              ? (data['kelas']['name'] as String?)
              : null) ??
          (profile['class_name'] as String?) ??
          (profile['kelas'] as String?) ??
          '-',
      parentName:
          (parent?['father_name'] as String?) ??
          (parent?['mother_name'] as String?) ??
          (parentUser?['name'] as String?) ??
          (profile['father_name'] as String?) ??
          (profile['mother_name'] as String?) ??
          '-',
      photoUrl: data['photo_url'] as String?,
      dailyStatus: StudentDailyStatus.belumHadir,
      nisn: data['nisn']?.toString(),
      nis: data['nis']?.toString(),
      gender: _mapGender(data['gender']),
      birthPlace: data['birth_place'] as String?,
      birthDate: _parseDate(data['birth_date']),
      religion: data['religion'] as String?,
      address: data['address'] as String?,
      fatherName:
          (parent?['father_name'] as String?) ??
          (profile['father_name'] as String?) ??
          (data['father_name'] as String?),
      motherName:
          (parent?['mother_name'] as String?) ??
          (profile['mother_name'] as String?) ??
          (data['mother_name'] as String?),
      fatherJob:
          (parent?['father_job'] as String?) ??
          (profile['father_job'] as String?),
      motherJob:
          (parent?['mother_job'] as String?) ??
          (profile['mother_job'] as String?),
      guardianName:
          (parent?['guardian_name'] as String?) ??
          (profile['guardian_name'] as String?),
      guardianJob:
          (parent?['guardian_job'] as String?) ??
          (profile['guardian_job'] as String?),
      fatherPhone:
          (parent?['father_phone'] as String?) ??
          (data['father_phone'] as String?),
      motherPhone:
          (parent?['mother_phone'] as String?) ??
          (data['mother_phone'] as String?),
      guardianPhone:
          (parent?['guardian_phone'] as String?) ??
          (data['guardian_phone'] as String?),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  String? _mapGender(dynamic value) {
    switch ((value ?? '').toString().toUpperCase()) {
      case 'L':
        return 'Laki-laki';
      case 'P':
        return 'Perempuan';
      default:
        return null;
    }
  }
}
