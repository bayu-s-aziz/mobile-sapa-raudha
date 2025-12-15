import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/teacher_service.dart';
import 'package:sapa_raudha/app/data/services/parent_service.dart';
import 'admin_user_management_controller.dart';

class AdminUserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherService>(() => TeacherService());
    Get.lazyPut<ParentService>(() => ParentService());
    Get.lazyPut<AdminUserManagementController>(
      () => AdminUserManagementController(),
    );
  }
}
