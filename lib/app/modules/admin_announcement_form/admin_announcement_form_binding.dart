// lib/app/modules/admin_announcement_form/admin_announcement_form_binding.dart

import 'package:get/get.dart';
import '../../data/services/announcement_service.dart';
import 'admin_announcement_form_controller.dart';

class AdminAnnouncementFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnnouncementService>(() => AnnouncementService());
    Get.lazyPut<AdminAnnouncementFormController>(
      () => AdminAnnouncementFormController(),
    );
  }
}
