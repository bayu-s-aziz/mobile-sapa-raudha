import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

        _showPresenceConfirmation(scannedData.value);

        Future.delayed(const Duration(seconds: 2), () {
          scannedData.value = '';
          _isProcessing = false;
        });
      }
    }
  }

  void toggleFlash() {
    scannerController.toggleTorch();
    isFlashOn.value = !isFlashOn.value;
  }

  void _showPresenceConfirmation(String studentInfo) {
    Get.snackbar(
      "Presensi Berhasil",
      "Siswa dengan ID: $studentInfo telah ditandai hadir.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
