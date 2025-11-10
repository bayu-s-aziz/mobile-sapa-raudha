// lib/app/modules/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // --- APPBAR DIHAPUS DARI SINI ---
      // appBar: AppBar(
      //   title: const Text('Profil Saya'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.edit_outlined),
      //       tooltip: 'Edit Profil',
      //       onPressed: controller.goToEditProfile,
      //     ),
      //   ],
      // ),
      // --- AKHIR PENGHAPUSAN ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Center(
          child: Column(
            children: [
              // Foto Profil
              Obx(
                () => CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary,
                  backgroundImage: controller.userPhotoUrl.value.isNotEmpty
                      ? NetworkImage(controller.userPhotoUrl.value)
                      : null,
                  child: controller.userPhotoUrl.value.isEmpty
                      ? const Icon(
                          Icons.person_outline,
                          size: 60,
                          // --- MODIFIKASI WARNA IKON ---
                          color: Colors.white, // Diubah dari AppColors.primary
                          // --- AKHIR MODIFIKASI ---
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Nama Pengguna
              Obx(
                () => Text(
                  controller.userName.value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),

              // Email Pengguna
              Obx(
                () => Text(
                  controller.userEmail.value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(thickness: 0.5),

              // Daftar Menu
              _buildProfileMenu(
                context,
                icon: Icons.lock_outline,
                title: 'Ubah Password',
                onTap: () {
                  Get.snackbar("Info", "Fitur 'Ubah Password' belum tersedia.");
                },
              ),
              _buildProfileMenu(
                context,
                icon: Icons.help_outline,
                title: 'Pusat Bantuan',
                onTap: () {
                  Get.snackbar("Info", "Fitur 'Pusat Bantuan' belum tersedia.");
                },
              ),
              _buildProfileMenu(
                context,
                icon: Icons.logout,
                title: 'Logout',
                color: AppColors.error,
                onTap: controller.logout, // Panggil fungsi logout
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.primaryText,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color.withAlpha((0.7 * 255).toInt()),
      ),
      onTap: onTap,
    );
  }
}
