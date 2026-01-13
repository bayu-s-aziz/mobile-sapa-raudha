import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'admin_password_reset_controller.dart';

class AdminPasswordResetView extends GetView<AdminPasswordResetController> {
  const AdminPasswordResetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Reset Password'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(
            () => SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'pending',
                  label: Text('Pending'),
                  icon: Icon(Icons.pending_outlined),
                ),
                ButtonSegment(
                  value: 'completed',
                  label: Text('Selesai'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment(
                  value: 'rejected',
                  label: Text('Ditolak'),
                  icon: Icon(Icons.cancel_outlined),
                ),
              ],
              selected: {controller.selectedFilter.value},
              onSelectionChanged: (Set<String> selected) {
                controller.changeFilter(selected.first);
              },
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada permintaan',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchRequests,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final request = controller.requests[index];
              return _buildRequestCard(context, request);
            },
          ),
        );
      }),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    final status = request['status'] as String;
    final createdAt = DateTime.parse(request['created_at']);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        statusText = 'Menunggu';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Selesai';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusText = 'Ditolak';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request['name'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  request['identifier'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(
                  request['user_type'] == 'guru'
                      ? Icons.person_outline
                      : Icons.family_restroom_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  request['user_type'] == 'guru' ? 'Guru/Admin' : 'Orang Tua',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            if (request['phone_number'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    request['phone_number'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            if (request['notes'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Catatan: ${request['notes']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        controller.processRequest(request['id'], 'rejected'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => controller.showProcessDialog(request),
                    child: const Text('Proses'),
                  ),
                ],
              ),
            ],
            if (request['processed_by_name'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Diproses oleh: ${request['processed_by_name']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
