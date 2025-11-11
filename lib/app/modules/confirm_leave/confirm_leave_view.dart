// lib/app/modules/confirm_leave/confirm_leave_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/leave_request_model.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'confirm_leave_controller.dart';
import 'widgets/leave_request_card.dart'; // Widget kustom (dibuat di bawah)

class ConfirmLeaveView extends GetView<ConfirmLeaveController> {
  const ConfirmLeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingPage(
        title: 'Konfirmasi Izin',
        onBack: () => Get.back(),
        scrollable: false,
        contentPadding: EdgeInsets.zero,
        child: Obx(() {
          if (controller.isLoading.value && controller.leaveRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter request yang masih pending
          final pendingRequests = controller.leaveRequests
              .where((r) => r.status == LeaveStatus.pending)
              .toList();

          // Filter request yang sudah diproses
          final processedRequests = controller.leaveRequests
              .where((r) => r.status != LeaveStatus.pending)
              .toList();

          if (controller.leaveRequests.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada pengajuan izin saat ini.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            );
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (pendingRequests.isNotEmpty) ...[
                    Text(
                      'Menunggu Konfirmasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...pendingRequests.map(
                      (request) => LeaveRequestCard(
                        request: request,
                        onApprove: () => controller.processRequest(
                          request,
                          LeaveStatus.approved,
                        ),
                        onReject: () => controller.processRequest(
                          request,
                          LeaveStatus.rejected,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (processedRequests.isNotEmpty) ...[
                    Text(
                      'Riwayat Dikonfirmasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...processedRequests.map(
                      (request) => LeaveRequestCard(request: request),
                    ),
                  ],
                ],
              ),
              // Indikator loading saat memproses
              if (controller.isLoading.value &&
                  controller.leaveRequests.isNotEmpty)
                Container(
                  color: Colors.black.withAlpha(25),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }),
      ),
    );
  }
}
