import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'dart:io' show Platform;

class ScanPresenceController extends GetxController {
  // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR'); // Tidak diperlukan lagi
  // QRViewController? qrViewController; // Ganti dengan MobileScannerController

  MobileScannerController? scannerController;

  // Scanner tersedia di Android, iOS, dan Web (browser)
  // Linux, Windows, macOS desktop tidak didukung oleh mobile_scanner
  bool get isScannerAvailable =>
      kIsWeb || (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

  final RxString scannedData = ''.obs;
  final RxBool isFlashOn = false.obs;
  bool _isProcessing = false;
  late final AttendanceService _attendanceService;

  @override
  void onInit() {
    super.onInit();
    _attendanceService = Get.find<AttendanceService>();

    // Initialize scanner only on supported platforms
    if (isScannerAvailable) {
      scannerController = MobileScannerController(returnImage: false);
    }
  }

  @override
  void onClose() {
    scannerController?.dispose();
    super.onClose();
  }

  void onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code.isNotEmpty) {
        final nis = _extractNis(code);
        if (nis == null) {
          SnackbarHelper.showError('QR tidak berisi NIS yang valid.');
          // briefly show the scanned code then reset
          scannedData.value = code;
          Future.delayed(const Duration(seconds: 2), () {
            scannedData.value = '';
            _isProcessing = false;
          });
          return;
        }

        _isProcessing = true;
        scannedData.value = nis;
        _submitAttendance(nis);
      }
    }
  }

  void toggleFlash() {
    if (scannerController != null) {
      scannerController!.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
    }
  }

  void _showPresenceConfirmation(String studentInfo) {
    SnackbarHelper.showSuccess(
      "Presensi masuk untuk: $studentInfo berhasil disimpan.",
    );
  }

  /// Try to extract NIS from QR content. Supports:
  /// - JSON like {"nis": "12345"}
  /// - plain 'NIS:12345' or 'nis=12345'
  /// - plain digits (takes first sequence of digits of length >= 4)
  String? _extractNis(String raw) {
    final trimmed = raw.trim();
    // Try parse JSON
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map && decoded['nis'] != null) {
        return decoded['nis'].toString();
      }
    } catch (_) {}

    // Pattern like 'NIS:12345' or 'nis=12345'
    final nisMatch = RegExp(
      r'nis[:=\s]*([0-9]+)',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (nisMatch != null) return nisMatch.group(1);

    // Fallback: prefer a 6-digit NIS (exactly 6 digits), else accept 4-8 digits as secondary fallback
    final nisExact = RegExp(r'\b(\d{6})\b').firstMatch(trimmed);
    if (nisExact != null) return nisExact.group(1);

    // Secondary fallback: common school IDs that might be shorter/longer
    final digits = RegExp(r'\d{4,8}').firstMatch(trimmed);
    if (digits != null) return digits.group(0);

    return null;
  }

  bool _needsCheckoutConfirmation(Map<String, dynamic>? res) {
    if (res == null) return false;
    final status = (res['status'] ?? '').toString().toLowerCase();
    if (status == 'already' ||
        status == 'exists' ||
        status == 'already_checked_in') {
      return true;
    }
    if (res['requires_confirmation'] == true ||
        res['confirm_checkout'] == true) {
      return true;
    }
    final msg = (res['message'] ?? '').toString().toLowerCase();
    if (msg.contains('sudah hadir') ||
        msg.contains('sudah absen') ||
        msg.contains('already checked')) {
      return true;
    }
    return false;
  }

  /// Shows a confirmation dialog before performing check-in. Overridable for tests.
  @protected
  Future<bool?> showCheckInConfirmation(String title, String content) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  /// Haptic feedback hook — can be overridden in tests.
  @protected
  Future<void> vibrate() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> _submitAttendance(String nis) async {
    try {
      // Lookup student info before submitting so we can show confirmation
      Map<String, dynamic>? student;
      try {
        student = await _attendanceService.findStudentByNis(nis);
      } catch (_) {
        student = null;
      }

      final studentName = student?['name']?.toString() ?? nis;

      final confirmed = await showCheckInConfirmation(
        'Konfirmasi Hadir',
        'Apakah Anda yakin akan mencatat hadir untuk $studentName (NIS: $nis)?',
      );

      if (confirmed != true) {
        SnackbarHelper.showInfo('Presensi dibatalkan.');
        return;
      }

      final res = await _attendanceService.scanAttendance(nis);
      developer.log('Scan response: $res', name: 'ScanPresence');

      // If server indicates a checkout confirmation is required, prompt user
      if (_needsCheckoutConfirmation(res)) {
        final studentName = res['student']?['name'] ?? nis;
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Konfirmasi Pulang'),
            content: Text(
              'Siswa $studentName telah melakukan presensi masuk. Konfirmasi untuk mencatat pulang?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Konfirmasi Pulang'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            // Send confirm flag to the scan endpoint
            final checkoutRes = await _attendanceService.scanAttendance(
              nis,
              confirmCheckout: true,
            );
            final name = checkoutRes['student']?['name'] ?? nis;
            SnackbarHelper.showSuccess(
              'Presensi pulang untuk $name berhasil disimpan.',
            );
            try {
              vibrate();
            } catch (_) {}
          } catch (e) {
            SnackbarHelper.showError('Gagal mencatat pulang: $e');
          }
        } else {
          // User cancelled - do nothing
        }
      } else {
        // Normal check-in result: try to extract check_in time from various response shapes
        String? checkIn;
        try {
          checkIn =
              res['check_in']?.toString() ??
              (res['data'] is Map
                  ? res['data']['check_in']?.toString()
                  : null) ??
              (res['attendance'] is Map
                  ? res['attendance']['check_in']?.toString()
                  : null);
        } catch (_) {
          checkIn = null;
        }

        final name = res['student']?['name'] ?? nis;
        if (checkIn != null && checkIn.isNotEmpty) {
          SnackbarHelper.showSuccess(
            'Presensi masuk untuk $name berhasil disimpan pada $checkIn.',
          );
          // Haptic feedback for success
          try {
            vibrate();
          } catch (_) {}
        } else {
          _showPresenceConfirmation(name);
        }
      }
    } catch (e, st) {
      if (e is ApiException) {
        final msg = e.message;
        SnackbarHelper.showError(msg);
        developer.log(
          'Scan ApiException: ${e.body}',
          name: 'ScanPresence',
          error: e,
          stackTrace: st,
        );
      } else {
        SnackbarHelper.showError('Tidak dapat merekam presensi: $e');
        developer.log(
          'Scan unexpected error',
          name: 'ScanPresence',
          error: e,
          stackTrace: st,
        );
      }
    } finally {
      // Clear scanned data and allow scanning again
      Future.delayed(const Duration(seconds: 1), () {
        scannedData.value = '';
        _isProcessing = false;
      });
    }
  }
}
