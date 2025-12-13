// lib/app/modules/student_profile/student_profile_controller.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';

class StudentProfileController extends GetxController {
  final Rx<Student?> student = Rx<Student?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  late final ProfileService _profileService = Get.find<ProfileService>();
  late final StudentService _studentService = Get.find<StudentService>();

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

      final nisn = profile['nisn'] as String?;
      if (nisn == null) {
        throw Exception('NISN tidak ditemukan.');
      }

      final detail = await _studentService.getStudentByNisn(nisn);
      if (detail == null) {
        throw Exception('Data siswa tidak ditemukan.');
      }

      student.value = _mapToStudent(detail, profile);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Gagal memuat profil ananda: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Student _mapToStudent(
    Map<String, dynamic> data,
    Map<String, dynamic> profile,
  ) {
    return Student(
      id: data['id'].toString(),
      name: (data['name'] as String?) ?? '-',
      studentClass:
          (data['class_name'] as String?) ??
          (profile['class_name'] as String?) ??
          (profile['kelas'] as String?) ??
          '-',
      parentName:
          (profile['father_name'] as String?) ??
          (profile['mother_name'] as String?) ??
          (profile['name'] as String?) ??
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
          (profile['father_name'] as String?) ??
          (data['father_name'] as String?),
      motherName:
          (profile['mother_name'] as String?) ??
          (data['mother_name'] as String?),
      fatherJob: profile['father_job'] as String?,
      motherJob: profile['mother_job'] as String?,
      guardianName: profile['guardian_name'] as String?,
      guardianJob: profile['guardian_job'] as String?,
      fatherPhone: data['father_phone'] as String?,
      motherPhone: data['mother_phone'] as String?,
      guardianPhone: data['guardian_phone'] as String?,
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
