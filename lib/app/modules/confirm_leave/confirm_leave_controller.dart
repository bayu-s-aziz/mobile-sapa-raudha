// lib/app/modules/confirm_leave/confirm_leave_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/leave_request_model.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';
import '../home/home_controller.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class ConfirmLeaveController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<LeaveRequest> leaveRequests = <LeaveRequest>[].obs;
  late final LeaveService _leaveService;

  @override
  void onInit() {
    super.onInit();
    _leaveService = Get.find<LeaveService>();
    fetchLeaveRequests();
  }

  Future<void> fetchLeaveRequests() async {
    isLoading(true);
    try {
      final data = await _leaveService.getLeaveRequests();
      final mapped = data.map((item) {
        final start = DateTime.parse(item['request_date']);
        return LeaveRequest(
          id: item['id'].toString(),
          studentName: item['student_name'] ?? '',
          parentName: item['parent_name'] ?? '',
          leaveType: item['status'] == 'sakit' ? 'Sakit' : 'Izin',
          dateRange: DateTimeRange(start: start, end: start),
          reason: item['reason'] ?? '',
          status: _mapStatus(item['status'] as String?),
        );
      }).toList();
      leaveRequests.assignAll(mapped);
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat pengajuan izin: $e');
    } finally {
      isLoading(false);
    }
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
    isLoading(true);
    final Future<void> action = newStatus == LeaveStatus.approved
        ? _leaveService.approve(request.id)
        : _leaveService.reject(request.id);

    action
        .then((_) {
          final index = leaveRequests.indexWhere((r) => r.id == request.id);
          if (index != -1) {
            leaveRequests[index] = request.copyWith(status: newStatus);
            leaveRequests.refresh();
          }
          // Segarkan badge pending dan daftar dari sumber API
          Get.find<HomeController>().fetchPendingLeaveCount();
          fetchLeaveRequests();
          SnackbarHelper.showSuccess(
            'Pengajuan izin ${request.studentName} telah di-${newStatus == LeaveStatus.approved ? 'setujui' : 'tolak'}.',
          );
        })
        .catchError((e) {
          SnackbarHelper.showError('Tidak dapat memperbarui status: $e');
        })
        .whenComplete(() => isLoading(false));
  }

  LeaveStatus _mapStatus(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }
}
