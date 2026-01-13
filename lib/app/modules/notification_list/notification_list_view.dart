import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'notification_list_controller.dart';

class NotificationListView extends GetView<NotificationListController> {
  const NotificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    return Scaffold(
      body: FloatingPage(
        title: 'Notifikasi',
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text('Tandai sudah dibaca'),
          ),
        ],
        onBack: () {
          if (homeController != null) {
            homeController.clearActionView();
          } else {
            Get.back();
          }
        },
        onRefresh: controller.refreshList,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return _EmptyState(onRefresh: controller.refreshList);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final notif in controller.notifications)
                _NotificationCard(
                  item: notif,
                  onTap: () => controller.toggleRead(notif.id),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText);
    final timeText = DateFormat('d MMM yyyy • HH:mm').format(item.time);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: item.isRead ? Colors.white : AppColors.primary.withAlpha(18),
      child: ListTile(
        onTap: onTap,
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(item.body, style: subtitleStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                _CategoryChip(label: item.category),
                const SizedBox(width: 8),
                Text(timeText, style: subtitleStyle?.copyWith(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Icon(
          item.isRead ? Icons.mark_email_read_outlined : Icons.markunread,
          color: item.isRead ? AppColors.secondaryText : AppColors.primary,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.alternate.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Belum ada notifikasi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk memuat notifikasi terbaru.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
