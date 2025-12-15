// lib/app/modules/admin_announcement_management/admin_announcement_management_binding.dart

import 'package:get/get.dart';
import '../../data/services/announcement_service.dart';
import 'admin_announcement_management_controller.dart';

class AdminAnnouncementManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnnouncementService>(() => AnnouncementService());
    Get.lazyPut<AdminAnnouncementManagementController>(
      () => AdminAnnouncementManagementController(),
    );
  }
}
