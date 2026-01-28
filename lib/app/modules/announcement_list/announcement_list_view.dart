// lib/app/modules/announcement_list/announcement_list_view.dart
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import '../home/home_controller.dart';

import 'announcement_list_controller.dart';

class AnnouncementListView extends GetView<AnnouncementListController> {
  const AnnouncementListView({super.key});

  IconData _getFileIcon(String fileName) {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Helper untuk mengekstrak ekstensi dari fileName atau URL
  String _getExtension(String? fileName, String? url) {
    String? candidate;
    if (fileName != null && fileName.contains('.')) {
      candidate = fileName.split('.').last;
    } else if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        final last = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        if (last.contains('.')) candidate = last.split('.').last;
      } catch (_) {}
    }
    return (candidate ?? '').toLowerCase();
  }

  bool _isImageExt(String ext) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Scaffold(
      floatingActionButton: Obx(() {
        final isGuru = home.userRole.value == 'guru';
        if (!isGuru) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: home.goToCreateAnnouncement,
          tooltip: 'Buat Pengumuman',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add),
        );
      }),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.content.replaceAll('\n', ' '),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          announcement.formattedDate,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.secondaryText.withAlpha(
                                  (0.6 * 255).round(),
                                ),
                              ),
                        ),
                        if (announcement.attachments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 64,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: announcement.attachments.length > 3
                                  ? 3
                                  : announcement.attachments.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final att = announcement.attachments[i];
                                final rawUrl =
                                    (att['file_url'] ?? att['url']) as String?;
                                final fileUrl =
                                    rawUrl != null && rawUrl.isNotEmpty
                                    ? Get.find<ApiClient>().buildFullUrl(rawUrl)
                                    : null;
                                final fileName =
                                    (att['file_name'] ??
                                            att['name'] ??
                                            rawUrl ??
                                            'Lampiran')
                                        as String;
                                final ext = _getExtension(fileName, rawUrl);
                                final isImage = _isImageExt(ext);

                                return GestureDetector(
                                  onTap: fileUrl != null
                                      ? () async {
                                          final uri = Uri.parse(fileUrl);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        }
                                      : null,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      color: AppColors.secondaryBackground,
                                      width: 90,
                                      height: 64,
                                      child: isImage && fileUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: fileUrl,
                                              fit: BoxFit.cover,
                                              width: 90,
                                              height: 64,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Center(
                                                        child: Icon(
                                                          _getFileIcon(
                                                            fileName,
                                                          ),
                                                          color: AppColors
                                                              .secondaryText,
                                                        ),
                                                      ),
                                            )
                                          : Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    _getFileIcon(fileName),
                                                    color: AppColors.primary,
                                                  ),
                                                  if (ext.isNotEmpty)
                                                    Text(
                                                      ext.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (announcement.attachments.length > 3) ...[
                            const SizedBox(height: 8),
                            Text(
                              '+${announcement.attachments.length - 3} lampiran lainnya',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.secondaryText.withAlpha(
                                      (0.6 * 255).round(),
                                    ),
                                  ),
                            ),
                          ],
                        ],
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                    isThreeLine: true,
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
