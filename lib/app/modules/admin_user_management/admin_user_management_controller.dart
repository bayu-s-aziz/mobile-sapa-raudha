import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/teacher_model.dart';
import '../../data/models/parent_model.dart';
import '../../data/services/teacher_service.dart';
import '../../data/services/parent_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminUserManagementController extends GetxController {
  late final TeacherService _teacherService;
  late final ParentService _parentService;

  final RxList<Teacher> teachers = <Teacher>[].obs;
  final RxList<Parent> parents = <Parent>[].obs;
  final RxList<Teacher> filteredTeachers = <Teacher>[].obs;
  final RxList<Parent> filteredParents = <Parent>[].obs;

  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs; // 0: Guru, 1: Orang Tua
  final RxString searchQuery = ''.obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _teacherService = Get.find<TeacherService>();
    _parentService = Get.find<ParentService>();
    fetchData();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      applyFilters();
    });
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      await Future.wait([fetchTeachers(), fetchParents()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTeachers() async {
    try {
      final data = await _teacherService.getAllTeachers();
      teachers.value = data;
      applyFilters();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data guru: $e');
    }
  }

  Future<void> fetchParents() async {
    try {
      final data = await _parentService.getAllParents();
      parents.value = data;
      applyFilters();
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data orang tua: $e');
    }
  }

  void applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredTeachers.value = teachers.toList();
      filteredParents.value = parents.toList();
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredTeachers.value = teachers
          .where(
            (t) =>
                t.name.toLowerCase().contains(query) ||
                (t.email.toLowerCase().contains(query)) ||
                (t.nip?.toLowerCase().contains(query) ?? false),
          )
          .toList();
      filteredParents.value = parents
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                (p.email.toLowerCase().contains(query)) ||
                (p.phone?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void editTeacher(Teacher teacher) {
    // Will be handled by view modal
    fetchData();
  }

  void editParent(Parent parent) {
    fetchData();
  }

  Future<void> deleteTeacher(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus data guru ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;
        await _teacherService.deleteTeacher(id);
        await fetchTeachers();
        SnackbarHelper.showSuccess('Data guru berhasil dihapus');
      } catch (e) {
        SnackbarHelper.showError('Gagal menghapus data guru: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteParent(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus data orang tua ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;
        await _parentService.deleteParent(id);
        await fetchParents();
        SnackbarHelper.showSuccess('Data orang tua berhasil dihapus');
      } catch (e) {
        SnackbarHelper.showError('Gagal menghapus data orang tua: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
