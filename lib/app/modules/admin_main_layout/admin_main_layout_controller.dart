import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_view.dart';
import 'package:sapa_raudha/app/modules/admin_user_management/admin_user_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_student_management/admin_student_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_attendance_management/admin_attendance_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_class_management/admin_class_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_announcement_management/admin_announcement_management_view.dart';
import 'package:sapa_raudha/app/modules/admin_password_reset/admin_password_reset_view.dart';
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
    const AdminPasswordResetView(),
  ];

  @override
  void onInit() {
    super.onInit();
    _resizeWindowForAdmin();
  }

  Future<void> _resizeWindowForAdmin() async {
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      try {
        await windowManager.ensureInitialized();
        // Resize untuk admin: landscape/lebih besar
        const adminSize = Size(1280, 720);
        await windowManager.setSize(adminSize);
        await windowManager.setMinimumSize(const Size(1024, 600));
        await windowManager.setMaximumSize(const Size(1920, 1080));
        await windowManager.center();
      } catch (e) {
        print('Error resizing window for admin: $e');
      }
    }
  }

  void changePage(int index) {
    if (index == 7) {
      // Index 7 adalah Logout
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
            onPressed: () async {
              Get.back();
              final storage = Get.find<LocalStorageService>();
              storage.remove('token');
              storage.remove('role');
              storage.remove('profile');

              // Resize kembali ke resolusi default (portrait mode)
              if (!kIsWeb &&
                  (Platform.isLinux ||
                      Platform.isWindows ||
                      Platform.isMacOS)) {
                try {
                  await windowManager.ensureInitialized();
                  // Kembali ke resolusi awal: 400x800 (DEFAULT)
                  const defaultSize = Size(400, 800);
                  const defaultMinSize = Size(360, 640);
                  const defaultMaxSize = Size(450, 900);

                  await windowManager.setSize(defaultSize);
                  await windowManager.setMinimumSize(defaultMinSize);
                  await windowManager.setMaximumSize(defaultMaxSize);
                  await windowManager.center();
                } catch (e) {
                  print('Error resizing window on logout: $e');
                }
              }

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
