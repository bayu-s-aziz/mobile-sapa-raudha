// lib/app/modules/announcement_detail/announcement_detail_controller.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';

class AnnouncementDetailController extends GetxController {
  // --- TAMBAHKAN CONSTRUCTOR INI ---
  final String? passedAnnouncementId;
  AnnouncementDetailController({this.passedAnnouncementId});
  // --- AKHIR TAMBAHAN ---

  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();

  final RxBool isLoading = true.obs;
  final Rxn<Announcement> announcement = Rxn<Announcement>();

  @override
  void onInit() {
    super.onInit();
    // --- MODIFIKASI LOGIKA onInit ---
    // Gunakan ID dari constructor (passedAnnouncementId)
    // sebagai prioritas utama
    final String? announcementId =
        passedAnnouncementId ?? (Get.arguments as String?);

    if (announcementId != null) {
      fetchAnnouncementDetail(announcementId);
    } else {
      isLoading.value = false;
      announcement.value = null;
      // Opsional: Tampilkan error
    }
    // --- AKHIR MODIFIKASI ---
  }

  void fetchAnnouncementDetail(String id) {
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      announcement.value = _announcementService.getAnnouncementById(id);
      isLoading.value = false;
    });
  }
}
