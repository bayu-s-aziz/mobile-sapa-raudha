// [MODERNISASI & FIX] lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// [MODERNISASI] Mengaktifkan GoogleFonts untuk tipografi yang lebih baik
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await GetStorage.init();
  Get.put(AnnouncementService());
  Get.put(LocalStorageService()); // register storage service
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Sapa Raudha",
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.login,
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          // [FIX] Menghapus properti 'background' yang deprecated
          // background: AppColors.primaryBackground, // <-- BARIS INI DIHAPUS
          surface: AppColors
              .secondaryBackground, // Ini untuk permukaan komponen seperti Card
        ),

        // [MODERNISASI] Menggunakan GoogleFonts 'Inter' untuk tampilan bersih
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .copyWith(
              bodyLarge: GoogleFonts.inter(color: AppColors.primaryText),
              bodyMedium: GoogleFonts.inter(color: AppColors.secondaryText),
              titleLarge: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ), // Sedikit lebih tebal
            ),

        // [MODERNISASI] AppBar dibuat "ringan" tanpa bayangan dan menyatu dengan background
        appBarTheme: AppBarTheme(
          backgroundColor:
              AppColors.primaryBackground, // Menyatu dengan scaffold
          foregroundColor: AppColors.primaryText, // Teks menjadi gelap
          elevation: 0, // Tanpa bayangan
          centerTitle: true,
          surfaceTintColor: Colors.transparent, // Hapus tint Material 3
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        // [MODERNISASI] Tombol dibuat berbentuk "pill" (rounded penuh)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Radius penuh
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            elevation: 1, // Bayangan halus
          ),
        ),

        // [MODERNISASI] Input field dibuat lebih lembut dengan radius lebih besar
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.secondaryBackground, // Tetap putih
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), // Radius lebih besar
            borderSide: BorderSide.none, // Hilangkan border default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            // Border sangat halus
            borderSide: BorderSide(color: AppColors.alternate, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: GoogleFonts.inter(color: AppColors.secondaryText),
          hintStyle: GoogleFonts.inter(
            color: AppColors.secondaryText.withAlpha((0.6 * 255).round()),
          ),
          prefixIconColor: AppColors.secondaryText,
          suffixIconColor: AppColors.secondaryText,
        ),

        // [MODERNISASI] Card dibuat tanpa bayangan, border halus, dan radius besar
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Radius lebih besar
            side: BorderSide(
              color: AppColors.alternate.withAlpha((0.8 * 255).round()),
              width: 1,
            ),
          ),
          color: AppColors.secondaryBackground,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),

        // [MODERNISASI] BottomNavBar dibuat "floating"
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor:
              AppColors.secondaryBackground, // Latar belakang putih
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.secondaryText.withAlpha(
            (0.7 * 255).round(),
          ),
          selectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 5, // Perlu sedikit bayangan agar "mengambang"
        ),

        // [MODERNISASI] Latar belakang utama diatur di sini
        scaffoldBackgroundColor:
            AppColors.primaryBackground, // Latar belakang hangat
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
