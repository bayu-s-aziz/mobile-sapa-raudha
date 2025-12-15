import 'package:get/get.dart';
import 'admin_teacher_form_controller.dart';

class AdminTeacherFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminTeacherFormController>(() => AdminTeacherFormController());
  }
}
