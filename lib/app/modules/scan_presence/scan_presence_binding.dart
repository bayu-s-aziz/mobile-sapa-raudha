import 'package:get/get.dart';
import 'scan_presence_controller.dart';

class ScanPresenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanPresenceController>(() => ScanPresenceController());
  }
}
