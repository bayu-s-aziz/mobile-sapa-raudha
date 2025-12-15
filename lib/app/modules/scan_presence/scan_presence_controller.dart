import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class ScanPresenceController extends GetxController {
  // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR'); // Tidak diperlukan lagi
  // QRViewController? qrViewController; // Ganti dengan MobileScannerController

  final MobileScannerController scannerController = MobileScannerController(
    // Atur opsi kamera jika perlu, misal:
    // facing: CameraFacing.back,
    // torchEnabled: false,
    returnImage: false, // Hemat memori jika tidak butuh gambar
  );
  final RxString scannedData = ''.obs;
  final RxBool isFlashOn = false.obs;
  bool _isProcessing = false;
  late final AttendanceService _attendanceService;

  @override
  void onInit() {
    super.onInit();
    _attendanceService = Get.find<AttendanceService>();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code.isNotEmpty) {
        _isProcessing = true;
        scannedData.value = code;
        _submitAttendance(scannedData.value);
      }
    }
  }

  void toggleFlash() {
    scannerController.toggleTorch();
    isFlashOn.value = !isFlashOn.value;
  }

  void _showPresenceConfirmation(String studentInfo) {
    SnackbarHelper.showSuccess(
      "Siswa dengan ID: $studentInfo telah ditandai hadir.",
    );
  }

  Future<void> _submitAttendance(String nisn) async {
    try {
      final res = await _attendanceService.scanAttendance(nisn);
      _showPresenceConfirmation(res['student']?['name'] ?? nisn);
    } catch (e) {
      SnackbarHelper.showError("Tidak dapat merekam presensi: $e");
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        scannedData.value = '';
        _isProcessing = false;
      });
    }
  }
}
