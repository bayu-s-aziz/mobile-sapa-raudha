import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_view.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_student_management/admin_student_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_attendance_management/admin_attendance_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_class_management/admin_class_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_management/admin_announcement_management_view.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';

class AdminMainLayoutController extends GetxController {
  // Menyimpan indeks halaman yang sedang aktif
  var selectedIndex = 0.obs;

  // Daftar halaman/view untuk ditampilkan
  final List<Widget> pages = [
    const AdminDashboardView(),
    const AdminUserManagementView(),
    const AdminStudentManagementView(),
    const AdminClassManagementView(),
    const AdminAttendanceManagementView(),
    const AdminAnnouncementManagementView(),
  ];

  void changePage(int index) {
    if (index == 6) {
      // Index 6 adalah Logout (setelah menambah Pengumuman)
      _logout();
    } else {
      selectedIndex.value = index;
    }
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final storage = Get.find<LocalStorageService>();
              storage.remove('token');
              storage.remove('role');
              storage.remove('profile');
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
