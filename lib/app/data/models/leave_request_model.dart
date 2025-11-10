// lib/app/data/models/leave_request_model.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum LeaveStatus { pending, approved, rejected }

class LeaveRequest {
  final String id;
  final String studentName;
  final String parentName;
  final String leaveType; // "Sakit" atau "Izin"
  final DateTimeRange dateRange;
  final String reason;
  final LeaveStatus status;

  LeaveRequest({
    required this.id,
    required this.studentName,
    required this.parentName,
    required this.leaveType,
    required this.dateRange,
    required this.reason,
    this.status = LeaveStatus.pending,
  });

  // Salin objek dengan status baru
  LeaveRequest copyWith({LeaveStatus? status}) {
    return LeaveRequest(
      id: id,
      studentName: studentName,
      parentName: parentName,
      leaveType: leaveType,
      dateRange: dateRange,
      reason: reason,
      status: status ?? this.status,
    );
  }
}

class RequestLeaveController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

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
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedImage != null) {
        selectedFile.value = File(pickedImage.path);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengambil gambar: $e",
        snackPosition: SnackPosition.BOTTOM,
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
      // final file = selectedFile.value;
      // final alasan = reasonController.text;
      // ...

      Get.snackbar(
        "Berhasil",
        "Formulir izin terkirim (file terlampir jika ada).",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
