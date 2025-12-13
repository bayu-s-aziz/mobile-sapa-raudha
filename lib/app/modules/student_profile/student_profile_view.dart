// lib/app/modules/student_profile/student_profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
                        icon: Icons.badge_outlined,
                        label: 'NISN',
                        value: student.nisn ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.person_outline,
                        label: 'Jenis Kelamin',
                        value: student.gender ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Tempat Lahir',
                        value: student.birthPlace ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.cake_outlined,
                        label: 'Tanggal Lahir',
                        value: student.birthDate != null
                            ? DateFormat(
                                'dd MMMM yyyy',
                                'id_ID',
                              ).format(student.birthDate!)
                            : '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.church_outlined,
                        label: 'Agama',
                        value: student.religion ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.home_outlined,
                        label: 'Alamat',
                        value: student.address ?? '-',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
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
                        icon: Icons.man_outlined,
                        label: 'Nama Ayah',
                        value: student.fatherName ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.work_outline,
                        label: 'Pekerjaan Ayah',
                        value: student.fatherJob ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.woman_outlined,
                        label: 'Nama Ibu',
                        value: student.motherName ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.work_history_outlined,
                        label: 'Pekerjaan Ibu',
                        value: student.motherJob ?? '-',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
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
                        icon: Icons.supervisor_account_outlined,
                        label: 'Nama Wali',
                        value: student.guardianName ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.work_outline,
                        label: 'Pekerjaan Wali',
                        value: student.guardianJob ?? '-',
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
