import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_view.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_view.dart';
// Import view stub lainnya di sini
// import 'package:sapa_raudha/app/modules/admin_attendance/admin_attendance_view.dart';
// import 'package:sapa_raudha/app/modules/admin_announcements/admin_announcements_view.dart';

class AdminMainLayoutController extends GetxController {
  // Menyimpan indeks halaman yang sedang aktif
  var selectedIndex = 0.obs;

  // Daftar halaman/view untuk ditampilkan
  final List<Widget> pages = [
    AdminDashboardView(),
    AdminUserManagementView(),
    // Placeholder untuk halaman lain
    Scaffold(body: Center(child: Text("Halaman Absensi"))),
    Scaffold(body: Center(child: Text("Halaman Pengumuman"))),
  ];

  void changePage(int index) {
    if (index == 4) {
      // Index 4 adalah Logout
      // Tambahkan logika logout, misal kembali ke halaman login
      Get.offAllNamed('/login');
    } else {
      selectedIndex.value = index;
    }
  }
}
