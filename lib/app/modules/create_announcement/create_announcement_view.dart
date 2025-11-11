// lib/app/modules/create_announcement/create_announcement_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_announcement_controller.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart'; // Impor AppColors
import 'package:sapa_raudha/app/widgets/floating_page.dart';

class CreateAnnouncementView extends GetView<CreateAnnouncementController> {
  const CreateAnnouncementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FloatingPage(
          title: 'Buat Pengumuman',
          onBack: () => Get.back(),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Judul
                TextFormField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Pengumuman',
                    hintText: 'Masukkan judul...',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    if (value.length > 100) {
                      return 'Judul terlalu panjang (maks 100 karakter)';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),

                // Input Isi Pengumuman
                TextFormField(
                  controller: controller.contentController,
                  decoration: const InputDecoration(
                    labelText: 'Isi Pengumuman',
                    hintText: 'Tulis isi pengumuman di sini...',
                    prefixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 12.0,
                        top: 14.0,
                      ),
                      child: Icon(Icons.article_outlined),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Isi pengumuman tidak boleh kosong';
                    }
                    if (value.length < 10) {
                      return 'Isi pengumuman terlalu pendek (min 10 karakter)';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 24),

                // --- BAGIAN UPLOAD FILE ---
                Text(
                  'Lampiran (Opsional)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // Tampilan File yang Dipilih (atau Tombol Pilih File)
                Obx(() {
                  if (controller.pickedFile.value == null) {
                    // Tampilkan tombol jika belum ada file
                    return OutlinedButton.icon(
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: const Text('Lampirkan Gambar/Berkas'),
                      onPressed: controller.pickAttachment,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        side: const BorderSide(color: AppColors.alternate),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } else {
                    // Tampilkan file yang sudah dipilih
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.alternate.withAlpha(77),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.alternate),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            // Ikon berdasarkan tipe file (sederhana)
                            controller.pickedFile.value!.extension == 'pdf'
                                ? Icons.picture_as_pdf_outlined
                                : (controller.pickedFile.value!.extension ==
                                          'jpg' ||
                                      controller.pickedFile.value!.extension ==
                                          'png')
                                ? Icons.image_outlined
                                : Icons.insert_drive_file_outlined,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller
                                  .pickedFile
                                  .value!
                                  .name, // Tampilkan nama file
                              style: const TextStyle(
                                color: AppColors.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.error,
                            ),
                            onPressed:
                                controller.clearAttachment, // Tombol hapus
                            tooltip: 'Hapus lampiran',
                          ),
                        ],
                      ),
                    );
                  }
                }),

                // --- AKHIR BAGIAN UPLOAD FILE ---
                const SizedBox(height: 40),

                // Tombol Submit
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submitAnnouncement,
                    icon: controller.isLoading.value
                        ? Container(
                            width: 20,
                            height: 20,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      controller.isLoading.value
                          ? 'MENGIRIM...'
                          : 'PUBLIKASIKAN',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
