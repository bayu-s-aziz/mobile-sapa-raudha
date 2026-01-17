// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
// ... imports lainnya ...
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_binding.dart';
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_view.dart';
import 'package:sapa_raudha/app/modules/admin_main_layout/admin_main_layout_binding.dart';
import 'package:sapa_raudha/app/modules/admin_main_layout/admin_main_layout_view.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_binding.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_management/admin_announcement_management_binding.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_management/admin_announcement_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_form/admin_announcement_form_binding.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_form/admin_announcement_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_teacher_form/admin_teacher_form_binding.dart';
import 'package:sapa_raudha/app/modules/admin_teacher_form/admin_teacher_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_parent_form/admin_parent_form_binding.dart';
import 'package:sapa_raudha/app/modules/admin_parent_form/admin_parent_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_student_management/admin_student_management_binding.dart';
import 'package:sapa_raudha/app/modules/admin_student_management/admin_student_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_student_form/admin_student_form_binding.dart';
import 'package:sapa_raudha/app/modules/admin_student_form/admin_student_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_password_reset/admin_password_reset_binding.dart';
import 'package:sapa_raudha/app/modules/admin_password_reset/admin_password_reset_view.dart';
import 'package:sapa_raudha/app/modules/student_detail/student_detail_binding.dart';
import '../modules/announcement_detail/announcement_detail_binding.dart'; // Import
import '../modules/announcement_list/announcement_list_binding.dart';
import '../modules/create_announcement/create_announcement_binding.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/scan_presence/scan_presence_binding.dart';
import '../modules/scan_presence/scan_presence_view.dart';
import '../modules/request_leave/request_leave_binding.dart';
import '../modules/request_leave/request_leave_view.dart';
import '../modules/attendance_history/attendance_history_binding.dart'; // Import
import '../modules/profile/profile_binding.dart';
import '../modules/edit_profile/edit_profile_binding.dart';
import '../modules/edit_profile/edit_profile_view.dart';
import '../modules/change_password/change_password_binding.dart';
import '../modules/change_password/change_password_view.dart';
import '../modules/confirm_leave/confirm_leave_binding.dart';
import '../modules/student_list/student_list_binding.dart';
import '../modules/student_detail/student_detail_view.dart';
import '../modules/student_profile/student_profile_binding.dart';
import '../modules/leave_list/leave_list_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // --- MODIFIKASI RUTE HOME ---
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      // Tambahkan semua binding untuk halaman
      // yang akan ditampilkan DI DALAM HomeView
      binding: BindingsBuilder(() {
        // Binding untuk Home (wrapper)
        HomeBinding().dependencies();
        // Binding untuk tab-tab
        AnnouncementListBinding().dependencies();
        StudentListBinding().dependencies();
        RequestLeaveBinding().dependencies();
        LeaveListBinding().dependencies();
        ProfileBinding().dependencies();

        // Binding untuk action pages
        CreateAnnouncementBinding().dependencies();
        ConfirmLeaveBinding().dependencies();
        StudentProfileBinding().dependencies();

        // --- TAMBAHKAN BINDING INI ---
        AttendanceHistoryBinding().dependencies();
        AnnouncementDetailBinding().dependencies();
        // --- AKHIR TAMBAHAN ---
      }),
    ),
    // --- AKHIR MODIFIKASI ---
    GetPage(
      name: _Paths.scanPresence,
      page: () => const ScanPresenceView(),
      binding: ScanPresenceBinding(),
    ),

    GetPage(
      name: _Paths.requestLeave,
      page: () => const RequestLeaveView(),
      binding: RequestLeaveBinding(),
    ),
    // Rute Profil
    GetPage(
      name: _Paths.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.changePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    // Rute Data Siswa
    GetPage(
      name: _Paths.studentDetail,
      page: () => const StudentDetailView(),
      binding: StudentDetailBinding(),
    ),
    // --- TAMBAHKAN GETPAGE ADMIN DI SINI ---

    // Rute utama untuk layout admin
    GetPage(
      name: _Paths.adminMain,
      page: () => AdminMainLayoutView(),
      binding: AdminMainLayoutBinding(),
    ),

    // Rute ini bisa digunakan jika Anda ingin mengakses halaman
    // secara individual, tapi untuk sekarang kita fokus
    // pada layout utama yang berisi semua halaman.
    GetPage(
      name: _Paths.adminDashboard,
      page: () => AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: _Paths.adminUserManagement,
      page: () => AdminUserManagementView(),
      binding: AdminUserManagementBinding(),
    ),
    GetPage(
      name: _Paths.adminAnnouncementManagement,
      page: () => const AdminAnnouncementManagementView(),
      binding: AdminAnnouncementManagementBinding(),
    ),
    GetPage(
      name: _Paths.adminAnnouncementAdd,
      page: () => const AdminAnnouncementFormView(),
      binding: AdminAnnouncementFormBinding(),
    ),
    GetPage(
      name: _Paths.adminAnnouncementEdit,
      page: () => const AdminAnnouncementFormView(),
      binding: AdminAnnouncementFormBinding(),
    ),
    GetPage(
      name: _Paths.adminTeacherForm,
      page: () => const AdminTeacherFormView(),
      binding: AdminTeacherFormBinding(),
    ),
    GetPage(
      name: _Paths.adminParentForm,
      page: () => const AdminParentFormView(),
      binding: AdminParentFormBinding(),
    ),
    GetPage(
      name: _Paths.adminStudentManagement,
      page: () => const AdminStudentManagementView(),
      binding: AdminStudentManagementBinding(),
    ),
    GetPage(
      name: _Paths.adminStudentForm,
      page: () => const AdminStudentFormView(),
      binding: AdminStudentFormBinding(),
    ),
    GetPage(
      name: _Paths.adminPasswordReset,
      page: () => const AdminPasswordResetView(),
      binding: AdminPasswordResetBinding(),
    ),

    // --- RUTE-RUTE INI DIHAPUS DARI TOP-LEVEL ---
    // GetPage(
    //   name: _Paths.announcementDetail,
    //   page: () => const AnnouncementDetailView(),
    //   binding: AnnouncementDetailBinding(),
    // ),
    // GetPage(
    //   name: _Paths.createAnnouncement,
    //   page: () => const CreateAnnouncementView(),
    //   binding: CreateAnnouncementBinding(),
    // ),
    // GetPage(
    //   name: _Paths.attendanceHistory,
    //   page: () => const AttendanceHistoryView(),
    //   binding: AttendanceHistoryBinding(),
    // ),
    // GetPage(
    //   name: _Paths.confirmLeave,
    //   page: () => const ConfirmLeaveView(),
    //   binding: ConfirmLeaveBinding(),
    // ),
    // GetPage(
    //   name: _Paths.studentProfile,
    //   page: () => const StudentProfileView(),
    //   binding: StudentProfileBinding(),
    // ),
    // --- AKHIR PENGHAPUSAN ---
  ];
}
