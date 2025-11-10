// lib/app/data/models/attendance_model.dart
enum AttendanceStatus { hadir, sakit, izin, alpa }

class AttendanceRecord {
  final DateTime date;
  final AttendanceStatus status;
  final String? description; // Keterangan tambahan, misal jam masuk/pulang

  AttendanceRecord({
    required this.date,
    required this.status,
    this.description,
  });
}

// [KODE BARU]
// File ini baru dan digunakan oleh AttendanceHistoryController & View

class AttendanceModel {
  final DateTime date;
  final String status; // Misal: 'Sakit', 'Izin', 'Alpha'
  final String? checkIn;
  final String? checkOut;

  AttendanceModel({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
  });
}
