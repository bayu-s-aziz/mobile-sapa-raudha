import 'package:get/get.dart';
import 'admin_password_reset_controller.dart';

class AdminPasswordResetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminPasswordResetController>(
      () => AdminPasswordResetController(),
    );
  }
}
