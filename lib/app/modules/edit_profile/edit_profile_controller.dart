// lib/app/modules/edit_profile/edit_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/profile/profile_controller.dart';

class EditProfileController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();

  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;

  final RxBool isLoading = false.obs;
  final RxString photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data awal dari profile controller
    nameController = TextEditingController(
      text: profileController.userName.value,
    );
    photoUrl.value = profileController.userPhotoUrl.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void selectImage() {
    // TODO: Implementasi logika pilih gambar (dari galeri/kamera)
    // Untuk saat ini, kita tampilkan snackbar
    Get.snackbar("Info", "Fitur ganti foto belum diimplementasikan.");
    // Contoh jika berhasil:
    // photoUrl.value = "URL_FOTO_BARU_DARI_SERVER";
  }

  void saveProfile() {
    if (formKey.currentState?.validate() ?? false) {
      isLoading(true);
      // Simulasi penyimpanan
      Future.delayed(const Duration(seconds: 2), () {
        // Update data di ProfileController
        profileController.userName.value = nameController.text;
        profileController.userPhotoUrl.value = photoUrl.value;

        isLoading(false);
        Get.back(); // Kembali ke halaman profil
        Get.snackbar(
          "Berhasil",
          "Profil berhasil diperbarui.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      });
    }
  }
}
