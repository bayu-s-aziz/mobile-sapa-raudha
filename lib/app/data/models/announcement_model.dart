// lib/app/data/models/announcement_model.dart
import 'package:intl/intl.dart'; // <-- TAMBAHKAN IMPOR INI

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String author;
  final String? attachmentName;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.author,
    this.attachmentName,
  });

  // --- TAMBAHKAN GETTER INI ---
  String get formattedDate {
    // Menggunakan package intl untuk memformat tanggal
    // 'id_ID' akan menggunakan format tanggal Indonesia
    return DateFormat('d MMMM yyyy', 'id_ID').format(timestamp);
  }

  // --- AKHIR TAMBAHAN ---
}
