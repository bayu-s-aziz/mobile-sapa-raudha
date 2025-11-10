import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Tambahkan import untuk SVG

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                // Ganti Image.asset dengan SvgPicture.asset dan ganti nama file
                SvgPicture.asset(
                  'assets/images/logo_ra.svg', // Diperbarui ke SVG
                  height: 130,
                ),
                const SizedBox(height: 40),
                Text(
                  'Selamat Datang!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText, // Gunakan warna tema
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),

                _buildEmailField(context),
                const SizedBox(height: 20),
                _buildPasswordField(context),
                const SizedBox(height: 40),
                _buildLoginButton(),

                // --- Tambahan: Opsi Lupa Password atau Daftar ---
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    /* Logika lupa password */
                  },
                  child: const Text('Lupa Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextField(
      controller: controller.emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.alternate_email),
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
          // Styling diambil dari theme
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
}
