// lib/app/modules/announcement_detail/announcement_detail_binding.dart
import 'package:get/get.dart';
import 'announcement_detail_controller.dart';

class AnnouncementDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnnouncementDetailController>(
      () => AnnouncementDetailController(),
    );
  }
}
