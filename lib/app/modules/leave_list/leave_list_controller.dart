import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';
import '../request_leave/request_leave_view.dart';
import '../home/home_controller.dart';

class LeaveListController extends GetxController {
  final RxList<Map<String, dynamic>> leaves = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  late final LeaveService _leaveService = Get.find<LeaveService>();
  late final StudentService _studentService = Get.find<StudentService>();
  late final ProfileService _profileService = Get.find<ProfileService>();

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    isLoading(true);
    try {
      // If the current user is a parent, fetch leaves for their child
      if (_profileService.isParent()) {
        final nisn = _profileService.getStoredNisn();
        if (nisn != null) {
          final student = await _studentService.getStudentByNisn(nisn);
          if (student != null && student['id'] != null) {
            final data = await _leaveService.getByStudent(student['id']);
            leaves.assignAll(data);
            return;
          }
        }
        // fallback to general list if student not resolved
      }

      final data = await _leaveService.getLeaveRequests();
      leaves.assignAll(data);
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data izin: $e');
    } finally {
      isLoading(false);
    }
  }

  void goToCreateLeave() {
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      try {
        // Render RequestLeave as an action view inside Home for consistent behavior
        home.currentActionView.value = const RequestLeaveView();
        return;
      } catch (_) {
        // Fallthrough to route navigation if something goes wrong
      }
    }

    // Fallback: open as a full route
    Get.toNamed(Routes.requestLeave);
  }

  Future<void> deleteLeave(dynamic id) async {
    try {
      await _leaveService.delete(id);
      SnackbarHelper.showSuccess('Izin berhasil dibatalkan');
      await fetchLeaves();
    } catch (e) {
      SnackbarHelper.showError('Gagal membatalkan izin: $e');
    }
  }

  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
