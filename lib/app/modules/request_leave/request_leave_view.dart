// [KODE LENGKAP]

import 'dart:io'; // <-- Tambahkan import ini
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart'; // <-- Tambahkan import ini
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'request_leave_controller.dart';

class RequestLeaveView extends GetView<RequestLeaveController> {
  const RequestLeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body di-wrap dengan GestureDetector untuk menutup keyboard
      // saat user tap di luar text field
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FloatingPage(
          title: 'Ajukan Izin',
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pilih Tanggal Izin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // (Misal: Widget untuk pilih tanggal mulai)
                TextFormField(
                  controller: controller.startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.startDateController.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal mulai harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // (Misal: Widget untuk pilih tanggal selesai)
                TextFormField(
                  controller: controller.endDateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Selesai',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.endDateController.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal selesai harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: controller.reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Alasan Tidak Hadir',
                    hintText: 'Contoh: Sakit, acara keluarga, dll.',
                    alignLabelWithHint: true, // Agar label sejajar hint
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alasan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- WIDGET BARU UNTUK UPLOAD FILE ---
                Text(
                  'Lampiran (Opsional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.selectedFile.value == null) {
                    // Tampilan Tombol Upload
                    return OutlinedButton.icon(
                      onPressed: controller.pickImage,
                      icon: const Icon(Icons.attach_file_outlined),
                      label: const Text('Pilih Gambar (Surat Dokter)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryText,
                        // Gunakan style border dari theme
                        side: BorderSide(
                          color: AppColors.alternate.withAlpha(
                            (0.8 * 255).round(),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // Gunakan radius dari theme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  } else {
                    // Tampilan Pratinjau File
                    return _buildFilePreview(
                      context,
                      controller.selectedFile.value!,
                    );
                  }
                }),

                // -------------------------------------
                const SizedBox(height: 40),
                // Tombol ini akan otomatis mengambil style modern (pill shape)
                ElevatedButton(
                  onPressed: controller.submitLeaveRequest,
                  child: const Text('AJUKAN IZIN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER BARU UNTUK PREVIEW ---
  Widget _buildFilePreview(BuildContext context, File file) {
    // Ambil nama file dari path
    String fileName = file.path.split('/').last;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // Radius modern
        border: Border.all(color: AppColors.alternate),
        color: AppColors.secondaryBackground,
      ),
      child: Row(
        children: [
          // Icon pratinjau
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.error),
            onPressed: controller.clearImage,
            tooltip: 'Hapus file',
          ),
        ],
      ),
    );
  }

  // -------------------------------------
}
