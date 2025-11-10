import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorSnackbar("Email dan password tidak boleh kosong");
      return;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      _showErrorSnackbar("Format email tidak valid");
      return;
    }

    isLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // Persingkat delay

      final String? role = _performDummyLoginWithRole(
        emailController.text,
        passwordController.text,
      );

      if (role != null) {
        Get.offAllNamed(Routes.home, arguments: role);
      } else {
        _showErrorSnackbar("Email atau password salah");
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

  String? _performDummyLoginWithRole(String email, String password) {
    const String dummyPassword = "12345678";

    if (email.toLowerCase() == "guru@gmail.com" && password == dummyPassword) {
      return "guru";
    } else if (email.toLowerCase() == "ortu@gmail.com" &&
        password == dummyPassword) {
      return "orangtua";
    } else {
      return null;
    }
  }

  void _showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      "Login Gagal",
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      shouldIconPulse: false,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
