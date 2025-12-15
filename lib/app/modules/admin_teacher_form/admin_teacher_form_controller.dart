import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/teacher_model.dart';
import '../../data/services/teacher_service.dart';

class AdminTeacherFormController extends GetxController {
  late final TeacherService _teacherService;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nipController = TextEditingController();
  final subjectController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final Rx<File?> selectedPhoto = Rx<File?>(null);
  Teacher? existingTeacher;

  @override
  void onInit() {
    super.onInit();
    _teacherService = Get.find<TeacherService>();

    // Check if we're in edit mode
    if (Get.arguments != null && Get.arguments is Teacher) {
      existingTeacher = Get.arguments as Teacher;
      isEditMode.value = true;
      _populateForm();
    }
  }

  void _populateForm() {
    if (existingTeacher != null) {
      nameController.text = existingTeacher!.name;
      emailController.text = existingTeacher!.email;
      phoneController.text = existingTeacher!.phone ?? '';
      nipController.text = existingTeacher!.nip ?? '';
      subjectController.text = existingTeacher!.subject ?? '';
      passwordController.text = existingTeacher!.password ?? '';
    }
  }

  Future<void> pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedPhoto.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final teacher = Teacher(
        id: existingTeacher?.id ?? '',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        nip: nipController.text.trim(),
        subject: subjectController.text.trim(),
        gender: null,
        education: null,
        joinDate: existingTeacher?.joinDate ?? DateTime.now(),
        isActive: true,
      );

      String teacherId;
      if (isEditMode.value && existingTeacher != null) {
        await _teacherService.updateTeacher(existingTeacher!.id, teacher);
        teacherId = existingTeacher!.id;
      } else {
        final newTeacher = await _teacherService.createTeacher(teacher);
        teacherId = newTeacher.id;
      }

      // Upload photo if selected
      if (selectedPhoto.value != null) {
        await _teacherService.uploadTeacherPhoto(
          teacherId,
          selectedPhoto.value!,
        );
      }

      Get.back();
      Get.snackbar(
        'Berhasil',
        isEditMode.value
            ? 'Data guru berhasil diperbarui'
            : 'Data guru berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan data guru: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nipController.dispose();
    subjectController.dispose();
    super.onClose();
  }
}
