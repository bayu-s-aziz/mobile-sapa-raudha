// lib/app/modules/admin_announcement_form/admin_announcement_form_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/announcement_model.dart';
import '../../data/services/announcement_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminAnnouncementFormController extends GetxController {
  late final AnnouncementService _announcementService;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final RxBool isLoading = false.obs;

  Announcement? editingAnnouncement;
  bool get isEditMode => editingAnnouncement != null;

  @override
  void onInit() {
    super.onInit();
    _announcementService = Get.find<AnnouncementService>();
    // Check if we're editing an existing announcement
    if (Get.arguments is Announcement) {
      editingAnnouncement = Get.arguments as Announcement;
      _populateForm();
    }
  }

  void _populateForm() {
    if (editingAnnouncement != null) {
      titleController.text = editingAnnouncement!.title;
      contentController.text = editingAnnouncement!.content;
    }
  }

  Future<void> saveAnnouncement() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      if (isEditMode) {
        // Update existing announcement
        await _announcementService.updateAnnouncement(
          editingAnnouncement!.id,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
        );

        // Close modal first
        Get.back(result: true);

        // Show success snackbar after modal is closed
        Future.delayed(const Duration(milliseconds: 300), () {
          SnackbarHelper.showSuccess('Pengumuman berhasil diperbarui');
        });
      } else {
        // Create new announcement
        await _announcementService.addAnnouncement(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          targetAudience: 'all',
        );

        // Close modal first
        Get.back(result: true);

        // Show success snackbar after modal is closed
        Future.delayed(const Duration(milliseconds: 300), () {
          SnackbarHelper.showSuccess('Pengumuman berhasil ditambahkan');
        });
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal menyimpan pengumuman: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
