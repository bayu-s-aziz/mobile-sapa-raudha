// lib/app/modules/confirm_leave/widgets/leave_request_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/data/models/leave_request_model.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';

class LeaveRequestCard extends StatelessWidget {
  final LeaveRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const LeaveRequestCard({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
  });

  String _formatDateRange(DateTimeRange range) {
    final start = DateFormat('dd MMM yyyy', 'id_ID').format(range.start);
    final end = DateFormat('dd MMM yyyy', 'id_ID').format(range.end);
    if (start == end) {
      return start;
    }
    return '$start - $end';
  }

  Widget _buildStatusChip() {
    String text;
    Color backgroundColor;
    Color textColor;

    switch (request.status) {
      case LeaveStatus.approved:
        text = 'Disetujui';
        backgroundColor = AppColors.success.withAlpha((0.1 * 255).toInt());
        textColor = AppColors.success;
        break;
      case LeaveStatus.rejected:
        text = 'Ditolak';
        backgroundColor = AppColors.error.withAlpha((0.1 * 255).toInt());
        textColor = AppColors.error;
        break;
      case LeaveStatus.pending:
        text = 'Pending';
        backgroundColor = AppColors.warning.withAlpha((0.1 * 255).toInt());
        textColor = AppColors.warning;
        break;
    }

    return Chip(
      label: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.alternate.withAlpha(122)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.studentName} • ${request.className}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Orang Tua: ${request.parentName}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(
              Icons.category_outlined,
              'Tipe Izin:',
              request.leaveType,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Tanggal:',
              _formatDateRange(request.dateRange),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.article_outlined,
              'Keterangan:',
              request.reason,
            ),

            // Tombol Aksi (hanya jika status pending)
            if (request.status == LeaveStatus.pending) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onReject,
                    child: const Text(
                      'Tolak',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Setujui'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryText),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.primaryText),
          ),
        ),
      ],
    );
  }
}
