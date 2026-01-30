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

        // Try nested student relation first
        String studentName = '-';
        String parentName = '-';
        String className = '-';

        final student = item['student'];
        if (student is Map) {
          studentName =
              (student['name'] ??
                      student['nama'] ??
                      student['full_name'] ??
                      '-')
                  ?.toString() ??
              '-';
          final kelas = student['kelas'];
          if (kelas is Map) {
            className =
                (kelas['name'] ?? kelas['nama'] ?? kelas['class_name'] ?? '-')
                    ?.toString() ??
                '-';
          } else {
            className =
                (student['class_name'] ?? student['kelas_name'] ?? '-')
                    ?.toString() ??
                '-';
          }

          final parent = student['parent'];
          if (parent is Map) {
            final user = parent['user'];
            if (user is Map) {
              parentName =
                  (user['name'] ?? user['nama'] ?? '-')?.toString() ?? '-';
            } else {
              parentName =
                  (parent['name'] ??
                          parent['father_name'] ??
                          parent['mother_name'] ??
                          '-')
                      ?.toString() ??
                  '-';
            }
          }
        } else {
          // Fallback to flattened keys
          studentName =
              (item['student_name'] ?? item['nama_anak'] ?? '-')?.toString() ??
              '-';
          parentName =
              (item['parent_name'] ?? item['orang_tua'] ?? '-')?.toString() ??
              '-';
          className =
              (item['class_name'] ?? item['kelas_name'] ?? '-')?.toString() ??
              '-';
        }

        // Determine leave type (best-effort)
        final reasonText = (item['reason'] ?? '')?.toString() ?? '';
        final leaveType =
            (item['leave_type'] ??
                    (reasonText.toLowerCase().contains('sakit')
                        ? 'Sakit'
                        : 'Izin'))
                ?.toString() ??
            'Izin';

        return LeaveRequest(
          id: item['id'].toString(),
          studentName: studentName,
          parentName: parentName,
          className: className,
          leaveType: leaveType,
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

          // Jika ada HomeController, minta sinkronisasi status anak hari ini.
          if (Get.isRegistered<HomeController>()) {
            try {
              Get.find<HomeController>().fetchChildTodayStatus();
            } catch (_) {}
          }

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
