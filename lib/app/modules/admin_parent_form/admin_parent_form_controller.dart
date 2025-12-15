import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/parent_model.dart';
import '../../data/services/parent_service.dart';

class AdminParentFormController extends GetxController {
  late final ParentService _parentService;

  final formKey = GlobalKey<FormState>();
  final studentNisnController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final Rx<File?> selectedPhoto = Rx<File?>(null);
  Parent? existingParent;

  @override
  void onInit() {
    super.onInit();
    _parentService = Get.find<ParentService>();

    // Check if we're in edit mode
    if (Get.arguments != null && Get.arguments is Parent) {
      existingParent = Get.arguments as Parent;
      isEditMode.value = true;
      _populateForm();
    }
  }

  void _populateForm() {
    if (existingParent != null) {
      studentNisnController.text = existingParent!.studentNisn ?? '';
      fatherNameController.text = existingParent!.fatherName ?? '';
      motherNameController.text = existingParent!.motherName ?? '';
      phoneController.text = existingParent!.phone ?? '';
      passwordController.text = existingParent!.password ?? '';
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

      final parent = Parent(
        id: existingParent?.id ?? '',
        name: fatherNameController.text.trim(),
        email: existingParent?.email ?? '',
        phone: phoneController.text.trim(),
        studentIds: existingParent?.studentIds ?? [],
        isActive: true,
        fatherName: fatherNameController.text.trim(),
        motherName: motherNameController.text.trim(),
        studentNisn: studentNisnController.text.trim(),
      );

      String parentId;
      if (isEditMode.value && existingParent != null) {
        await _parentService.updateParent(existingParent!.id, parent);
        parentId = existingParent!.id;
      } else {
        await _parentService.createParent(parent);
        parentId = parent.id;
      }

      // Upload photo if selected
      if (selectedPhoto.value != null) {
        await _parentService.uploadParentPhoto(parentId, selectedPhoto.value!);
      }

      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        isEditMode.value
            ? 'Data orang tua berhasil diperbarui'
            : 'Data orang tua berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan data orang tua: $e',
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
    studentNisnController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
