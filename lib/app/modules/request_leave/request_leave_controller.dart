// [KODE LENGKAP]

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart';
import 'package:sapa_raudha/app/modules/leave_list/leave_list_controller.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';

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
  late final ProfileService _profileService = Get.find<ProfileService>();
  String? _studentNisn;

  @override
  void onInit() {
    super.onInit();
    _leaveService = Get.find<LeaveService>();
    _storage = Get.find<LocalStorageService>();

    // Prefer ProfileService stored NISN, then storage 'nisn', then legacy profile key
    final profile = _storage.read<Map<String, dynamic>>('profile');
    _studentNisn =
        _profileService.getStoredNisn() ??
        _storage.read<String>('nisn') ??
        profile?['nisn'] as String?;

    // NISN resolved (if available) on init
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

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Pengajuan Izin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajukan izin untuk tanggal: $requestDate'),
            const SizedBox(height: 8),
            Text('Alasan: ${reason.isNotEmpty ? reason : '-'}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Get.back(result: false),
          ),
          TextButton(
            child: const Text('Kirim'),
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Perform submission and close the page only on success so user sees
    // validation errors if something goes wrong.
    final success = await _performSubmit(
      requestDate: requestDate,
      reason: reason,
    );
    if (!success) return;

    // Ensure the Izin tab is active and refresh list, then close the request page.
    try {
      final home = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : null;
      final leaveList = Get.isRegistered<LeaveListController>()
          ? Get.find<LeaveListController>()
          : null;

      // Give dialog/animations a moment to finish
      await Future.delayed(const Duration(milliseconds: 150));

      // If this page was opened as a separate route, pop it to reveal Home
      if (Get.currentRoute == Routes.requestLeave) {
        Get.back();
        // Small delay to allow navigation animations to settle
        await Future.delayed(const Duration(milliseconds: 120));
      } else {
        // If it was rendered as an action view inside Home, clear it explicitly
        if (home?.currentActionView.value != null) {
          home?.clearActionView();
          // Give a short moment for the UI to update
          await Future.delayed(const Duration(milliseconds: 80));
        }
      }

      // Ensure the Izin tab is active so user lands there
      home?.changeTabIndex(2);

      // Refresh list to show newly submitted izin
      if (leaveList != null) {
        await leaveList.fetchLeaves();
      } else if (Get.isRegistered<LeaveListController>()) {
        await Get.find<LeaveListController>().fetchLeaves();
      }

      // Sinkronisasi status kehadiran anak di dashboard orang tua
      // (berfungsi jika HomeController terdaftar di konteks saat ini)
      try {
        home?.fetchChildTodayStatus();
      } catch (_) {}
    } catch (_) {}
  }

  Future<bool> _performSubmit({
    required String requestDate,
    required String reason,
  }) async {
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

      return true;
    } catch (e) {
      SnackbarHelper.showError('Pengajuan izin gagal: $e');
      return false;
    }
  }
}
