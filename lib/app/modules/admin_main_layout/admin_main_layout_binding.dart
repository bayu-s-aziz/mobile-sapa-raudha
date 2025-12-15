import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_controller.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_controller.dart';
import 'package:sapa_raudha/app/modules/admin_student_management/admin_student_management_controller.dart';
import 'package:sapa_raudha/app/modules/admin_attendance_management/admin_attendance_management_controller.dart';
import 'package:sapa_raudha/app/modules/admin_class_management/admin_class_management_controller.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_management/admin_announcement_management_controller.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/data/services/teacher_service.dart';
import 'package:sapa_raudha/app/data/services/parent_service.dart';
import 'admin_main_layout_controller.dart';

class AdminMainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMainLayoutController>(() => AdminMainLayoutController());

    // Register services first (before controllers that depend on them)
    Get.put<AnnouncementService>(AnnouncementService(), permanent: true);
    Get.put<TeacherService>(TeacherService(), permanent: true);
    Get.put<ParentService>(ParentService(), permanent: true);

    // Kita juga perlu mendaftarkan controller untuk halaman
    // yang akan ditampilkan di dalam layout
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    Get.put<AdminUserManagementController>(
      AdminUserManagementController(),
      permanent: true,
    );
    Get.lazyPut<AdminStudentManagementController>(
      () => AdminStudentManagementController(),
    );
    Get.lazyPut<AdminAttendanceManagementController>(
      () => AdminAttendanceManagementController(),
    );
    Get.lazyPut<AdminClassManagementController>(
      () => AdminClassManagementController(),
    );
    Get.lazyPut<AdminAnnouncementManagementController>(
      () => AdminAnnouncementManagementController(),
    );
  }
}
