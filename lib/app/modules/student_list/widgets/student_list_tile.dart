// lib/app/modules/student_list/widgets/student_list_tile.dart
import 'package:flutter/material.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';

class StudentListTile extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentListTile({
    super.key,
    required this.student,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (student.dailyStatus) {
      case StudentDailyStatus.hadir:
        return AppColors.success;
      case StudentDailyStatus.sakit:
        return AppColors.warning;
      case StudentDailyStatus.izin:
        return AppColors.primary;
      case StudentDailyStatus.alpa:
        return AppColors.error;
      case StudentDailyStatus.belumHadir:
        return AppColors.secondaryText;
    }
  }

  String _getStatusText() {
    switch (student.dailyStatus) {
      case StudentDailyStatus.hadir:
        return 'Hadir';
      case StudentDailyStatus.sakit:
        return 'Sakit';
      case StudentDailyStatus.izin:
        return 'Izin';
      case StudentDailyStatus.alpa:
        return 'Alpa';
      case StudentDailyStatus.belumHadir:
        return 'Blm Hadir';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage: (student.photoUrl != null)
              ? NetworkImage(student.photoUrl!)
              : null,
          child: (student.photoUrl == null)
              ? Text(
                  student.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              student.studentClass,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText().toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
