import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

class SnackbarHelper {
  // Success snackbar
  static void showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Error snackbar dengan filter message
  static void showError(String message) {
    // Filter pesan error untuk tidak menampilkan detail API
    String cleanMessage = _cleanErrorMessage(message);

    Get.snackbar(
      'Error',
      cleanMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Warning snackbar
  static void showWarning(String message) {
    Get.snackbar(
      'Perhatian',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.warning, color: Colors.white),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Info snackbar
  static void showInfo(String message) {
    Get.snackbar(
      'Informasi',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info, color: Colors.white),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Custom snackbar dengan title dan message
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: textColor ?? Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: icon != null ? Icon(icon, color: textColor ?? Colors.white) : null,
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Helper function untuk membersihkan error message
  static String _cleanErrorMessage(String message) {
    // Hapus detail API seperti HTTP status codes, endpoints, dll
    message = message.replaceAll(RegExp(r'HTTP \d+:.*'), '');
    message = message.replaceAll(RegExp(r'Exception:.*'), '');
    message = message.replaceAll(RegExp(r'\[.*\]'), '');
    message = message.replaceAll(RegExp(r'Error:'), '');

    // Jika message masih panjang (mengandung stack trace atau detail teknis), gunakan pesan umum
    if (message.length > 100 ||
        message.contains('at ') ||
        message.contains('file:///')) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }

    // Hapus kata-kata teknis yang mungkin membingungkan
    message = message.replaceAll('toString()', '');
    message = message.replaceAll('e.toString()', '');

    // Trim dan return
    return message.trim().isEmpty
        ? 'Terjadi kesalahan. Silakan coba lagi.'
        : message.trim();
  }
}
