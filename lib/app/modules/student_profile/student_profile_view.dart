// lib/app/modules/student_profile/student_profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'student_profile_controller.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FloatingPage(
        title: 'Profil Ananda',
        onBack: () => Get.back(),
        contentPadding: EdgeInsets.zero,
        child: Obx(() {
          if (controller.student.value == null) {
            return const Center(child: Text('Data ananda tidak ditemukan.'));
          }

          final student = controller.student.value!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info Siswa
              Container(
                padding: const EdgeInsets.all(24.0),
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary,
                      // Jika ada foto siswa, tampilkan, jika tidak, inisial
                      child: (student.photoUrl != null)
                          ? null // Tambahkan NetworkImage jika ada
                          : Text(
                              student.name.substring(0, 1).toUpperCase(),
                              style: textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelas: ${student.studentClass}',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // Info Tambahan
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.alternate.withAlpha(122)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.person_outline,
                        label: 'Nama Wali',
                        value: student.parentName,
                      ),
                      _buildInfoTile(
                        icon: Icons.class_outlined,
                        label: 'Kelas',
                        value: student.studentClass,
                      ),
                      _buildInfoTile(
                        icon: Icons.info_outline,
                        label: 'Status Hari Ini',
                        value: 'Hadir', // Diambil dari status dummy
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondaryText),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
