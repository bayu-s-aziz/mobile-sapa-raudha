import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isLoading = false.obs;
  late final ProfileService _profileService;

  @override
  void onInit() {
    super.onInit();
    _profileService = Get.find<ProfileService>();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      SnackbarHelper.showError('Konfirmasi password tidak sama');
      return;
    }

    isLoading(true);
    try {
      await _profileService.changePassword(
        oldPassword: oldPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );
      SnackbarHelper.showSuccess('Password berhasil diubah');
      Get.back();
    } catch (e) {
      SnackbarHelper.showError('Ubah password gagal: $e');
    } finally {
      isLoading(false);
    }
  }
}
