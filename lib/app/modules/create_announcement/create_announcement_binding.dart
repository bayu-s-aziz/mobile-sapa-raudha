// lib/app/modules/create_announcement/create_announcement_binding.dart
import 'package:get/get.dart';
import 'create_announcement_controller.dart';

class CreateAnnouncementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAnnouncementController>(
      () => CreateAnnouncementController(),
    );
  }
}
