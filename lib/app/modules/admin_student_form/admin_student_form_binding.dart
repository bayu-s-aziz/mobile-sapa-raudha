import 'package:get/get.dart';
import 'admin_student_form_controller.dart';

class AdminStudentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminStudentFormController>(() => AdminStudentFormController());
  }
}
