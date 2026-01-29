// lib/app/modules/student_list/student_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/student_list/student_list_controller.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';

import 'widgets/student_list_tile.dart'; // Widget kustom (dibuat di bawah)

class StudentListView extends GetView<StudentListController> {
  const StudentListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh student list when the page becomes visible so the data is
    // always up-to-date when the user accesses this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        controller.fetchStudents();
      } catch (_) {}
    });

    return Scaffold(
      body: FloatingPage(
        title: 'Data Siswa',
        scrollable: false,
        child: Column(
          children: [
            // Kolom Pencarian
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 8.0),
              child: TextFormField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau kelas siswa...',
                  prefixIcon: const Icon(Icons.search),
                  // Use ValueListenableBuilder instead of Obx because TextEditingController
                  // is not an Rx variable. Obx without reactive dependencies triggers
                  // 'improper use' warning. TextEditingController already notifies listeners
                  // on text changes.
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.searchController,
                    builder: (context, value, _) {
                      return (value.text.isNotEmpty)
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                controller.searchController.clear();
                              },
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
            // Filter Kelompok (Dropdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(
                () => Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: controller.selectedGroup.value,
                    items: const [
                      DropdownMenuItem(value: 'A,B', child: Text('Semua')),
                      DropdownMenuItem(value: 'A', child: Text('A')),
                      DropdownMenuItem(value: 'B', child: Text('B')),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.setGroupFilter(val);
                    },
                  ),
                ),
              ),
            ),

            // Daftar Siswa
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.filteredStudents.isEmpty) {
                  return const Center(
                    child: Text(
                      'Siswa tidak ditemukan.',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  itemCount: controller.filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = controller.filteredStudents[index];
                    return StudentListTile(
                      student: student,
                      onTap: () => controller.goToStudentDetail(student),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
