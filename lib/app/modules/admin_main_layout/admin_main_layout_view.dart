import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_main_layout_controller.dart';

class AdminMainLayoutView extends GetView<AdminMainLayoutController> {
  const AdminMainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan Obx untuk body yang reaktif
      body: Obx(
        () => Row(
          children: [
            // Sidebar Navigation
            NavigationRail(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) => controller.changePage(index),
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dasbor'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Pengguna'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: Text('Absensi'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.article_outlined),
                  selectedIcon: Icon(Icons.article),
                  label: Text('Pengumuman'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                ),
              ],
            ),
            VerticalDivider(thickness: 1, width: 1),

            // Content Area
            // Halaman akan berganti di sini
            Expanded(child: controller.pages[controller.selectedIndex.value]),
          ],
        ),
      ),
    );
  }
}
