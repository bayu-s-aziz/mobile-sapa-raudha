// lib/app/modules/student_detail/student_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'package:sapa_raudha/app/modules/student_detail/student_detail_controller.dart';

class StudentDetailView extends GetView<StudentDetailController> {
  const StudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingPage(
        title: 'Detail Siswa',
        onBack: () => Get.back(),
        contentPadding: EdgeInsets.zero,
        child: Obx(() {
          if (controller.student.value == null) {
            return const Center(child: Text('Data siswa tidak tersedia.'));
          }
          final student = controller.student.value!;
          final textTheme = Theme.of(context).textTheme;
          String formatValue(String? value) {
            final trimmed = value?.trim();
            if (trimmed != null && trimmed.isNotEmpty) {
              return trimmed;
            }
            return '-';
          }

          String formatPhone() {
            final candidates = [
              student.fatherPhone,
              student.motherPhone,
              student.guardianPhone,
            ];
            for (final phone in candidates) {
              final trimmed = phone?.trim();
              if (trimmed != null && trimmed.isNotEmpty) return trimmed;
            }
            return 'Tidak tersedia';
          }

          return SingleChildScrollView(
            child: Column(
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
                        backgroundImage: (student.photoUrl != null)
                            ? NetworkImage(student.photoUrl!)
                            : null,
                        child: (student.photoUrl == null)
                            ? Text(
                                student.name.substring(0, 1).toUpperCase(),
                                style: textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
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
                // Info Tambahan (Orang Tua)
                _buildInfoSection(
                  context,
                  title: 'Informasi Orang Tua',
                  children: [
                    _buildInfoTile(
                      icon: Icons.man_outlined,
                      label: 'Nama Ayah',
                      value: formatValue(student.fatherName),
                    ),
                    _buildInfoTile(
                      icon: Icons.woman_outlined,
                      label: 'Nama Ibu',
                      value: formatValue(student.motherName),
                    ),
                    _buildInfoTile(
                      icon: Icons.home_outlined,
                      label: 'Alamat',
                      value: formatValue(student.address),
                    ),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Nomor Telepon Orang Tua',
                      value: formatPhone(),
                    ),
                  ],
                ),
                // Aksi Cepat
                _buildInfoSection(
                  context,
                  title: 'Aksi Cepat',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history_outlined),
                      title: const Text('Lihat Riwayat Absensi'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: controller.goToStudentAttendanceHistory,
                    ),
                    ListTile(
                      leading: const Icon(Icons.message_outlined),
                      title: const Text('Hubungi Orang Tua (WA)'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: controller.callParent,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppColors.alternate.withAlpha(122)),
            ),
            child: Column(children: children),
          ),
        ],
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
