// lib/app/modules/student_profile/student_profile_binding.dart
import 'package:get/get.dart';
import 'student_profile_controller.dart';

class StudentProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentProfileController>(() => StudentProfileController());
  }
}
