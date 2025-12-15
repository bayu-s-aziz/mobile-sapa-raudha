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

  void showForgotPasswordDialog() {
    final identifierController = TextEditingController();
    final nameController = TextEditingController();
    final isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Lupa Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan NIK/NISN dan nama Anda. Admin akan menghubungi Anda untuk reset password.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: identifierController,
                decoration: const InputDecoration(
                  labelText: 'NIK atau NISN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              identifierController.dispose();
              nameController.dispose();
              Get.back();
            },
            child: const Text('Batal'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isSubmitting.value
                  ? null
                  : () async {
                      final identifier = identifierController.text.trim();
                      final name = nameController.text.trim();

                      if (identifier.isEmpty || name.isEmpty) {
                        SnackbarHelper.showError(
                          'NIK/NISN dan nama harus diisi',
                        );
                        return;
                      }

                      if (!RegExp(r'^\d+$').hasMatch(identifier)) {
                        SnackbarHelper.showError('NIK/NISN harus berupa angka');
                        return;
                      }

                      isSubmitting.value = true;
                      try {
                        final auth = Get.find<AuthService>();
                        await auth.requestPasswordReset(
                          identifier: identifier,
                          name: name,
                        );

                        Get.back();
                        identifierController.dispose();
                        nameController.dispose();

                        SnackbarHelper.showSuccess(
                          'Permintaan reset password berhasil dikirim. Admin akan menghubungi Anda segera.',
                        );
                      } catch (e) {
                        SnackbarHelper.showError(
                          'Gagal mengirim permintaan: $e',
                        );
                      } finally {
                        isSubmitting.value = false;
                      }
                    },
              child: isSubmitting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kirim'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
