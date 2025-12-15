import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/modules/admin_teacher_form/admin_teacher_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_teacher_form/admin_teacher_form_controller.dart';
import 'package:sapa_raudha/app/modules/admin_parent_form/admin_parent_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_parent_form/admin_parent_form_controller.dart';
import 'package:sapa_raudha/app/data/models/teacher_model.dart';
import 'package:sapa_raudha/app/data/models/parent_model.dart';
import 'admin_user_management_controller.dart';

class AdminUserManagementView extends GetView<AdminUserManagementController> {
  const AdminUserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildSearchAndTabs(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return controller.selectedTab.value == 0
                  ? _buildTeachersList(context)
                  : _buildParentsList(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(bottom: BorderSide(color: AppColors.alternate)),
      ),
      child: Row(
        children: [
          Text(
            'Manajemen Pengguna',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.selectedTab.value == 0
                  ? () => _showAddTeacherModal(context)
                  : () => _showAddParentModal(context),
              icon: const Icon(Icons.add),
              label: Text(
                controller.selectedTab.value == 0
                    ? 'Tambah Guru'
                    : 'Tambah Orang Tua',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchData,
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(bottom: BorderSide(color: AppColors.alternate)),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Cari pengguna...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.primaryBackground,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Guru',
                    Icons.person_outline,
                    0,
                    controller.teachers.length,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    'Orang Tua',
                    Icons.family_restroom,
                    1,
                    controller.parents.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index, int count) {
    final isSelected = controller.selectedTab.value == index;
    return InkWell(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.alternate,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.secondaryText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$label ($count)',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeachersList(BuildContext context) {
    return Obx(() {
      if (controller.filteredTeachers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada data guru',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchTeachers,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.alternate),
            ),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                horizontalMargin: 24,
                columnSpacing: 24,
                headingRowColor: WidgetStateProperty.all(
                  AppColors.primary.withAlpha(25),
                ),
                headingRowHeight: 56,
                dataRowMaxHeight: 72,
                columns: [
                  DataColumn(
                    label: Text(
                      'Foto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'NIK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nama',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Telepon',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Aksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
                rows: controller.filteredTeachers.map((teacher) {
                  return DataRow(
                    cells: [
                      DataCell(
                        teacher.photoUrl != null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  teacher.photoUrl!,
                                ),
                                onBackgroundImageError: (_, _) {},
                                child: teacher.photoUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: 20,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              )
                            : CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withAlpha(
                                  25,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                      DataCell(Text(teacher.nip ?? '-')),
                      DataCell(
                        Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(
                            teacher.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(teacher.phone ?? '-')),
                      DataCell(
                        Text(
                          teacher.password ?? '******',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      DataCell(
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert, size: 20),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () =>
                                  _showEditTeacherModal(context, teacher),
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Data'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => controller.deleteTeacher(teacher.id),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildParentsList(BuildContext context) {
    return Obx(() {
      if (controller.filteredParents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.family_restroom,
                size: 64,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada data orang tua',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchParents,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.alternate),
            ),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                horizontalMargin: 24,
                columnSpacing: 20,
                headingRowColor: WidgetStateProperty.all(
                  AppColors.accent2.withAlpha(25),
                ),
                headingRowHeight: 56,
                dataRowMaxHeight: 72,
                columns: [
                  DataColumn(
                    label: Text(
                      'Foto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'NISN Anak',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nama Ayah',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nama Ibu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Telepon',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Aksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
                rows: controller.filteredParents.map((parent) {
                  return DataRow(
                    cells: [
                      DataCell(
                        parent.photoUrl != null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(parent.photoUrl!),
                                onBackgroundImageError: (_, __) {},
                                child: parent.photoUrl == null
                                    ? Icon(
                                        Icons.family_restroom,
                                        size: 20,
                                        color: AppColors.accent2,
                                      )
                                    : null,
                              )
                            : CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.accent2.withAlpha(
                                  25,
                                ),
                                child: Icon(
                                  Icons.family_restroom,
                                  size: 20,
                                  color: AppColors.accent2,
                                ),
                              ),
                      ),
                      DataCell(Text(parent.studentNisn ?? '-')),
                      DataCell(
                        Container(
                          constraints: BoxConstraints(maxWidth: 150),
                          child: Text(
                            parent.fatherName ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: BoxConstraints(maxWidth: 150),
                          child: Text(
                            parent.motherName ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(parent.phone ?? '-')),
                      DataCell(
                        Text(
                          parent.password ?? '******',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      DataCell(
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert, size: 20),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () =>
                                  _showEditParentModal(context, parent),
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Data'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => controller.deleteParent(parent.id),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showEditTeacherModal(BuildContext context, Teacher teacher) {
    Get.lazyPut(() => AdminTeacherFormController());

    // Manually set the data after controller is created
    final formController = Get.find<AdminTeacherFormController>();
    formController.existingTeacher = teacher;
    formController.isEditMode.value = true;
    formController.nameController.text = teacher.name;
    formController.emailController.text = teacher.email;
    formController.phoneController.text = teacher.phone ?? '';
    formController.nipController.text = teacher.nip ?? '';
    formController.subjectController.text = teacher.subject ?? '';
    formController.passwordController.text = teacher.password ?? '';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Edit Guru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Expanded(child: AdminTeacherFormView()),
            ],
          ),
        ),
      ),
      arguments: teacher,
    ).then((result) {
      if (result == true) {
        controller.fetchData();
      }
    });
  }

  void _showEditParentModal(BuildContext context, Parent parent) {
    Get.lazyPut(() => AdminParentFormController());

    // Manually set the data after controller is created
    final formController = Get.find<AdminParentFormController>();
    formController.existingParent = parent;
    formController.isEditMode.value = true;
    formController.studentNisnController.text = parent.studentNisn ?? '';
    formController.fatherNameController.text = parent.fatherName ?? '';
    formController.motherNameController.text = parent.motherName ?? '';
    formController.phoneController.text = parent.phone ?? '';
    formController.passwordController.text = parent.password ?? '';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Edit Orang Tua',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Expanded(child: AdminParentFormView()),
            ],
          ),
        ),
      ),
      arguments: parent,
    ).then((result) {
      if (result == true) {
        controller.fetchData();
      }
    });
  }

  void _showAddParentModal(BuildContext context) {
    // Delete existing controller if any to ensure fresh state
    Get.delete<AdminParentFormController>();
    Get.put(AdminParentFormController());
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Tambah Orang Tua',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Expanded(child: AdminParentFormView()),
            ],
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        controller.fetchData();
      }
    });
  }

  void _showAddTeacherModal(BuildContext context) {
    // Delete existing controller if any to ensure fresh state
    Get.delete<AdminTeacherFormController>();
    Get.put(AdminTeacherFormController());
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Tambah Guru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Expanded(child: AdminTeacherFormView()),
            ],
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        controller.fetchData();
      }
    });
  }
}
