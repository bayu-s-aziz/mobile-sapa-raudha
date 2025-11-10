// lib/app/modules/student_list/student_list_binding.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/student_list/student_list_controller.dart';

class StudentListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentListController>(() => StudentListController());
  }
}
