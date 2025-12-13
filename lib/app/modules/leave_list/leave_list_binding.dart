import 'package:get/get.dart';
import 'leave_list_controller.dart';

class LeaveListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveListController>(() => LeaveListController());
  }
}
