// lib/app/modules/profile/profile_controller.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';
import 'package:sapa_raudha/app/modules/home/home_controller.dart'; // Untuk ambil data user

class ProfileController extends GetxController {
  // Mengambil HomeController untuk mendapatkan data user yang sedang login
  final HomeController homeController = Get.find<HomeController>();

  late RxString userName;
  late RxString userRole;
  late RxString userEmail; // Tambahan dummy
  late RxString userPhotoUrl; // Tambahan dummy

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi data dari HomeController
    userName = homeController.userName;
    userRole = homeController.userRole;

    // Data dummy tambahan
    userEmail =
        (userRole.value == 'guru'
                ? 'guru.hebat@sekolah.id'
                : 'ortu.keren@email.com')
            .obs;
    userPhotoUrl = ''.obs; // Awalnya kosong, bisa diisi URL
  }

  void goToEditProfile() {
    // Navigasi ke halaman edit profil (yang akan kita buat selanjutnya)
    Get.toNamed(Routes.editProfile);
  }

  void logout() {
    // Memanggil fungsi logout yang sudah ada di HomeController
    homeController.confirmLogout();
  }
}
