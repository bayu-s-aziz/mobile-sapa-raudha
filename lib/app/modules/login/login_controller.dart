import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/data/services/auth_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
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

    final identifierInput = idController.text.trim();
    final isNumeric = RegExp(r'^\d+$').hasMatch(identifierInput);
    final isEmail = RegExp(r'^\S+@\S+\.\S+$').hasMatch(identifierInput);
    if (!isNumeric && !isEmail) {
      _showErrorSnackbar("Masukkan NIK/NISN (angka) atau email yang valid");
      return;
    }

    isLoading(true);
    try {
      final auth = Get.find<AuthService>();
      final res = isEmail
          ? await auth.login(
              email: identifierInput,
              password: passwordController.text,
            )
          : await auth.login(
              identifier: identifierInput,
              password: passwordController.text,
            );

      // If Fortify returned two_factor (session-based flow)
      if (res is Map && res!.containsKey('two_factor')) {
        final two = res['two_factor'];
        if (two == true) {
          _showErrorSnackbar('Two-factor authentication required.');
        } else {
          _showErrorSnackbar('Login succeeded (session). Please continue.');
          Get.offAllNamed(Routes.home);
        }
        return;
      }

      if (res != null) {
        // Normalize role from various possible response shapes
        String role = '';
        final Map<String, dynamic> resp = Map<String, dynamic>.from(res as Map);

        if (resp.containsKey('role') && resp['role'] != null) {
          role = resp['role'].toString();
        } else if (resp.containsKey('profile') && resp['profile'] is Map) {
          final profile = Map<String, dynamic>.from(resp['profile'] as Map);
          if (profile.containsKey('role') && profile['role'] != null) {
            role = profile['role'].toString();
          }
        } else if (resp.containsKey('userable_type') &&
            resp['userable_type'] != null) {
          final t = resp['userable_type'].toString();
          if (t.contains('Guru')) {
            role = 'guru';
          } else if (t.contains('Siswa')) {
            role = 'siswa';
          } else if (t.toLowerCase().contains('parent') ||
              t.toLowerCase().contains('ortu')) {
            role = 'orangtua';
          }
        }

        // Persist role for HomeController fallback
        try {
          final storage = Get.find<LocalStorageService>();
          if (role.isNotEmpty) {
            await storage.save('role', role);
          }

          // Simpan NISN anak untuk orang tua dari response login
          if (role == 'orangtua') {
            final nisn =
                (resp['user']?['userable']?['student']?['nisn'] as String?) ??
                (resp['nisn'] as String?) ??
                (resp['student_nisn'] as String?);
            if (nisn != null && nisn.isNotEmpty) {
              await storage.save('nisn', nisn);
            } else {
              // NISN not present in login response
            }
          }
        } catch (_) {}

        // Redirect to Home with role argument
        Get.offAllNamed(Routes.home, arguments: role);
      } else {
        _showErrorSnackbar("Identitas atau password salah");
      }
    } catch (e) {
      if (e is ApiException) {
        final body = e.body;
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as Map<String, dynamic>;
          final messages = errors.values
              .map((v) => v is List ? v.join(' ') : v.toString())
              .join('\n');
          _showErrorSnackbar(messages);
        } else if (body is Map && body.containsKey('message')) {
          _showErrorSnackbar(body['message'].toString());
        } else {
          _showErrorSnackbar(e.toString());
        }
      } else {
        _showErrorSnackbar("Terjadi kesalahan: ${e.toString()}");
      }
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
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
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
    ).then((_) {
      // Dispose controllers when dialog is dismissed (any way it closes)
      identifierController.dispose();
      nameController.dispose();
    });
  }

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
