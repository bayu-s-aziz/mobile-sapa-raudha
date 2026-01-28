// lib/app/modules/create_announcement/create_announcement_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'package:sapa_raudha/app/modules/announcement_list/announcement_list_controller.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:file_picker/file_picker.dart'; // <-- IMPOR FILE PICKER
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class CreateAnnouncementController extends GetxController {
  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();
  late final HomeController _homeController;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  // State untuk menyimpan file yang dipilih
  final Rx<PlatformFile?> pickedFile = Rx<PlatformFile?>(
    null,
  ); // <-- TAMBAHKAN INI

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<HomeController>()) {
      _homeController = Get.find<HomeController>();
    } else {
      SnackbarHelper.showError('User data not found.');
      Get.back();
    }
  }

  // Method untuk memilih file
  Future<void> pickAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom, // Izinkan tipe kustom
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
        ], // Batasi ekstensi
      );

      if (result != null) {
        pickedFile.value = result.files.first; // Simpan file yang dipilih
      } else {
        // User membatalkan pemilihan
        SnackbarHelper.showInfo('Tidak ada file yang dipilih.');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memilih file: $e');
    }
  }

  // Method untuk menghapus file yang dipilih
  void clearAttachment() {
    pickedFile.value = null; // Hapus file
  }

  void submitAnnouncement() {
    if (formKey.currentState?.validate() ?? false) {
      isLoading(true);
      final attachmentPath = pickedFile.value?.path;

      _announcementService
          .addAnnouncement(
            title: titleController.text.trim(),
            content: contentController.text.trim(),
            attachment: attachmentPath != null ? File(attachmentPath) : null,
          )
          .then((_) {
            Get.back();
            SnackbarHelper.showSuccess('Pengumuman berhasil dipublikasikan.');

            _homeController.refreshAnnouncements();

            if (Get.isRegistered<AnnouncementListController>() &&
                Get.currentRoute == Routes.announcementList) {
              final listController = Get.find<AnnouncementListController>();
              listController.fetchAnnouncements();
            }
          })
          .catchError((e) {
            SnackbarHelper.showError('Terjadi kesalahan: $e');
          })
          .whenComplete(() {
            isLoading(false);
          });
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
