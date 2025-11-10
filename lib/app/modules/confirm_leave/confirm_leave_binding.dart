// lib/app/modules/confirm_leave/confirm_leave_binding.dart
import 'package:get/get.dart';
import 'confirm_leave_controller.dart';

class ConfirmLeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmLeaveController>(() => ConfirmLeaveController());
  }
}
