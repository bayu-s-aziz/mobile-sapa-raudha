// lib/app/modules/announcement_detail/announcement_detail_controller.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';

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

    if (kDebugMode) {
      print(
        'DEBUG: AnnouncementDetailController initialized with ID: $announcementId',
      );
    }

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
    if (kDebugMode) {
      print('DEBUG: Fetching announcement detail for ID: $id');
    }
    isLoading.value = true;
    _announcementService
        .getAnnouncementById(id)
        .then((value) {
          announcement.value = value;
          // Tandai pengumuman sebagai sudah dibaca
          markAsRead();
        })
        .catchError((error) {
          announcement.value = null;
          Get.snackbar(
            'Error',
            'Gagal memuat pengumuman: ${error.toString()}',
            snackPosition: SnackPosition.BOTTOM,
          );
        })
        .whenComplete(() => isLoading.value = false);
  }

  // --- TAMBAH: Method untuk tandai pengumuman sebagai dibaca ---
  void markAsRead() {
    if (announcement.value != null) {
      // Update status isRead di Home controller
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : null;

      if (homeController != null) {
        final index = homeController.recentAnnouncements.indexWhere(
          (a) => a.id == announcement.value!.id,
        );
        if (index >= 0) {
          final updatedAnnouncement = Announcement(
            id: announcement.value!.id,
            title: announcement.value!.title,
            content: announcement.value!.content,
            timestamp: announcement.value!.timestamp,
            author: announcement.value!.author,
            attachmentName: announcement.value!.attachmentName,
            isRead: true,
          );
          homeController.recentAnnouncements[index] = updatedAnnouncement;
        }
      }
    }
  }

  // --- AKHIR TAMBAHAN ---
}
