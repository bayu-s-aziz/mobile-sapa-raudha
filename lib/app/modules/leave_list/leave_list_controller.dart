import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';

class LeaveListController extends GetxController {
  final RxList<Map<String, dynamic>> leaves = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  late final LeaveService _leaveService = Get.find<LeaveService>();

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    isLoading(true);
    try {
      final data = await _leaveService.getLeaveRequests();
      leaves.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data izin: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void goToCreateLeave() {
    Get.toNamed(Routes.requestLeave);
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
