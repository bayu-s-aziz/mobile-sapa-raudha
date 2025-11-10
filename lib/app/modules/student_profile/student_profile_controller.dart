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
    // Ini adalah data dummy berdasarkan apa yang ada di HomeController
    // Di aplikasi nyata, data ini akan diambil dari server berdasarkan ID ortu
    if (homeController.userRole.value == 'orangtua') {
      student.value = Student(
        id: 'S001', // Dummy ID
        name: 'Budi Santoso', // Dummy name (dari homeController.childStatus)
        studentClass: 'Kelas A', // Dummy class
        parentName: homeController.userName.value, // "Bapak Ortu Keren"
        dailyStatus:
            StudentDailyStatus.hadir, // (dari homeController.childStatus)
      );
    }
  }
}
