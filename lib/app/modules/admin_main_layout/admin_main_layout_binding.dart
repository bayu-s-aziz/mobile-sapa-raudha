import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_controller.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_controller.dart';
import 'admin_main_layout_controller.dart';

class AdminMainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMainLayoutController>(() => AdminMainLayoutController());

    // Kita juga perlu mendaftarkan controller untuk halaman
    // yang akan ditampilkan di dalam layout
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    Get.lazyPut<AdminUserManagementController>(
      () => AdminUserManagementController(),
    );
    // Daftarkan controller stub lainnya di sini
  }
}
