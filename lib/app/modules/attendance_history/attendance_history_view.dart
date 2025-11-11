// [KODE LENGKAP]
// File ini diganti total untuk menampilkan kalender

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/data/models/attendance_model.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'package:sapa_raudha/app/widgets/floating_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'attendance_history_controller.dart';

class AttendanceHistoryView extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingPage(
        title: 'Riwayat Absensi',
        onBack: () => Get.back(),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            // --- WIDGET KALENDER UTAMA ---
            Card(
              // Beri sedikit margin agar "mengambang" di atas background
              margin: const EdgeInsets.all(16.0),
              // Gunakan CardTheme modern (border, radius) dari main.dart
              clipBehavior: Clip.antiAlias, // Agar shadow tidak tumpang tindih
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 400, // Tinggi rata-rata kalender
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return TableCalendar<AttendanceModel>(
                  locale: 'id_ID', // Bahasa Indonesia
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: controller.focusedDay.value,
                  calendarFormat: controller.calendarFormat.value,
                  selectedDayPredicate: (day) =>
                      isSameDay(controller.selectedDay.value, day),

                  // --- Logika Event (Absensi) ---
                  eventLoader: controller.getEventsForDay,

                  // --- Handler Interaksi ---
                  onDaySelected: controller.onDaySelected,
                  onFormatChanged: controller.onFormatChanged,
                  onPageChanged: controller.onPageChanged,

                  // --- STYLING MODERN ---
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    // Sembunyikan tombol (Month/2 Weeks/Week)
                    formatButtonVisible: false,
                    titleTextStyle: Theme.of(context).textTheme.titleMedium!
                        .copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.secondaryText,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    // Marker untuk hari ini
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(0x4D),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: AppColors.primaryText.withAlpha(0xCC),
                    ),
                    // Marker untuk hari yang dipilih
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    // Sembunyikan marker untuk hari di luar bulan
                    outsideDaysVisible: false,
                  ),
                  calendarBuilders: CalendarBuilders(
                    // Custom builder untuk marker event
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;

                      // Ambil status absensi
                      String status = events.first.status.toLowerCase();
                      Color markerColor;

                      if (status == 'sakit') {
                        markerColor = AppColors.warning; // Kuning
                      } else if (status == 'izin') {
                        markerColor = Colors.blue.shade600; // Biru
                      } else {
                        markerColor = AppColors.error; // Merah (Alpha)
                      }

                      // Tanda titik di bawah tanggal
                      return Positioned(
                        bottom: 5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: markerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            // ---------------------------
            const SizedBox(height: 16),
            _buildLegend(context),
            const Divider(height: 32, indent: 16, endIndent: 16),

            // --- DAFTAR DETAIL HARI YANG DIPILIH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox.shrink(); // Jangan tampilkan apa-apa saat loading
                }

                final selectedEvents = controller.getEventsForDay(
                  controller.selectedDay.value ?? DateTime.now(),
                );

                if (selectedEvents.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'Tidak ada catatan ketidakhadiran\npada tanggal ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  );
                }

                return _buildEventDetails(context, selectedEvents.first);
              }),
            ),
            const SizedBox(
              height: 40,
            ), // Padding bawah agar tidak tertutup nav bar
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK LEGENDA ---
  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(context, AppColors.error, 'Alpha'),
          _legendItem(context, AppColors.warning, 'Sakit'),
          _legendItem(context, Colors.blue.shade600, 'Izin'),
        ],
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
  // -------------------------------------

  // --- WIDGET HELPER UNTUK DETAIL EVENT ---
  Widget _buildEventDetails(BuildContext context, AttendanceModel event) {
    // Format tanggal
    final String date = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(event.date);
    String status = event.status;
    Color statusColor;
    IconData statusIcon;

    if (status.toLowerCase() == 'sakit') {
      statusColor = AppColors.warning;
      statusIcon = Icons.sick_outlined;
    } else if (status.toLowerCase() == 'izin') {
      statusColor = Colors.blue.shade600;
      statusIcon = Icons.mail_outline;
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.block_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Gunakan Card agar styling konsisten
        Card(
          elevation: 0,
          color: statusColor.withAlpha(0x14), // Warna background halus
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // Border sesuai warna status
            side: BorderSide(color: statusColor.withAlpha(0x4D)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Status: $status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor.withAlpha(0xE6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------
}
