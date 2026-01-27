import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Tambahkan import untuk SVG
// Device frame removed for production

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  // Role selector removed: backend auto-detects by NIK/NISN

  Widget _buildIdentifierField(BuildContext context) {
    return TextField(
      controller: controller.idController,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: controller.isPasswordHidden.value,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: controller.isPasswordHidden.value
                ? 'Tampilkan password'
                : 'Sembunyikan password',
            icon: Icon(
              controller.isPasswordHidden.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => controller.login(),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.login,
              child: const Text('MASUK'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan warna background dari tema
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo aplikasi
                Image.asset(
                  'assets/images/logo_ra.png',
                  height: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  'Selamat Datang di SAPA Raudha!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText, // Gunakan warna tema
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem Informasi Presensi dan Komunikasi Terpadu Raudhatul Athfal',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Silakan masuk untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                // Role selector removed
                _buildIdentifierField(context),
                const SizedBox(height: 20),
                _buildPasswordField(context),
                const SizedBox(height: 40),
                _buildLoginButton(),

                // --- Tambahan: Opsi Lupa Password atau Daftar ---
                const SizedBox(height: 24),
                TextButton(
                  onPressed: controller.showForgotPasswordDialog,
                  child: const Text('Lupa Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
