// lib/app/data/services/announcement_service.dart
import 'package:get/get.dart';
import '../models/announcement_model.dart';

class AnnouncementService extends GetxService {
  final RxList<Announcement> _dummyAnnouncements = <Announcement>[
    Announcement(
      id: 'A001',
      title: 'Rapat Wali Murid Kelas 1',
      content:
          'Diberitahukan kepada seluruh wali murid kelas 1 bahwa akan diadakan rapat pada hari Sabtu, 2 November 2025 pukul 09:00 WIB di Aula Sekolah. Kehadiran sangat diharapkan.\n\nTerima kasih.',
      timestamp: DateTime(2025, 10, 28, 10, 0),
      author: 'Ibu Guru Hebat',
      attachmentName: 'Surat_Undangan_Rapat.pdf', // <-- CONTOH LAMPIRAN
    ),
    Announcement(
      id: 'A002',
      title: 'Informasi Kegiatan Outing Class',
      content:
          'Anak-anak kelas 2 akan mengikuti kegiatan outing class ke Taman Mini Indonesia Indah pada hari Rabu, 6 November 2025. Mohon mempersiapkan bekal dan pakaian ganti. Biaya partisipasi sebesar Rp 50.000,- dapat dititipkan melalui wali kelas.',
      timestamp: DateTime(2025, 10, 29, 14, 30),
      author: 'Admin Sekolah',
      attachmentName: null, // <-- Tidak ada lampiran
    ),
    Announcement(
      id: 'A003',
      title: 'Libur Maulid Nabi Muhammad SAW',
      content:
          'Dalam rangka memperingati Maulid Nabi Muhammad SAW, kegiatan belajar mengajar akan diliburkan pada hari Senin, 4 November 2025. Kegiatan belajar akan dimulai kembali pada hari Selasa, 5 November 2025.',
      timestamp: DateTime(2025, 10, 29, 8, 15),
      author: 'Admin Sekolah',
      attachmentName: null,
    ),
    Announcement(
      id: 'A004',
      title: 'Pengambilan Rapor Semester Ganjil',
      content:
          'Pengambilan rapor semester ganjil akan dilaksanakan pada hari Jumat, 20 Desember 2025. Jadwal pengambilan per kelas akan diinformasikan lebih lanjut oleh wali kelas masing-masing.',
      timestamp: DateTime(2025, 12, 15, 11, 00),
      author: 'Admin Sekolah',
      attachmentName: 'Jadwal_Pengambilan_Rapor.png', // <-- CONTOH LAMPIRAN
    ),
  ].obs;

  List<Announcement> getAllAnnouncements() {
    final sortedList = List<Announcement>.from(_dummyAnnouncements);
    sortedList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedList;
  }

  Announcement? getAnnouncementById(String id) {
    try {
      return _dummyAnnouncements.firstWhere((ann) => ann.id == id);
    } catch (e) {
      return null;
    }
  }

  // Perbarui signature method ini
  void addAnnouncement(
    String title,
    String content,
    String author, {
    String? attachmentName,
  }) {
    final newId =
        'A${(_dummyAnnouncements.length + 1).toString().padLeft(3, '0')}';
    final newAnnouncement = Announcement(
      id: newId,
      title: title,
      content: content,
      timestamp: DateTime.now(),
      author: author,
      attachmentName: attachmentName, // <-- SIMPAN NAMA LAMPIRAN
    );
    _dummyAnnouncements.add(newAnnouncement);
  }

  List<Announcement> getRecentAnnouncements({int count = 3}) {
    return getAllAnnouncements().take(count).toList();
  }
}
