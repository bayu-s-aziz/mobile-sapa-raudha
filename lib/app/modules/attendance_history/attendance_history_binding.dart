// lib/app/modules/attendance_history/attendance_history_binding.dart
import 'package:get/get.dart';
import 'attendance_history_controller.dart';

class AttendanceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceHistoryController>(
      () => AttendanceHistoryController(),
    );
  }
}
