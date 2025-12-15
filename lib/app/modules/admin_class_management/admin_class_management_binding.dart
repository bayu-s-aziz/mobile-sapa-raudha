import 'package:get/get.dart';
import 'admin_class_management_controller.dart';

class AdminClassManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminClassManagementController>(
      () => AdminClassManagementController(),
    );
  }
}
