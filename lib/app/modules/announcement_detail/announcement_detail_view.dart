// lib/app/modules/announcement_detail/announcement_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart'; // Sesuaikan impor
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'package:sapa_raudha/app/modules/announcement_detail/announcement_detail_controller.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- MODIFIKASI BAGIAN INI ---
class AnnouncementDetailView extends StatelessWidget {
  // Tambahkan constructor untuk menerima ID
  final String announcementId;

  const AnnouncementDetailView({super.key, required this.announcementId});

  // Dapatkan ekstensi dari nama file atau dari URL jika nama tidak memiliki ekstensi
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

  bool _isImage(String fileName, String? url) {
    final ext = _getExtension(fileName, url);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  // Helper untuk mendapatkan icon berdasarkan tipe file
  IconData _getFileIcon(String fileName, [String? url]) {
    final ext = _getExtension(fileName, url);
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
  // --- AKHIR MODIFIKASI ---

  @override
  Widget build(BuildContext context) {
    // --- TAMBAHKAN BARIS INI ---
    // Inisialisasi controller secara manual dengan 'put'
    // agar bisa ditemukan oleh Get.find() di dalam widget
    // Gunakan tag unik agar setiap instance announcement memiliki controller sendiri
    final String tag = 'announcement_$announcementId';
    final AnnouncementDetailController controller = Get.put(
      AnnouncementDetailController(passedAnnouncementId: announcementId),
      tag: tag,
    );
    // --- AKHIR TAMBAHAN ---

    // (Pastikan sisa kode build() Anda tidak memanggil GetView)
    // Jika Anda sebelumnya menggunakan GetView, ubah 'extends GetView<...>'
    // menjadi 'extends StatelessWidget' (seperti di atas) dan
    // panggil 'controller' yang sudah kita buat di atas.

    return Scaffold(
      body: FloatingPage(
        title: 'Detail Pengumuman',
        onBack: () {
          if (Get.isRegistered<HomeController>()) {
            final hc = Get.find<HomeController>();
            hc.clearActionView();
          } else {
            Get.back();
          }
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.announcement.value == null) {
            return const Center(child: Text("Pengumuman tidak ditemukan."));
          }

          final announcement = controller.announcement.value!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Diterbitkan pada: ${announcement.formattedDate}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                announcement.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryText,
                  height: 1.5,
                ),
              ),
              if (announcement.attachments.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Lampiran:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: announcement.attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = announcement.attachments[index];
                    final rawUrl = attachment['file_url'] ?? attachment['url'];
                    final fileUrl =
                        rawUrl != null && rawUrl is String && rawUrl.isNotEmpty
                        ? Get.find<ApiClient>().buildFullUrl(rawUrl)
                        : null;
                    final fileName =
                        (attachment['file_name'] ??
                                attachment['name'] ??
                                rawUrl ??
                                'Lampiran')
                            .toString();
                    final isImage = _isImage(fileName, rawUrl);

                    return GestureDetector(
                      onTap: fileUrl != null
                          ? () => controller.openAttachment(fileUrl)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.alternate.withAlpha(
                              (0.3 * 255).round(),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isImage && fileUrl != null)
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: fileUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.broken_image,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Icon(
                                _getFileIcon(fileName, rawUrl),
                                size: 48,
                                color: AppColors.primary,
                              ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                fileName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.primaryText),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
