import 'package:get/get.dart';
import 'admin_user_management_controller.dart';

class AdminUserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserManagementController>(
      () => AdminUserManagementController(),
    );
  }
}
