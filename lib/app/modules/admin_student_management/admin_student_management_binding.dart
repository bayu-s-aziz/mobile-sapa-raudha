import 'package:get/get.dart';
import 'admin_student_management_controller.dart';

class AdminStudentManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminStudentManagementController>(
      () => AdminStudentManagementController(),
    );
  }
}
