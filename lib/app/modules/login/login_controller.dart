import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/auth_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class LoginController extends GetxController {
  // Ganti email -> id (NIK/NISN)
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  // No role selection; backend determines role by identifier

  Future<void> login() async {
    if (idController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorSnackbar("Identitas dan password tidak boleh kosong");
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(idController.text.trim())) {
      _showErrorSnackbar("NIK/NISN harus berupa angka");
      return;
    }
    isLoading(true);
    try {
      final auth = Get.find<AuthService>();
      final res = await auth.login(
        identifier: idController.text.trim(),
        password: passwordController.text,
      );
      if (res != null) {
        final role = (res['profile']?['role'] ?? '') as String;
        if (role == 'admin') {
          Get.offAllNamed(Routes.adminMain);
        } else {
          Get.offAllNamed(Routes.home, arguments: role);
        }
      } else {
        _showErrorSnackbar("Identitas atau password salah");
      }
    } catch (e) {
      _showErrorSnackbar("Terjadi kesalahan: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void _showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    SnackbarHelper.showError(message);
  }

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
