// lib/app/modules/announcement_list/announcement_list_view.dart
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';

import 'announcement_list_controller.dart';

class AnnouncementListView extends GetView<AnnouncementListController> {
  const AnnouncementListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingPage(
        title: 'Pengumuman',
        scrollable: false,
        contentPadding: EdgeInsets.zero,
        child: Obx(() {
          if (controller.isLoading.value && controller.announcements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.announcements.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Belum ada pengumuman yang dipublikasikan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchAnnouncements();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: controller.announcements.length,
              itemBuilder: (context, index) {
                final announcement = controller.announcements[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(
                        (255 * 0.1).round(),
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      announcement.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      announcement.content.replaceAll('\n', ' '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                    onTap: () => controller.goToDetail(announcement.id),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          );
        }),
      ),
    );
  }
}
