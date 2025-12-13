import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';

import 'admin_main_layout_controller.dart';

class AdminMainLayoutView extends GetView<AdminMainLayoutController> {
  const AdminMainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 960;

            return Obx(
              () => Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(vertical: isCompact ? 8 : 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.alternate),
                    ),
                    child: NavigationRail(
                      extended: !isCompact,
                      selectedIndex: controller.selectedIndex.value,
                      onDestinationSelected: (index) =>
                          controller.changePage(index),
                      labelType: isCompact
                          ? NavigationRailLabelType.selected
                          : NavigationRailLabelType.none,
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: Icon(Icons.school, color: AppColors.primary),
                      ),
                      selectedIconTheme: const IconThemeData(size: 24),
                      destinations: const [
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
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: controller.pages[controller.selectedIndex.value],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
