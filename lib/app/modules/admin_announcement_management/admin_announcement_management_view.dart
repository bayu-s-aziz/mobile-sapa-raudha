// lib/app/modules/admin_announcement_management/admin_announcement_management_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_form/admin_announcement_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_form/admin_announcement_form_controller.dart';
import '../../data/models/announcement_model.dart';
import 'admin_announcement_management_controller.dart';

class AdminAnnouncementManagementView
    extends GetView<AdminAnnouncementManagementController> {
  const AdminAnnouncementManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(bottom: BorderSide(color: AppColors.alternate)),
      ),
      child: Row(
        children: [
          Text(
            'Manajemen Pengumuman',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddAnnouncementModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pengumuman'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchAnnouncements,
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.secondaryBackground,
          child: Column(
            children: [
              // Search field
              TextField(
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari pengumuman...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.primaryBackground,
                ),
              ),
            ],
          ),
        ),
        // Announcements List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredAnnouncements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada pengumuman',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchAnnouncements,
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: controller.filteredAnnouncements.length,
                itemBuilder: (context, index) {
                  final announcement = controller.filteredAnnouncements[index];
                  return _AnnouncementCard(
                    announcement: announcement,
                    onTap: () => controller.goToAnnouncementDetail(
                      announcement,
                      onEdit: () =>
                          _showEditAnnouncementModal(context, announcement),
                    ),
                    onEdit: () =>
                        _showEditAnnouncementModal(context, announcement),
                    onDelete: () =>
                        controller.deleteAnnouncement(announcement.id),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showEditAnnouncementModal(
    BuildContext context,
    Announcement announcement,
  ) {
    // Delete existing controller if any to ensure fresh state
    Get.delete<AdminAnnouncementFormController>();
    Get.put(AdminAnnouncementFormController());

    // Manually set the announcement data after controller is created
    final formController = Get.find<AdminAnnouncementFormController>();
    formController.editingAnnouncement = announcement;
    formController.titleController.text = announcement.title;
    formController.contentController.text = announcement.content;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Edit Pengumuman',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(child: const AdminAnnouncementFormView()),
            ],
          ),
        ),
      ),
      arguments: announcement,
    ).then((result) {
      if (result == true) {
        controller.fetchAnnouncements();
      }
    });
  }

  void _showAddAnnouncementModal(BuildContext context) {
    // Delete existing controller if any to ensure fresh state
    Get.delete<AdminAnnouncementFormController>();
    Get.put(AdminAnnouncementFormController());
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Tambah Pengumuman',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Expanded(child: AdminAnnouncementFormView()),
            ],
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        controller.fetchAnnouncements();
      }
    });
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnnouncementCard({
    required this.announcement,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.alternate, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: AppColors.secondaryText),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                announcement.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              // Content preview
              Text(
                announcement.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Divider(color: AppColors.alternate),
              const SizedBox(height: 12),
              // Footer
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    announcement.createdBy,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                      'id_ID',
                    ).format(announcement.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
