import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'scan_presence_controller.dart';

class ScanPresenceView extends GetView<ScanPresenceController> {
  const ScanPresenceView({super.key});

  @override
  Widget build(BuildContext context) {
    final double scanAreaSize = MediaQuery.of(context).size.width * 0.7;
    const double borderRadius = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Presensi'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isFlashOn.value ? Icons.flash_on : Icons.flash_off,
              ),
              tooltip: 'Toggle Flash',
              onPressed: controller.toggleFlash,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.scannerController,
            onDetect: controller.onBarcodeDetected,
            scanWindow: Rect.fromCenter(
              center: MediaQuery.of(context).size.center(Offset.zero),
              width: scanAreaSize,
              height: scanAreaSize,
            ),
          ),

          QRScannerOverlay(
            overlayColour: Colors.black.withAlpha(128),
            scanAreaSize: scanAreaSize,
            borderRadius: borderRadius,
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spacer untuk mendorong teks ke bawah area scan
                SizedBox(height: scanAreaSize + 40), // scanAreaSize + jarak
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(153), // Background teks
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(
                    () => Text(
                      controller.scannedData.isEmpty
                          ? 'Arahkan kamera ke QR Code Siswa'
                          : 'Memproses: ${controller.scannedData.value}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerOverlay extends StatelessWidget {
  final Color overlayColour;
  final double scanAreaSize;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;

  const QRScannerOverlay({
    super.key,
    required this.overlayColour,
    required this.scanAreaSize,
    this.borderRadius = 12.0,
    this.borderLength = 30.0,
    this.borderWidth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final cutoutPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.largest),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: MediaQuery.of(context).size.center(Offset.zero),
            width: scanAreaSize,
            height: scanAreaSize,
          ),
          Radius.circular(borderRadius),
        ),
      ),
    );

    return Stack(
      children: [
        ClipPath(
          clipper: _QRScannerOverlayClipper(cutoutPath),
          child: Container(color: overlayColour),
        ),
        Center(
          child: CustomPaint(
            size: Size(scanAreaSize, scanAreaSize),
            painter: _QRBorderPainter(
              borderRadius: borderRadius,
              borderLength: borderLength,
              borderWidth: borderWidth,
              borderColor: Colors.white.withAlpha(204),
            ),
          ),
        ),
      ],
    );
  }
}

class _QRScannerOverlayClipper extends CustomClipper<Path> {
  final Path cutoutPath;

  _QRScannerOverlayClipper(this.cutoutPath);

  @override
  Path getClip(Size size) {
    return cutoutPath;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _QRScannerOverlayClipper &&
        oldClipper.cutoutPath != cutoutPath;
  }
}

class _QRBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final Color borderColor;

  _QRBorderPainter({
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Sudut tumpul

    final path = Path();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // Sudut Kiri Atas
    path.moveTo(rrect.left, rrect.top + borderLength);
    path.lineTo(rrect.left, rrect.top + borderRadius);
    path.arcToPoint(
      Offset(rrect.left + borderRadius, rrect.top),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rrect.left + borderLength, rrect.top);

    // Sudut Kanan Atas
    path.moveTo(rrect.right - borderLength, rrect.top);
    path.lineTo(rrect.right - borderRadius, rrect.top);
    path.arcToPoint(
      Offset(rrect.right, rrect.top + borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rrect.right, rrect.top + borderLength);

    // Sudut Kanan Bawah
    path.moveTo(rrect.right, rrect.bottom - borderLength);
    path.lineTo(rrect.right, rrect.bottom - borderRadius);
    path.arcToPoint(
      Offset(rrect.right - borderRadius, rrect.bottom),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rrect.right - borderLength, rrect.bottom);

    // Sudut Kiri Bawah
    path.moveTo(rrect.left + borderLength, rrect.bottom);
    path.lineTo(rrect.left + borderRadius, rrect.bottom);
    path.arcToPoint(
      Offset(rrect.left, rrect.bottom - borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rrect.left, rrect.bottom - borderLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
