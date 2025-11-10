// lib/app/modules/announcement_list/announcement_list_binding.dart
import 'package:get/get.dart';
import 'announcement_list_controller.dart';

class AnnouncementListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnnouncementListController>(() => AnnouncementListController());
  }
}
