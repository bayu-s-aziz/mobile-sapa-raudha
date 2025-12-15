// lib/app/modules/admin_announcement_management/admin_announcement_management_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/announcement_model.dart';
import '../../data/services/announcement_service.dart';
import '../../utils/app_colors.dart';

class AdminAnnouncementManagementController extends GetxController {
  late final AnnouncementService _announcementService;

  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxList<Announcement> filteredAnnouncements = <Announcement>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _announcementService = Get.find<AnnouncementService>();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      final data = await _announcementService.getAllAnnouncements();
      announcements.value = data;
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat pengumuman: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = announcements.toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where(
            (a) =>
                a.title.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                a.content.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredAnnouncements.value = filtered;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  Future<void> deleteAnnouncement(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus pengumuman ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;
        await _announcementService.deleteAnnouncement(id);
        await fetchAnnouncements();
        Get.snackbar(
          'Berhasil',
          'Pengumuman berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menghapus pengumuman: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void goToAddAnnouncement() {
    // This will be called from the view to show modal
    fetchAnnouncements();
  }

  void goToEditAnnouncement(Announcement announcement) {
    // Will be handled by view modal
    fetchAnnouncements();
  }

  void goToAnnouncementDetail(
    Announcement announcement, {
    VoidCallback? onEdit,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Pengumuman',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        announcement.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Metadata
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            announcement.createdBy,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'EEEE, dd MMMM yyyy',
                              'id_ID',
                            ).format(announcement.createdAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppColors.alternate),
                      const SizedBox(height: 24),
                      // Content
                      Text(
                        announcement.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryText,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  border: Border(top: BorderSide(color: AppColors.alternate)),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Tutup'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back(); // Close detail dialog
                        if (onEdit != null) {
                          onEdit(); // Call the edit modal callback
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
