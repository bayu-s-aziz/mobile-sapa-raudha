// lib/app/modules/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'profile_controller.dart';
import 'package:sapa_raudha/app/utils/url_utils.dart';
import 'package:sapa_raudha/app/widgets/avatar.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FloatingPage(
        title: 'Profil Saya',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profil',
            onPressed: controller.goToEditProfile,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          final photoUrl = controller.userPhotoUrl;
          final email = controller.userEmail;
          final role = controller.userRole;

          return Center(
            child: Column(
              children: [
                // Avatar with fallback initials and error handling
                Avatar(
                  photoUrl: photoUrl,
                  name: controller.userName,
                  radius: 60,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.userName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Show parent subtitle under name
                if (role.toLowerCase() == 'orangtua') ...[
                  Text(
                    'Orang Tua Ananda ${controller.studentName}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    email,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),
                const Divider(thickness: 0.5),

                // Daftar Menu
                _buildProfileMenu(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Ubah Password',
                  onTap: controller.goToChangePassword,
                ),
                _buildProfileMenu(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  color: AppColors.error,
                  onTap: controller.logout,
                ),
              ],
            ),
          );
        }),
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
