import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/student_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminStudentFormController extends GetxController {
  late final StudentService _studentService;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nisnController = TextEditingController();
  final nisController = TextEditingController();
  final birthPlaceController = TextEditingController();
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final fatherPhoneController = TextEditingController();
  final motherPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final Rx<File?> selectedPhoto = Rx<File?>(null);
  final Rxn<DateTime> selectedBirthDate = Rxn<DateTime>();
  final Rxn<String> selectedGender = Rxn<String>();
  final Rxn<int> selectedClassId = Rxn<int>();
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  Map<String, dynamic>? existingStudent;

  @override
  void onInit() {
    super.onInit();
    _studentService = Get.find<StudentService>();
    _loadClasses();

    // Check if we're in edit mode
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      existingStudent = Get.arguments as Map<String, dynamic>;
      isEditMode.value = true;
      _populateForm();
    }
  }

  Future<void> _loadClasses() async {
    try {
      final data = await _studentService.getClasses();
      classes.assignAll(data);
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat data kelas: $e');
    }
  }

  void _populateForm() {
    if (existingStudent != null) {
      nameController.text = existingStudent!['name'] ?? '';
      nisnController.text = existingStudent!['nisn'] ?? '';
      nisController.text = existingStudent!['nis'] ?? '';
      birthPlaceController.text = existingStudent!['birth_place'] ?? '';
      addressController.text = existingStudent!['address'] ?? '';
      selectedGender.value = existingStudent!['gender'];
      selectedClassId.value = existingStudent!['class_id'];
      fatherNameController.text = existingStudent!['father_name'] ?? '';
      motherNameController.text = existingStudent!['mother_name'] ?? '';
      fatherPhoneController.text = existingStudent!['father_phone'] ?? '';
      motherPhoneController.text = existingStudent!['mother_phone'] ?? '';

      if (existingStudent!['birth_date'] != null) {
        try {
          selectedBirthDate.value = DateTime.parse(
            existingStudent!['birth_date'],
          );
          birthDateController.text =
              '${selectedBirthDate.value!.day}/${selectedBirthDate.value!.month}/${selectedBirthDate.value!.year}';
        } catch (e) {
          // Ignore if date parsing fails
        }
      }
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
      SnackbarHelper.showError('Gagal memilih foto: $e');
    }
  }

  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate.value ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedBirthDate.value = picked;
      birthDateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final studentData = {
        'name': nameController.text.trim(),
        'nisn': nisnController.text.trim(),
        'nis': nisController.text.trim(),
        'gender': selectedGender.value,
        'class_id': selectedClassId.value,
        'birth_place': birthPlaceController.text.trim(),
        'birth_date': selectedBirthDate.value?.toIso8601String(),
        'address': addressController.text.trim(),
        'father_name': fatherNameController.text.trim(),
        'mother_name': motherNameController.text.trim(),
        'father_phone': fatherPhoneController.text.trim(),
        'mother_phone': motherPhoneController.text.trim(),
        'parent_password': passwordController.text.trim(),
      };

      int studentId;
      if (isEditMode.value && existingStudent != null) {
        await _studentService.updateStudent(
          existingStudent!['id'],
          studentData,
        );
        studentId = existingStudent!['id'];
      } else {
        final result = await _studentService.createStudent(studentData);
        studentId = result['id'];
      }

      // Upload photo if selected
      if (selectedPhoto.value != null) {
        await _studentService.uploadStudentPhoto(
          studentId,
          selectedPhoto.value!,
        );
      }

      Get.back(result: true);
      SnackbarHelper.showSuccess(
        isEditMode.value
            ? 'Data siswa berhasil diperbarui'
            : 'Data siswa berhasil ditambahkan',
      );
    } catch (e) {
      SnackbarHelper.showError('Gagal menyimpan data siswa: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    nisnController.dispose();
    nisController.dispose();
    birthPlaceController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    fatherPhoneController.dispose();
    motherPhoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
