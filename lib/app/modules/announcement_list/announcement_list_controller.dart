// lib/app/modules/announcement_list/announcement_list_controller.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart'; // Impor rute

class AnnouncementListController extends GetxController {
  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>(); // Ambil service

  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  void fetchAnnouncements() {
    isLoading(true);
    // Simulasi delay
    Future.delayed(const Duration(milliseconds: 500), () {
      announcements.assignAll(_announcementService.getAllAnnouncements());
      isLoading(false);
    });
  }

  void goToDetail(String announcementId) {
    // Gunakan nama rute yang sudah didefinisikan
    Get.toNamed(Routes.announcementDetail, arguments: announcementId);
  }
}
