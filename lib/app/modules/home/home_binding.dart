// File: lib/app/modules/home/home_binding.dart
import 'package:get/get.dart';
import 'home_controller.dart'; // Impor HomeController

/// Binds HomeController to the HomeView.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan HomeController menggunakan lazyPut
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
