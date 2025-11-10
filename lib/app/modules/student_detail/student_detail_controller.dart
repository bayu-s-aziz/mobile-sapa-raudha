// lib/app/modules/student_detail/student_detail_controller.dart
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';

class StudentDetailController extends GetxController {
  // Gunakan Rx<Student?> agar bisa null-check
  final Rx<Student?> student = Rx<Student?>(null);

  @override
  void onInit() {
    super.onInit();
    // Ambil data Student yang dikirim sebagai argumen
    if (Get.arguments != null && Get.arguments is Student) {
      student.value = Get.arguments as Student;
    } else {
      // Handle jika data tidak ditemukan
      Get.back();
      Get.snackbar(
        'Error',
        'Gagal memuat data siswa. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Placeholder untuk navigasi ke riwayat absensi spesifik siswa
  void goToStudentAttendanceHistory() {
    if (student.value != null) {
      // Saat ini hanya navigasi ke halaman riwayat umum
      // Idealnya, halaman riwayat bisa difilter berdasarkan ID siswa
      Get.toNamed(Routes.attendanceHistory);
      Get.snackbar(
        'Info',
        'Menampilkan riwayat absensi untuk ${student.value!.name} (Fitur filter belum diimplementasikan)',
      );
    }
  }

  // Placeholder untuk aksi lain
  void callParent() {
    if (student.value != null) {
      Get.snackbar(
        'Info',
        'Fitur hubungi wali ${student.value!.parentName} belum tersedia.',
      );
    }
  }
}
