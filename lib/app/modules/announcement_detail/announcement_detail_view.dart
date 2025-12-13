// lib/app/modules/announcement_detail/announcement_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart'; // Sesuaikan impor
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'package:sapa_raudha/app/modules/announcement_detail/announcement_detail_controller.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';

// --- MODIFIKASI BAGIAN INI ---
class AnnouncementDetailView extends StatelessWidget {
  // Tambahkan constructor untuk menerima ID
  final String announcementId;

  const AnnouncementDetailView({super.key, required this.announcementId});
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
            ],
          );
        }),
      ),
    );
  }
}
