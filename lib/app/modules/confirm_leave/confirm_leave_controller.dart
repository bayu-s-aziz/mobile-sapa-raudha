// lib/app/modules/confirm_leave/confirm_leave_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/leave_request_model.dart';

class ConfirmLeaveController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<LeaveRequest> leaveRequests = <LeaveRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaveRequests();
  }

  void fetchLeaveRequests() {
    isLoading(true);
    // Simulasi pengambilan data
    Future.delayed(const Duration(milliseconds: 800), () {
      final dummyData = [
        LeaveRequest(
          id: 'LR001',
          studentName: 'Budi Santoso',
          parentName: 'Bapak Keren',
          leaveType: 'Sakit',
          dateRange: DateTimeRange(
            start: DateTime.now().add(const Duration(days: 1)),
            end: DateTime.now().add(const Duration(days: 2)),
          ),
          reason: 'Demam dan batuk, surat dokter menyusul.',
          status: LeaveStatus.pending,
        ),
        LeaveRequest(
          id: 'LR002',
          studentName: 'Siti Aminah',
          parentName: 'Ibu Keren',
          leaveType: 'Izin',
          dateRange: DateTimeRange(
            start: DateTime.now().add(const Duration(days: 1)),
            end: DateTime.now().add(const Duration(days: 1)),
          ),
          reason: 'Ada keperluan keluarga mendadak di luar kota.',
          status: LeaveStatus.pending,
        ),
        LeaveRequest(
          id: 'LR003',
          studentName: 'Ahmad Zaini',
          parentName: 'Bapak Keren',
          leaveType: 'Sakit',
          dateRange: DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 1)),
            end: DateTime.now().subtract(const Duration(days: 1)),
          ),
          reason: 'Diare.',
          status: LeaveStatus.approved, // Contoh yang sudah di-approve
        ),
      ];

      leaveRequests.assignAll(dummyData);
      isLoading(false);
    });
  }

  void processRequest(LeaveRequest request, LeaveStatus newStatus) {
    // Tampilkan dialog konfirmasi
    Get.dialog(
      AlertDialog(
        title: Text(
          'Konfirmasi ${newStatus == LeaveStatus.approved ? 'Setujui' : 'Tolak'}',
        ),
        content: Text(
          'Apakah Anda yakin ingin ${newStatus == LeaveStatus.approved ? 'menyetujui' : 'menolak'} pengajuan izin untuk ${request.studentName}?',
        ),
        actions: [
          TextButton(child: const Text('Batal'), onPressed: () => Get.back()),
          TextButton(
            child: Text(
              newStatus == LeaveStatus.approved ? 'Setujui' : 'Tolak',
            ),
            onPressed: () {
              Get.back(); // Tutup dialog
              _updateRequestStatus(request, newStatus);
            },
          ),
        ],
      ),
    );
  }

  void _updateRequestStatus(LeaveRequest request, LeaveStatus newStatus) {
    // Simulasi update ke server
    isLoading(true);
    Future.delayed(const Duration(milliseconds: 500), () {
      // Cari index request
      final index = leaveRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        // Update data di list lokal
        leaveRequests[index] = request.copyWith(status: newStatus);
        leaveRequests.refresh(); // Update UI
      }
      isLoading(false);
      Get.snackbar(
        'Berhasil',
        'Pengajuan izin ${request.studentName} telah di-${newStatus == LeaveStatus.approved ? 'setujui' : 'tolak'}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }
}
