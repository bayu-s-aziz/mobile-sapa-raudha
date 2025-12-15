// [KODE LENGKAP]

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'package:sapa_raudha/app/modules/leave_list/leave_list_controller.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

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

  late final LeaveService _leaveService;
  late final LocalStorageService _storage;
  String? _studentNisn;

  @override
  void onInit() {
    super.onInit();
    _leaveService = Get.find<LeaveService>();
    _storage = Get.find<LocalStorageService>();
    final profile = _storage.read<Map<String, dynamic>>('profile');
    _studentNisn = profile?['nisn'] as String?;
  }

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
      SnackbarHelper.showError("Gagal mengambil gambar: $e");
    }
  }

  // --- FUNGSI BARU UNTUK HAPUS GAMBAR ---
  void clearImage() {
    selectedFile.value = null;
  }
  // -------------------------------------

  void submitLeaveRequest() async {
    if (!formKey.currentState!.validate()) return;
    if (_studentNisn == null) {
      SnackbarHelper.showError('NISN anak tidak ditemukan');
      return;
    }

    final requestDate = startDateController.text.trim();
    final reason = reasonController.text.trim();

    try {
      await _leaveService.submitLeave(
        studentNisn: _studentNisn!,
        requestDate: requestDate,
        reason: reason,
        attachment: selectedFile.value,
      );

      SnackbarHelper.showSuccess("Formulir izin terkirim.");

      clearImage();
      reasonController.clear();
      startDateController.clear();
      endDateController.clear();
      leaveType.value = '';
      formKey.currentState?.reset();

      // Kembalikan ke daftar izin dan segarkan datanya
      final home = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : null;
      final leaveList = Get.isRegistered<LeaveListController>()
          ? Get.find<LeaveListController>()
          : null;

      home?.changeTabIndex(2); // Tab Izin untuk orang tua
      await leaveList?.fetchLeaves();
      Get.back();
    } catch (e) {
      SnackbarHelper.showError('Pengajuan izin gagal: $e');
    }
  }
}
