import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'scan_presence_controller.dart';
import 'dart:io' show Platform;

class ScanPresenceView extends GetView<ScanPresenceController> {
  const ScanPresenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.alternate.withAlpha(
                        (0.15 * 255).round(),
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.alternate.withAlpha((0.1 * 255).round()),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Column(
                    children: [
                      // Scanner Area
                      Expanded(
                        child: Stack(
                          children: [
                            if (controller.isMobilePlatform && controller.scannerController != null)
                              MobileScanner(
                                controller: controller.scannerController!,
                                onDetect: controller.onBarcodeDetected,
                              )
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        size: 80,
                                        color: AppColors.secondaryText.withAlpha((0.5 * 255).round()),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Fitur Scanner Tidak Tersedia',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryText,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Scanner QR Code hanya tersedia di perangkat mobile (Android/iOS)',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Floating controls overlay
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Back button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () => Get.back(),
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Title
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Scan QR Presensi',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                  // Flash toggle
                                  Obx(
                                    () => Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          controller.isFlashOn.value
                                              ? Icons.flash_on
                                              : Icons.flash_off,
                                        ),
                                        tooltip: 'Toggle Flash',
                                        onPressed: controller.toggleFlash,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status text at bottom
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Obx(
                                  () => Text(
                                    controller.scannedData.isEmpty
                                        ? 'Arahkan kamera ke QR Code Siswa'
                                        : 'Memproses: ${controller.scannedData.value}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
