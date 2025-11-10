// [MODERNISASI] lib/app/utils/app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4B986C); // Tetap, hijau yang bagus
  static const Color secondary = Color(0xFF928163);
  static const Color tertiary = Color(0xFF6D604A);
  // [MODERNISASI] Mengganti border/alternate color dari biru dingin ke abu-abu netral
  static const Color alternate = Color(0xFFE0E0E0); // Sebelumnya 0xFFC8D7E4

  // Utility Colors
  static const Color primaryText = Color(0xFF0B191E);
  static const Color secondaryText = Color(0xFF384E58);
  // [MODERNISASI] Mengganti latar belakang utama menjadi lebih hangat (soft white)
  static const Color primaryBackground = Color(
    0xFFF9F9F7,
  ); // Sebelumnya 0xFFF1F4F8
  static const Color secondaryBackground = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color accent1 = Color(
    0x4D4B986C,
  ); // 30% Opacity Primary (0x4D = ~30% alpha)
  static const Color accent2 = Color(
    0x4D928163,
  ); // 30% Opacity Secondary (0x4D = ~30% alpha)
  static const Color accent3 = Color(
    0x4C6D604A,
  ); // 30% Opacity Tertiary (0x4C = ~30% alpha)
  static const Color accent4 = Color(0xCDFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF336A4A);
  static const Color error = Color(0xFFC4454D);
  static const Color warning = Color(0xFFF3C344);
  static const Color info = Color(0xFFFFFFFF);
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};

  final int argb = color.toARGB32();
  final int r = (argb >> 16) & 0xFF;
  final int g = (argb >> 8) & 0xFF;
  final int b = argb & 0xFF;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.toARGB32(), swatch);
}
