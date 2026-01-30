import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sapa_raudha/app/data/services/secure_storage_service.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/auth_service.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_state_manager.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';
import 'package:sapa_raudha/app/data/services/class_service.dart';
import 'package:sapa_raudha/app/data/services/teacher_service.dart';
import 'package:sapa_raudha/app/data/services/app_lifecycle_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    const windowSize = Size(400, 800);
    const windowOptions = WindowOptions(
      size: windowSize,
      minimumSize: Size(360, 640),
      maximumSize: Size(450, 900),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Sapa Raudha',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await initializeDateFormatting('id_ID', null);
  await GetStorage.init();

  String? token;
  try {
    final fs = const FlutterSecureStorage();
    token = await fs.read(key: 'auth_token');
  } catch (_) {}

  final storage = GetStorage();
  token ??= storage.read<String>('auth_token');

  final initialRoute = (token != null && token.isNotEmpty)
      ? Routes.home
      : Routes.login;
  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, this.initialRoute = Routes.login});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "SAPA Raudha",
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.secondaryBackground,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .copyWith(
              bodyLarge: GoogleFonts.inter(color: AppColors.primaryText),
              bodyMedium: GoogleFonts.inter(color: AppColors.secondaryText),
              titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryBackground,
          foregroundColor: AppColors.primaryText,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            elevation: 1,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.secondaryBackground,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
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

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.secondaryBackground,
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
          elevation: 5,
        ),

        scaffoldBackgroundColor: AppColors.primaryBackground,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocalStorageService());

    Get.put(
      ApiClient(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://sapa.ra-alislam.sch.id/api',
        ),
      ),
    );
    Get.put(AuthService());
    Get.put(ProfileService());
    Get.put(StudentService());
    Get.put(ClassService());
    Get.put(TeacherService());
    Get.put(AttendanceService());
    Get.put(AttendanceStateManager());
    Get.put(LeaveService());
    Get.put(AnnouncementService());
    Get.put(SecureStorageService());
    Get.put(AppLifecycleService());
  }
}
