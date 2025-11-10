// [KODE LENGKAP]

import 'package:get/get.dart';
// Import model baru
import 'package:sapa_raudha/app/data/models/attendance_model.dart';
// Import package kalender
import 'package:table_calendar/table_calendar.dart';

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

  @override
  void onInit() {
    super.onInit();
    fetchAbsenceData();
  }

  Future<void> fetchAbsenceData() async {
    isLoading.value = true;
    // --- Simulasi Fetch Data (delay 1 detik) ---
    await Future.delayed(const Duration(seconds: 1));

    // Normalisasi tanggal HARI INI ke UTC (tanpa jam)
    final today = DateTime.now();
    final utcToday = DateTime.utc(today.year, today.month, today.day);

    // Ganti ini dengan logika API call Anda
    final dummyData = {
      // 2 hari lalu
      utcToday.subtract(const Duration(days: 2)): [
        AttendanceModel(
          date: utcToday.subtract(const Duration(days: 2)),
          status: 'Sakit',
        ),
      ],
      // 7 hari lalu
      utcToday.subtract(const Duration(days: 7)): [
        AttendanceModel(
          date: utcToday.subtract(const Duration(days: 7)),
          status: 'Izin',
        ),
      ],
      // 10 hari lalu
      utcToday.subtract(const Duration(days: 10)): [
        AttendanceModel(
          date: utcToday.subtract(const Duration(days: 10)),
          status: 'Alpha',
        ),
      ],
      // 11 hari lalu
      utcToday.subtract(const Duration(days: 11)): [
        AttendanceModel(
          date: utcToday.subtract(const Duration(days: 11)),
          status: 'Alpha',
        ),
      ],
    };

    absenceEvents.value = dummyData;
    isLoading.value = false;
    // ----------------------------
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

  // ---------------------------------
}
