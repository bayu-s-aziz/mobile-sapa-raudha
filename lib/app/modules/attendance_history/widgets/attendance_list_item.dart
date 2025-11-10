// lib/app/modules/attendance_history/widgets/attendance_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/data/models/attendance_model.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';

class AttendanceListItem extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceListItem({super.key, required this.record});

  IconData _getIcon() {
    switch (record.status) {
      case AttendanceStatus.hadir:
        return Icons.check_circle_outline;
      case AttendanceStatus.sakit:
        return Icons.sick_outlined;
      case AttendanceStatus.izin:
        return Icons.info_outline;
      case AttendanceStatus.alpa:
        return Icons.highlight_off_outlined;
    }
  }

  Color _getColor() {
    switch (record.status) {
      case AttendanceStatus.hadir:
        return AppColors.success;
      case AttendanceStatus.sakit:
        return AppColors.warning;
      case AttendanceStatus.izin:
        return AppColors.primary; // Biru info
      case AttendanceStatus.alpa:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (record.status) {
      case AttendanceStatus.hadir:
        return 'Hadir';
      case AttendanceStatus.sakit:
        return 'Sakit';
      case AttendanceStatus.izin:
        return 'Izin';
      case AttendanceStatus.alpa:
        return 'Alpa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withAlpha(128)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Icon(_getIcon(), color: color),
        ),
        title: Text(
          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(record.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          record.description ?? _getStatusText(),
          style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _getStatusText().toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
