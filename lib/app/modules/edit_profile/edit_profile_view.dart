// lib/app/modules/edit_profile/edit_profile_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
// Device frame removed for production
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'edit_profile_controller.dart';
import 'package:sapa_raudha/app/utils/url_utils.dart';
import 'package:sapa_raudha/app/widgets/avatar.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingPage(
        title: 'Ganti Foto Profil',
        onBack: () => Get.back(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Tampilan Foto Profil
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final photoUrl = controller.photoUrl.value;
                    final selectedImage = controller.selectedImage.value;

                    return Avatar(
                      localFilePath: selectedImage?.path,
                      photoUrl: photoUrl,
                      name: controller.profileController.userName,
                      radius: 80,
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      elevation: 4,
                      child: InkWell(
                        onTap: controller.selectImage,
                        borderRadius: BorderRadius.circular(24),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Info text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ketuk ikon kamera untuk memilih foto baru dari galeri.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Jika role orangtua, tampilkan field nomor telepon
            if (Get.find<ProfileService>().getStoredRole() == 'orangtua')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nomor Handphone',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan nomor handphone',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isSavingPhone.value
                            ? null
                            : controller.savePhone,
                        icon: controller.isSavingPhone.value
                            ? Container(
                                width: 20,
                                height: 20,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          controller.isSavingPhone.value
                              ? 'MENYIMPAN...'
                              : 'SIMPAN NOMOR',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Tombol Simpan
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.saveProfile,
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
                    : const Icon(Icons.save_outlined),
                label: Text(
                  controller.isLoading.value ? 'MENYIMPAN...' : 'SIMPAN FOTO',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
