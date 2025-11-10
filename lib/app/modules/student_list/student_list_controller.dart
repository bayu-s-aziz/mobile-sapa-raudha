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
        ),
        Student(
          id: 'S002',
          name: 'Siti Aminah',
          studentClass: 'Kelas A',
          parentName: 'Ibu Keren',
          dailyStatus: StudentDailyStatus.sakit,
        ),
        Student(
          id: 'S003',
          name: 'Ahmad Zaini',
          studentClass: 'Kelas B',
          parentName: 'Bapak Keren',
          dailyStatus: StudentDailyStatus.izin,
        ),
        Student(
          id: 'S004',
          name: 'Dewi Lestari',
          studentClass: 'Kelas B',
          parentName: 'Ibu Keren',
          dailyStatus: StudentDailyStatus.alpa,
        ),
        Student(
          id: 'S005',
          name: 'Eko Prasetyo',
          studentClass: 'Kelas A',
          parentName: 'Bapak Keren',
          dailyStatus: StudentDailyStatus.belumHadir,
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
