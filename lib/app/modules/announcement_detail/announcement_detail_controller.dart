// lib/app/modules/announcement_detail/announcement_detail_controller.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementDetailController extends GetxController {
  // --- TAMBAHKAN CONSTRUCTOR INI ---
  final String? passedAnnouncementId;
  AnnouncementDetailController({this.passedAnnouncementId});
  // --- AKHIR TAMBAHAN ---

  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();

  final RxBool isLoading = true.obs;
  final Rxn<Announcement> announcement = Rxn<Announcement>();
  final Rxn<Map<String, dynamic>> rawAnnouncement = Rxn<Map<String, dynamic>>();

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
      rawAnnouncement.value = null;
      // Opsional: Tampilkan error
    }
    // --- AKHIR MODIFIKASI ---
  }

  void fetchAnnouncementDetail(String id) async {
    if (kDebugMode) {
      print('DEBUG: Fetching announcement detail for ID: $id');
    }
    isLoading.value = true;
    try {
      // Fetch raw map first so we can debug attachment shapes
      final map = await _announcementService.getById(id);
      if (map == null) {
        announcement.value = null;
        rawAnnouncement.value = null;
        SnackbarHelper.showError('Pengumuman tidak ditemukan');
        return;
      }
      // Save raw for UI debugging
      rawAnnouncement.value = Map<String, dynamic>.from(map);
      developer.log(
        'AnnouncementDetail: raw response=$map',
        name: 'AnnouncementDetail',
      );

      // Normalize attachments if backend uses 'files' or single-field keys
      final hasAttachmentsList =
          map['attachments'] is List && (map['attachments'] as List).isNotEmpty;
      if (!hasAttachmentsList) {
        if (map['files'] is List && (map['files'] as List).isNotEmpty) {
          map['attachments'] = map['files'];
        } else {
          final List<Map<String, dynamic>> built = [];

          void addCandidate(dynamic urlField, [dynamic nameField]) {
            if (urlField == null) return;
            if (urlField is String && urlField.isNotEmpty) {
              built.add({
                'file_url': urlField,
                'file_name': (nameField is String && nameField.isNotEmpty)
                    ? nameField
                    : urlField.split('/').last,
              });
            }
          }

          addCandidate(
            map['attachment'] ??
                map['attachment_url'] ??
                map['file'] ??
                map['file_path'] ??
                map['path'] ??
                map['url'],
            map['attachment_name'] ?? map['file_name'],
          );
          addCandidate(
            map['image'] ?? map['image_url'],
            map['image_name'] ?? map['title'],
          );

          if (built.isNotEmpty) map['attachments'] = built;
        }
      }

      developer.log(
        'AnnouncementDetail: normalized attachments=${map['attachments']}',
        name: 'AnnouncementDetail',
      );

      announcement.value = Announcement.fromJson(
        Map<String, dynamic>.from(map),
      );
      // Tandai pengumuman sebagai sudah dibaca
      markAsRead();
    } catch (error) {
      announcement.value = null;
      rawAnnouncement.value = null;
      SnackbarHelper.showError('Gagal memuat pengumuman: $error');
    } finally {
      isLoading.value = false;
    }
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

  // --- TAMBAH: Method untuk membuka lampiran ---
  void openAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SnackbarHelper.showError('Tidak dapat membuka lampiran');
    }
  }
}
