// lib/app/modules/announcement_list/announcement_list_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';

class AnnouncementListController extends GetxController {
  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();
  late final HomeController _homeController;

  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<HomeController>()) {
      _homeController = Get.find<HomeController>();
    }
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    isLoading(true);
    try {
      final data = await _announcementService.getAllAnnouncements();
      announcements.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat pengumuman: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  void goToDetail(String announcementId) {
    if (kDebugMode) {
      print('DEBUG: Navigating to announcement with ID: $announcementId');
    }
    if (Get.isRegistered<HomeController>()) {
      _homeController.goToAnnouncementDetail(announcementId);
    }
  }
}
