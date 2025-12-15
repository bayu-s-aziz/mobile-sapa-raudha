import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/class_service.dart';
import 'package:sapa_raudha/app/data/services/teacher_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class AdminClassManagementController extends GetxController {
  final ClassService _classService = Get.find<ClassService>();
  final TeacherService _teacherService = Get.find<TeacherService>();

  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> teachers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    try {
      final teachersList = await _teacherService.getAllTeachers();
      teachers.value = teachersList
          .map((t) => {'id': int.tryParse(t.id) ?? 0, 'name': t.name})
          .toList();
    } catch (e) {
      // Silently fail, teachers dropdown will be empty
    }
  }

  Future<void> fetchClasses() async {
    isLoading(true);
    try {
      final data = await _classService.getClasses();
      classes.assignAll(data);
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data kelas: $e');
    } finally {
      isLoading(false);
    }
  }

  void showAddClassDialog() {
    final nameController = TextEditingController();
    final academicYearController = TextEditingController();
    final selectedTeacherId = Rxn<int>();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Kelas Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kelas *',
                    helperText: 'Contoh: Kelas 1A, Kelas 2B',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: academicYearController,
                  decoration: const InputDecoration(
                    labelText: 'Tahun Ajaran *',
                    helperText: 'Contoh: 2024/2025',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tahun ajaran tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(
                  () => DropdownButtonFormField<int>(
                    initialValue: selectedTeacherId.value,
                    decoration: const InputDecoration(
                      labelText: 'Wali Kelas',
                      helperText: 'Pilih wali kelas (opsional)',
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Belum ada wali kelas'),
                      ),
                      ...teachers.map(
                        (t) => DropdownMenuItem<int>(
                          value: t['id'] as int,
                          child: Text(t['name'] ?? ''),
                        ),
                      ),
                    ],
                    onChanged: (value) => selectedTeacherId.value = value,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Get.back();
                try {
                  final data = <String, dynamic>{
                    'name': nameController.text.trim(),
                    'academic_year': academicYearController.text.trim(),
                  };
                  if (selectedTeacherId.value != null) {
                    data['homeroom_teacher_id'] = selectedTeacherId.value!;
                  }
                  await _classService.createClass(data);
                  SnackbarHelper.showSuccess('Kelas berhasil ditambahkan');
                  await fetchClasses();
                } catch (e) {
                  SnackbarHelper.showError('Gagal menambahkan kelas: $e');
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void showEditClassDialog(Map<String, dynamic> classData) {
    final nameController = TextEditingController(text: classData['name']);
    final academicYearController = TextEditingController(
      text: classData['academic_year'] ?? '',
    );
    final selectedTeacherId = Rxn<int>(classData['homeroom_teacher_id']);
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Kelas'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kelas *',
                    helperText: 'Contoh: Kelas 1A, Kelas 2B',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: academicYearController,
                  decoration: const InputDecoration(
                    labelText: 'Tahun Ajaran *',
                    helperText: 'Contoh: 2024/2025',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tahun ajaran tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(
                  () => DropdownButtonFormField<int>(
                    initialValue: selectedTeacherId.value,
                    decoration: const InputDecoration(
                      labelText: 'Wali Kelas',
                      helperText: 'Pilih wali kelas (opsional)',
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Belum ada wali kelas'),
                      ),
                      ...teachers.map(
                        (t) => DropdownMenuItem<int>(
                          value: t['id'] as int,
                          child: Text(t['name'] ?? ''),
                        ),
                      ),
                    ],
                    onChanged: (value) => selectedTeacherId.value = value,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Get.back();
                try {
                  final data = <String, dynamic>{
                    'name': nameController.text.trim(),
                    'academic_year': academicYearController.text.trim(),
                  };
                  if (selectedTeacherId.value != null) {
                    data['homeroom_teacher_id'] = selectedTeacherId.value!;
                  }
                  await _classService.updateClass(classData['id'], data);
                  SnackbarHelper.showSuccess('Kelas berhasil diperbarui');
                  await fetchClasses();
                } catch (e) {
                  SnackbarHelper.showError('Gagal memperbarui kelas: $e');
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void deleteClass(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kelas ini? Data siswa dalam kelas ini tidak akan terhapus.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await _classService.deleteClass(id);
                SnackbarHelper.showSuccess('Kelas berhasil dihapus');
                await fetchClasses();
              } catch (e) {
                SnackbarHelper.showError('Gagal menghapus kelas: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
