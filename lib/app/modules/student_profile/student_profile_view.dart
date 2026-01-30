// lib/app/modules/student_profile/student_profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'student_profile_controller.dart';
import 'package:sapa_raudha/app/utils/url_utils.dart';
import 'package:sapa_raudha/app/widgets/avatar.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FloatingPage(
        title: 'Profil Ananda',
        onBack: () {
          if (homeController != null) {
            homeController.clearActionView();
          } else {
            Get.back();
          }
        },
        contentPadding: EdgeInsets.zero,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

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
                    Avatar(
                      photoUrl: student.photoUrl,
                      name: student.name,
                      radius: 60,
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
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
                      ' ${student.studentClass} ',
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
                        label: 'NIS',
                        value: student.nis ?? '-',
                      ),
                      _buildInfoTile(
                        icon: Icons.badge_outlined,
                        label: 'NISN',
                        value: student.nisn ?? '-',
                      ), // Status Kehadiran Hari Ini
                      Obx(() {
                        final att = controller.todayAttendance.value;
                        String statusLabel = 'Belum absen';
                        if (att != null && att['status'] != null) {
                          final s = (att['status'] as String).toLowerCase();
                          switch (s) {
                            case 'hadir':
                              statusLabel = 'Hadir';
                              break;
                            case 'sakit':
                              statusLabel = 'Sakit';
                              break;
                            case 'izin':
                              statusLabel = 'Izin';
                              break;
                            case 'alpa':
                            case 'alpha':
                              statusLabel = 'Alpa';
                              break;
                            default:
                              statusLabel = 'Belum absen';
                          }
                        }

                        return _buildInfoTile(
                          icon: Icons.event_available_outlined,
                          label: 'Status Kehadiran (Hari ini)',
                          value: statusLabel,
                        );
                      }),
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
