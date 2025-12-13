// lib/app/data/models/student_model.dart

// Enum untuk status kehadiran harian (bisa disesuaikan)
enum StudentDailyStatus { hadir, sakit, izin, alpa, belumHadir }

class Student {
  final String id;
  final String name;
  final String studentClass;
  final String parentName;
  final String? photoUrl;
  final StudentDailyStatus dailyStatus;
  final String? nisn;
  final String? nis;
  final String? gender;
  final String? birthPlace;
  final DateTime? birthDate; // <--- tambah
  final String? religion;
  final String? address;
  final String? fatherName; // <--- tambah
  final String? motherName; // <--- tambah
  final String? fatherJob; // <--- tambah
  final String? motherJob; // <--- tambah
  final String? guardianName; // <--- tambah
  final String? guardianJob; // <--- tambah
  final String? fatherPhone; // <--- tambah
  final String? motherPhone; // <--- tambah
  final String? guardianPhone; // <--- tambah

  Student({
    required this.id,
    required this.name,
    required this.studentClass,
    required this.parentName,
    this.photoUrl,
    this.dailyStatus = StudentDailyStatus.belumHadir,
    this.nisn,
    this.nis,
    this.gender,
    this.birthPlace,
    this.birthDate, // <--- tambah
    this.religion,
    this.address,
    this.fatherName, // <--- tambah
    this.motherName, // <--- tambah
    this.fatherJob, // <--- tambah
    this.motherJob, // <--- tambah
    this.guardianName, // <--- tambah
    this.guardianJob, // <--- tambah
    this.fatherPhone, // <--- tambah
    this.motherPhone, // <--- tambah
    this.guardianPhone, // <--- tambah
  });
}
