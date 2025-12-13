// [KODE LENGKAP]

import 'dart:io'; // <-- Tambahkan import ini
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // <-- Tambahkan import ini

class RequestLeaveController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final RxString leaveType = ''.obs; // sakit | izin

  // --- TAMBAHAN UNTUK FILE UPLOAD ---
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedFile = Rx<File?>(null);
  // ---------------------------------

  @override
  void onClose() {
    reasonController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  // --- FUNGSI BARU UNTUK AMBIL GAMBAR ---
  Future<void> pickImage() async {
    try {
      // Ambil gambar dari galeri
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi gambar
      );

      if (pickedImage != null) {
        selectedFile.value = File(pickedImage.path);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengambil gambar: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha((0.8 * 255).round()),
        colorText: Colors.white,
      );
    }
  }

  // --- FUNGSI BARU UNTUK HAPUS GAMBAR ---
  void clearImage() {
    selectedFile.value = null;
  }
  // -------------------------------------

  void submitLeaveRequest() {
    if (formKey.currentState!.validate()) {
      // --- LOGIKA SUBMIT ANDA ---
      // Anda bisa tambahkan 'selectedFile.value' ke data yang dikirim ke server
      // Contoh:
      // final jenis = leaveType.value;
      // final file = selectedFile.value;
      // final alasan = reasonController.text;
      // ...

      Get.snackbar(
        "Berhasil",
        "Formulir izin terkirim.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reset form
      clearImage();
      reasonController.clear();
      startDateController.clear();
      endDateController.clear();
      leaveType.value = '';
      formKey.currentState?.reset();
    }
  }
}
