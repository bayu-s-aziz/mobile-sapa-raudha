import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/modules/admin_student_form/admin_student_form_view.dart';
import 'package:sapa_raudha/app/modules/admin_student_form/admin_student_form_controller.dart';
import 'admin_student_management_controller.dart';

class AdminStudentManagementView
    extends GetView<AdminStudentManagementController> {
  const AdminStudentManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data siswa',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchStudents,
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
                              'NISN',
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
                              'Tempat Lahir',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Tanggal Lahir',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Alamat',
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
                        rows: controller.filteredStudents.map((student) {
                          return DataRow(
                            cells: [
                              DataCell(
                                student['photo_url'] != null
                                    ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          student['photo_url'],
                                        ),
                                        onBackgroundImageError: (_, _) {},
                                        child: student['photo_url'] == null
                                            ? Icon(
                                                Icons.person,
                                                size: 20,
                                                color: AppColors.primary,
                                              )
                                            : null,
                                      )
                                    : CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.primary
                                            .withAlpha(25),
                                        child: Icon(
                                          Icons.person,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                      ),
                              ),
                              DataCell(Text(student['nisn'] ?? '-')),
                              DataCell(
                                Container(
                                  constraints: BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    student['name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  constraints: BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    student['birth_place'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  student['birth_date'] != null
                                      ? _formatDate(student['birth_date'])
                                      : '-',
                                ),
                              ),
                              DataCell(
                                Container(
                                  constraints: BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    student['address'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              DataCell(
                                PopupMenuButton(
                                  icon: Icon(Icons.more_vert, size: 20),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () => _showEditStudentModal(
                                        context,
                                        student,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit Data'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: () => controller.deleteStudent(
                                        student['id'],
                                      ),
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
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(bottom: BorderSide(color: AppColors.alternate)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Manajemen Siswa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddStudentModal(context),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Siswa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: controller.fetchStudents,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari siswa (nama, NISN, kelas)...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.primaryBackground,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Obx(
                () => DropdownButton<int?>(
                  value: controller.selectedClassFilter.value,
                  hint: const Text('Semua Kelas'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua Kelas'),
                    ),
                    ...controller.classes.map(
                      (c) => DropdownMenuItem(
                        value: c['id'],
                        child: Text(c['name'] ?? ''),
                      ),
                    ),
                  ],
                  onChanged: controller.filterByClass,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditStudentModal(BuildContext context, dynamic student) {
    Get.lazyPut(() => AdminStudentFormController());

    // Manually set the data after controller is created
    final formController = Get.find<AdminStudentFormController>();
    formController.existingStudent = student;
    formController.isEditMode.value = true;
    formController.nameController.text = student['name'] ?? '';
    formController.nisnController.text = student['nisn'] ?? '';
    formController.nisController.text = student['nis'] ?? '';
    formController.birthPlaceController.text = student['birth_place'] ?? '';
    formController.birthDateController.text = student['birth_date'] ?? '';
    formController.addressController.text = student['address'] ?? '';
    formController.selectedGender.value = student['gender'];
    formController.selectedClassId.value = student['class_id'];
    if (student['birth_date'] != null) {
      try {
        formController.selectedBirthDate.value = DateTime.parse(
          student['birth_date'],
        );
      } catch (e) {
        // Ignore parse error
      }
    }
    // Parent data
    formController.fatherNameController.text = student['father_name'] ?? '';
    formController.motherNameController.text = student['mother_name'] ?? '';
    formController.fatherPhoneController.text = student['father_phone'] ?? '';
    formController.motherPhoneController.text = student['mother_phone'] ?? '';
    formController.passwordController.text = student['password'] ?? '';

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
                      'Edit Siswa',
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
              const Expanded(child: AdminStudentFormView()),
            ],
          ),
        ),
      ),
      arguments: student,
    ).then((result) {
      if (result == true) {
        controller.fetchStudents();
      }
    });
  }

  void _showAddStudentModal(BuildContext context) {
    // Delete existing controller if any to ensure fresh state
    Get.delete<AdminStudentFormController>();
    Get.put(AdminStudentFormController());
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
                      'Tambah Siswa',
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
              const Expanded(child: AdminStudentFormView()),
            ],
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        controller.fetchStudents();
      }
    });
  }
}
