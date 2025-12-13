// lib/app/modules/student_list/student_list_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/models/student_model.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';

class StudentListController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Student> allStudents = <Student>[].obs;
  final RxList<Student> filteredStudents = <Student>[].obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
    // Listener untuk search
    searchController.addListener(() {
      filterStudents(searchController.text);
    });
  }

  void fetchStudents() {
    isLoading(true);
    // Simulasi pengambilan data
    Future.delayed(const Duration(milliseconds: 800), () {
      final dummyData = [
        Student(
          id: 'S001',
          name: 'Budi Santoso',
          studentClass: 'Kelas A',
          parentName: 'Bapak Keren',
          dailyStatus: StudentDailyStatus.hadir,
          nisn: '1234567890',
          gender: 'Laki-laki',
          birthPlace: 'Surabaya',
          birthDate: DateTime(2019, 5, 12),
          religion: 'Islam',
          address: 'Jl. Mawar No. 10',
          fatherName: 'Bapak Keren',
          motherName: 'Ibu Hebat',
          fatherJob: 'Pegawai Swasta',
          motherJob: 'Ibu Rumah Tangga',
          guardianName: 'Paman Baik',
          guardianJob: 'Wiraswasta',
        ),
        Student(
          id: 'S002',
          name: 'Siti Aminah',
          studentClass: 'Kelas A',
          parentName: 'Ibu Keren',
          dailyStatus: StudentDailyStatus.sakit,
          nisn: '0987654321',
          gender: 'Perempuan',
          birthPlace: 'Jakarta',
          birthDate: DateTime(2019, 6, 15),
          religion: 'Islam',
          address: 'Jl. Melati No. 20',
          fatherName: 'Bapak Keren',
          motherName: 'Ibu Keren',
          fatherJob: 'Dokter',
          motherJob: 'Pengacara',
          guardianName: 'Nenek Baik',
          guardianJob: 'Pensiuun',
        ),
        Student(
          id: 'S003',
          name: 'Ahmad Zaini',
          studentClass: 'Kelas B',
          parentName: 'Bapak Keren',
          dailyStatus: StudentDailyStatus.izin,
          nisn: '1122334455',
          gender: 'Laki-laki',
          birthPlace: 'Bandung',
          birthDate: DateTime(2019, 7, 20),
          religion: 'Kristen',
          address: 'Jl. Kenanga No. 30',
          fatherName: 'Bapak Keren',
          motherName: 'Ibu Keren',
          fatherJob: 'Insinyur',
          motherJob: 'Dokter',
          guardianName: 'Paman Baik',
          guardianJob: 'Wiraswasta',
        ),
        Student(
          id: 'S004',
          name: 'Dewi Lestari',
          studentClass: 'Kelas B',
          parentName: 'Ibu Keren',
          dailyStatus: StudentDailyStatus.alpa,
          nisn: '2233445566',
          gender: 'Perempuan',
          birthPlace: 'Semarang',
          birthDate: DateTime(2019, 8, 25),
          religion: 'Buddha',
          address: 'Jl. Cempaka No. 40',
          fatherName: 'Bapak Keren',
          motherName: 'Ibu Keren',
          fatherJob: 'Pengusaha',
          motherJob: 'Ibu Rumah Tangga',
          guardianName: 'Nenek Baik',
          guardianJob: 'Pensiuun',
        ),
        Student(
          id: 'S005',
          name: 'Eko Prasetyo',
          studentClass: 'Kelas A',
          parentName: 'Bapak Keren',
          dailyStatus: StudentDailyStatus.belumHadir,
          nisn: '3344556677',
          gender: 'Laki-laki',
          birthPlace: 'Medan',
          birthDate: DateTime(2019, 9, 30),
          religion: 'Hindu',
          address: 'Jl. Anggrek No. 50',
          fatherName: 'Bapak Keren',
          motherName: 'Ibu Keren',
          fatherJob: 'Arsitek',
          motherJob: 'Dokter',
          guardianName: 'Paman Baik',
          guardianJob: 'Wiraswasta',
        ),
      ];

      allStudents.assignAll(dummyData);
      filteredStudents.assignAll(dummyData); // Awalnya tampilkan semua
      isLoading(false);
    });
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(allStudents);
    } else {
      filteredStudents.assignAll(
        allStudents
            .where(
              (student) =>
                  student.name.toLowerCase().contains(query.toLowerCase()) ||
                  student.studentClass.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList(),
      );
    }
  }

  void goToStudentDetail(Student student) {
    Get.toNamed(Routes.studentDetail, arguments: student);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
