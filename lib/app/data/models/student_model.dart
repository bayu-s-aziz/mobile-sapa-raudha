// lib/app/data/models/student_model.dart

// Enum untuk status kehadiran harian (bisa disesuaikan)
enum StudentDailyStatus { hadir, sakit, izin, alpa, belumHadir }

class Student {
  final String id;
  final String name;
  final String studentClass; // Misal: "Kelas A"
  final String parentName;
  final String? photoUrl;
  final StudentDailyStatus dailyStatus; // Status hari ini

  Student({
    required this.id,
    required this.name,
    required this.studentClass,
    required this.parentName,
    this.photoUrl,
    this.dailyStatus = StudentDailyStatus.belumHadir,
  });
}
