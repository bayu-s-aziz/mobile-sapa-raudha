// [KODE LENGKAP]

import 'package:get/get.dart';
// Import model baru
import 'package:sapa_raudha/app/data/models/attendance_model.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
// Import package kalender
import 'package:table_calendar/table_calendar.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';

class AttendanceHistoryController extends GetxController {
  // --- STATE UNTUK KALENDER ---
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = Rx<DateTime?>(DateTime.now());
  final Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;

  // Data dummy untuk absensi
  // Kunci: Hari (tanpa jam, dalam UTC), Nilai: List Model Absensi
  final RxMap<DateTime, List<AttendanceModel>> absenceEvents =
      RxMap<DateTime, List<AttendanceModel>>({});

  final RxBool isLoading = true.obs;
  // ----------------------------

  late final AttendanceService _attendanceService;
  late final LocalStorageService _storage;

  String? _studentNisn; // untuk role orangtua

  @override
  void onInit() {
    super.onInit();
    _attendanceService = Get.find<AttendanceService>();
    _storage = Get.find<LocalStorageService>();
    _studentNisn =
        _attendanceService.getStoredChildNisn() ??
        _storage.read<String>('nisn');
    fetchAbsenceData();
  }

  Future<void> fetchAbsenceData() async {
    isLoading.value = true;
    try {
      final nisn = _studentNisn;
      if (nisn == null || nisn.isEmpty) {
        throw Exception(
          'NISN anak tidak tersedia. Pastikan profil anak sudah dimuat.',
        );
      }
      final data = await _attendanceService.getStudentHistory(nisn);
      final map = <DateTime, List<AttendanceModel>>{};
      for (final item in data) {
        final dateStr = item['date'] as String?;
        if (dateStr == null) continue;
        final dt = DateTime.parse(dateStr);
        final dayKey = DateTime.utc(dt.year, dt.month, dt.day);
        map.putIfAbsent(dayKey, () => []);
        map[dayKey]!.add(
          AttendanceModel(
            date: dt,
            status: _humanStatus(item['status']),
            checkIn: item['check_in'],
            checkOut: item['check_out'],
          ),
        );
      }
      absenceEvents.value = map;
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat riwayat kehadiran: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI HELPER UNTUK KALENDER ---

  // Dipanggil oleh TableCalendar untuk mendapatkan event per hari
  List<AttendanceModel> getEventsForDay(DateTime day) {
    // Normalisasi 'day' ke UTC agar cocok dengan kunci di map
    final utcDay = DateTime.utc(day.year, day.month, day.day);
    return absenceEvents[utcDay] ?? [];
  }

  // Dipanggil saat pengguna tap hari di kalender
  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;
      // update(); // Tidak perlu 'update()' jika pakai Rx
    }
  }

  // Dipanggil saat format kalender berubah (minggu/bulan)
  void onFormatChanged(CalendarFormat format) {
    if (calendarFormat.value != format) {
      calendarFormat.value = format;
    }
  }

  // Dipanggil saat halaman/bulan di kalender diganti
  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
  }

  String _humanStatus(dynamic status) {
    switch ((status ?? '').toString().toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'sakit':
        return 'Sakit';
      case 'izin':
        return 'Izin';
      case 'alpa':
        return 'Alpha';
      default:
        return 'Hadir';
    }
  }

  // ---------------------------------
}
