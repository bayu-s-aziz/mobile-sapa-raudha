// lib/app/modules/edit_profile/edit_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sapa_raudha/app/modules/profile/profile_controller.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';

class EditProfileController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();
  final LocalStorageService _storage = Get.find<LocalStorageService>();
  final ApiClient _api = Get.find<ApiClient>();

  final RxBool isLoading = false.obs;
  final RxString photoUrl = ''.obs;
  final Rxn<XFile> selectedImage = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    photoUrl.value = profileController.userPhotoUrl ?? '';
  }

  Future<void> selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = image;
        photoUrl.value = image.path; // Local path for preview
        Get.snackbar(
          'Berhasil',
          'Foto dipilih. Tekan Simpan untuk mengupload.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveProfile() async {
    if (selectedImage.value == null) {
      Get.snackbar(
        'Info',
        'Tidak ada perubahan untuk disimpan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading(true);
    try {
      // Upload image to server
      final response = await _api.putMultipart(
        '/profile/photo',
        'photo',
        selectedImage.value!.path,
      );

      final serverPhotoUrl = response['photo_url'] as String;
      final fullUrl = '${_api.baseUrl}$serverPhotoUrl';

      // Update profile locally
      profileController.profile['photo_url'] = fullUrl;
      await _storage.save('profile', profileController.profile);
      profileController.profile.refresh();

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Foto profil berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
