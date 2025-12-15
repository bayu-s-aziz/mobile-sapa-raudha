import 'package:get/get.dart';
import 'admin_attendance_management_controller.dart';

class AdminAttendanceManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminAttendanceManagementController>(
      () => AdminAttendanceManagementController(),
    );
  }
}
