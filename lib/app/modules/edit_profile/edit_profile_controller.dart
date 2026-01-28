// lib/app/modules/edit_profile/edit_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sapa_raudha/app/modules/profile/profile_controller.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

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
        SnackbarHelper.showInfo('Foto dipilih. Tekan Simpan untuk mengupload.');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memilih foto: $e');
    }
  }

  Future<void> saveProfile() async {
    if (selectedImage.value == null) {
      SnackbarHelper.showInfo('Tidak ada perubahan untuk disimpan.');
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

      // Server may return different keys for the uploaded file URL (photo_url, photo, url, avatar)
      final dynamic rawPhoto =
          response['photo_url'] ??
          response['photo'] ??
          response['url'] ??
          response['avatar'];
      if (rawPhoto == null) {
        throw Exception('Server response tidak mengandung URL foto');
      }

      final serverPhotoUrl = rawPhoto.toString();

      // Persist the updated user profile under the same key used by ProfileService ('user')
      final Map<String, dynamic> updated = Map<String, dynamic>.from(
        profileController.profile,
      );

      // Update top-level fields to be defensive for consumers of different response shapes
      updated['photo_url'] =
          serverPhotoUrl; // store raw path; normalization happens when reading
      updated['avatar'] = serverPhotoUrl;

      // If a nested userable exists, update its photo_url as well so UI that reads nested values sees it
      final userable = updated['userable'] as Map<String, dynamic>?;
      if (userable != null) {
        userable['photo_url'] = serverPhotoUrl;
        userable['avatar'] = serverPhotoUrl;
        updated['userable'] = userable;
      }

      await _storage.save('user', updated);

      // Update in-memory reactive profile so UI updates immediately
      profileController.profile.assignAll(updated);
      profileController.profile.refresh();

      Get.back();
      SnackbarHelper.showSuccess('Foto profil berhasil diperbarui.');
    } catch (e) {
      SnackbarHelper.showError('Gagal menyimpan foto: $e');
    } finally {
      isLoading(false);
    }
  }
}
