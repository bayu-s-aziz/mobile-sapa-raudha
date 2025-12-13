// lib/app/modules/student_profile/student_profile_controller.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';

class StudentProfileController extends GetxController {
  // Dapatkan HomeController untuk mengambil data dummy
  final HomeController homeController = Get.find<HomeController>();

  final Rx<Student?> student = Rx<Student?>(null);

  @override
  void onInit() {
    super.onInit();
    loadStudentData();
  }

  void loadStudentData() {
    if (homeController.userRole.value == 'orangtua') {
      student.value = Student(
        id: 'S001',
        name: 'Budi Santoso',
        studentClass: 'Kelas A',
        parentName: 'Bapak Ortu Keren',
        dailyStatus: StudentDailyStatus.hadir,
        nisn: '1234567890',
        gender: 'Laki-laki',
        birthPlace: 'Surabaya',
        birthDate: DateTime(2019, 5, 12),
        religion: 'Islam',
        address: 'Jl. Mawar No. 10, Surabaya',
        fatherName: 'Bapak Ortu Keren',
        motherName: 'Ibu Ortu Hebat',
        fatherJob: 'Pegawai Swasta',
        motherJob: 'Ibu Rumah Tangga',
        guardianName: 'Paman Baik',
        guardianJob: 'Wiraswasta',
      );
    }
  }
}
