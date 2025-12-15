import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/student_service.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

enum PeriodFilter { day, week, month }

class AdminAttendanceManagementController extends GetxController {
  final StudentService _studentService = Get.find<StudentService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<Map<String, dynamic>> attendances = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredAttendances =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> attendanceSummary = <String, dynamic>{}.obs;
  final RxBool isLoading = true.obs;
  final Rxn<int> selectedClassFilter = Rxn<int>();
  final Rx<PeriodFilter> selectedPeriod = PeriodFilter.day.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final TextEditingController searchController = TextEditingController();

  String get formattedDate =>
      DateFormat('dd/MM/yyyy').format(selectedDate.value);

  String get periodLabel {
    switch (selectedPeriod.value) {
      case PeriodFilter.day:
        return 'Hari: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate.value)}';
      case PeriodFilter.week:
        final start = selectedDate.value.subtract(
          Duration(days: selectedDate.value.weekday - 1),
        );
        final end = start.add(const Duration(days: 6));
        return 'Minggu: ${DateFormat('dd MMM', 'id_ID').format(start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(end)}';
      case PeriodFilter.month:
        return 'Bulan: ${DateFormat('MMMM yyyy', 'id_ID').format(selectedDate.value)}';
    }
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_filterAttendances);
    fetchClasses();
    fetchAttendances();
  }

  Future<void> fetchClasses() async {
    try {
      final data = await _studentService.getClasses();
      classes.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kelas: ${e.toString()}');
    }
  }

  Future<void> fetchAttendances() async {
    isLoading(true);
    try {
      final dateRange = _getDateRange();

      // For week and month periods, use aggregate data
      if (selectedPeriod.value == PeriodFilter.week ||
          selectedPeriod.value == PeriodFilter.month) {
        final data = await _attendanceService.getAttendanceAggregate(
          classId: selectedClassFilter.value,
          startDate: dateRange['start'],
          endDate: dateRange['end'],
        );
        attendances.assignAll(data);
        filteredAttendances.assignAll(data);
      } else {
        // For day period, use regular recap
        final data = await _attendanceService.getAttendanceRecap(
          classId: selectedClassFilter.value,
          startDate: dateRange['start'],
          endDate: dateRange['end'],
        );
        attendances.assignAll(data);
        filteredAttendances.assignAll(data);
      }

      final summary = await _attendanceService.getAttendanceSummary(
        classId: selectedClassFilter.value,
        startDate: dateRange['start'],
        endDate: dateRange['end'],
      );

      attendanceSummary.assignAll(summary);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data presensi: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Map<String, String> _getDateRange() {
    final date = selectedDate.value;
    switch (selectedPeriod.value) {
      case PeriodFilter.day:
        final formatted = DateFormat('yyyy-MM-dd').format(date);
        return {'start': formatted, 'end': formatted};
      case PeriodFilter.week:
        final start = date.subtract(Duration(days: date.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return {
          'start': DateFormat('yyyy-MM-dd').format(start),
          'end': DateFormat('yyyy-MM-dd').format(end),
        };
      case PeriodFilter.month:
        final start = DateTime(date.year, date.month, 1);
        final end = DateTime(date.year, date.month + 1, 0);
        return {
          'start': DateFormat('yyyy-MM-dd').format(start),
          'end': DateFormat('yyyy-MM-dd').format(end),
        };
    }
  }

  void _filterAttendances() {
    final query = searchController.text.toLowerCase();

    var filtered = attendances.where((attendance) {
      final matchesSearch =
          query.isEmpty ||
          (attendance['student_name'] ?? '').toLowerCase().contains(query) ||
          (attendance['nisn'] ?? '').toLowerCase().contains(query) ||
          (attendance['class_name'] ?? '').toLowerCase().contains(query);

      return matchesSearch;
    }).toList();

    filteredAttendances.assignAll(filtered);
  }

  void filterByClass(int? classId) {
    selectedClassFilter.value = classId;
    fetchAttendances();
  }

  void changePeriod(PeriodFilter period) {
    selectedPeriod.value = period;
    fetchAttendances();
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked;

    if (selectedPeriod.value == PeriodFilter.month) {
      // For month selection, show custom month picker dialog
      picked = await _showMonthPicker(context);
    } else {
      // For day and week selection, use normal date picker
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('id', 'ID'),
      );
    }

    if (picked != null) {
      selectedDate.value = picked;
      fetchAttendances();
    }
  }

  Future<DateTime?> _showMonthPicker(BuildContext context) async {
    int selectedYear = selectedDate.value.year;
    int selectedMonth = selectedDate.value.month;

    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pilih Bulan'),
              content: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    // Year selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              selectedYear--;
                            });
                          },
                        ),
                        Text(
                          '$selectedYear',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              selectedYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Month grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected =
                              month == selectedMonth &&
                              selectedYear == selectedDate.value.year;
                          final monthNames = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'Mei',
                            'Jun',
                            'Jul',
                            'Agu',
                            'Sep',
                            'Okt',
                            'Nov',
                            'Des',
                          ];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedMonth = month;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                monthNames[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(DateTime(selectedYear, selectedMonth, 1));
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void editAttendance(Map<String, dynamic> attendance) {
    final selectedStatus = Rxn<String>(attendance['status']);
    final notesController = TextEditingController(
      text: attendance['notes'] ?? '',
    );
    final isNewRecord = attendance['id'] == null;

    Get.dialog(
      AlertDialog(
        title: Text(
          isNewRecord
              ? 'Tambah Presensi: ${attendance['student_name']}'
              : 'Edit Presensi: ${attendance['student_name']}',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: selectedStatus.value,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                  DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                  DropdownMenuItem(value: 'izin', child: Text('Izin')),
                  DropdownMenuItem(value: 'alpa', child: Text('Alpa')),
                ],
                onChanged: (value) => selectedStatus.value = value,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus.value == null) {
                Get.snackbar('Error', 'Silakan pilih status presensi');
                return;
              }

              Get.back();
              try {
                if (isNewRecord) {
                  // Create new attendance record
                  final dateRange = _getDateRange();
                  await _attendanceService.createAttendance({
                    'student_id': attendance['student_id'],
                    'date': dateRange['start'],
                    'status': selectedStatus.value,
                    'notes': notesController.text.trim(),
                  });
                  Get.snackbar('Sukses', 'Presensi berhasil ditambahkan');
                } else {
                  // Update existing attendance record
                  await _attendanceService.updateAttendance(attendance['id'], {
                    'status': selectedStatus.value,
                    'notes': notesController.text.trim(),
                  });
                  Get.snackbar('Sukses', 'Presensi berhasil diperbarui');
                }
                fetchAttendances();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal menyimpan presensi: ${e.toString()}',
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void exportAttendance() async {
    try {
      final pdf = pw.Document();

      // Get teachers data from API
      final teachersList = await _apiClient.getList('/api/teachers');
      final principal = teachersList.firstWhereOrNull(
        (t) => t['role']?.toString().toLowerCase() == 'kepsek',
      );

      // Get period info
      String periodText = '';
      String semesterText = '';

      // Determine period text and semester
      if (selectedPeriod.value == PeriodFilter.day) {
        periodText = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(selectedDate.value);
        semesterText = selectedDate.value.month >= 7 ? 'Ganjil' : 'Genap';
      } else if (selectedPeriod.value == PeriodFilter.week) {
        final start = selectedDate.value.subtract(
          Duration(days: selectedDate.value.weekday - 1),
        );
        final end = start.add(const Duration(days: 6));
        periodText =
            '${DateFormat('dd MMM', 'id_ID').format(start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(end)}';
        semesterText = start.month >= 7 ? 'Ganjil' : 'Genap';
      } else {
        periodText = DateFormat(
          'MMMM yyyy',
          'id_ID',
        ).format(selectedDate.value);
        semesterText = selectedDate.value.month >= 7 ? 'Ganjil' : 'Genap';
      }

      // Generate pages for each class (A and B) or filtered class
      if (selectedClassFilter.value == null) {
        // Export all classes (A and B)
        final classesToExport = classes.where((c) {
          final name = c['name']?.toString().toUpperCase() ?? '';
          return name.contains('A') || name.contains('B');
        }).toList();

        for (var classData in classesToExport) {
          final className = classData['name'] ?? '';
          final homeroomTeacherName = classData['homeroom_teacher_name'] ?? '';
          final classId = classData['id'];

          // Fetch attendance data for this class
          final dateRange = _getDateRange();
          List<Map<String, dynamic>> classAttendances;

          if (selectedPeriod.value == PeriodFilter.week ||
              selectedPeriod.value == PeriodFilter.month) {
            classAttendances = await _attendanceService.getAttendanceAggregate(
              classId: classId,
              startDate: dateRange['start'],
              endDate: dateRange['end'],
            );
          } else {
            classAttendances = await _attendanceService.getAttendanceRecap(
              classId: classId,
              startDate: dateRange['start'],
              endDate: dateRange['end'],
            );
          }

          // Add page based on period type
          if (selectedPeriod.value == PeriodFilter.day) {
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (context) => _buildDailyReport(
                  periodText,
                  semesterText,
                  className,
                  classAttendances,
                  principal?['name'] ?? 'Kepala Raudhatul Athfal',
                  principal?['nik'] ?? '',
                  homeroomTeacherName,
                  classData['homeroom_teacher_nik'] ?? '',
                ),
              ),
            );
          } else {
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (context) => _buildPeriodReport(
                  periodText,
                  semesterText,
                  className,
                  classAttendances,
                  principal?['name'] ?? 'Kepala Raudhatul Athfal',
                  principal?['nik'] ?? '',
                  homeroomTeacherName,
                  classData['homeroom_teacher_nik'] ?? '',
                ),
              ),
            );
          }
        }
      } else {
        // Export selected class only
        final selectedClass = classes.firstWhereOrNull(
          (c) => c['id'] == selectedClassFilter.value,
        );
        if (selectedClass != null) {
          final className = selectedClass['name'] ?? '';
          final homeroomTeacherName =
              selectedClass['homeroom_teacher_name'] ?? '';

          if (selectedPeriod.value == PeriodFilter.day) {
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (context) => _buildDailyReport(
                  periodText,
                  semesterText,
                  className,
                  filteredAttendances,
                  principal?['name'] ?? 'Kepala Raudhatul Athfal',
                  principal?['nik'] ?? '',
                  homeroomTeacherName,
                  selectedClass['homeroom_teacher_nik'] ?? '',
                ),
              ),
            );
          } else {
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (context) => _buildPeriodReport(
                  periodText,
                  semesterText,
                  className,
                  filteredAttendances,
                  principal?['name'] ?? 'Kepala Raudhatul Athfal',
                  principal?['nik'] ?? '',
                  homeroomTeacherName,
                  selectedClass['homeroom_teacher_nik'] ?? '',
                ),
              ),
            );
          }
        }
      }

      // Save and download PDF for web
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Generate filename based on period type
      String filename = 'presensi_';
      if (selectedPeriod.value == PeriodFilter.day) {
        filename +=
            'harian_${DateFormat('dd-MM-yyyy').format(selectedDate.value)}';
      } else if (selectedPeriod.value == PeriodFilter.week) {
        final start = selectedDate.value.subtract(
          Duration(days: selectedDate.value.weekday - 1),
        );
        final end = start.add(const Duration(days: 6));
        filename +=
            'mingguan_${DateFormat('dd-MM-yyyy').format(start)}_sampai_${DateFormat('dd-MM-yyyy').format(end)}';
      } else {
        filename +=
            'bulanan_${DateFormat('MMMM-yyyy', 'id_ID').format(selectedDate.value)}';
      }
      filename += '.pdf';

      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      Get.snackbar(
        'Berhasil',
        'PDF presensi berhasil diunduh',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuat PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  pw.Widget _buildDailyReport(
    String periodText,
    String semesterText,
    String className,
    List<Map<String, dynamic>> attendanceData,
    String principalName,
    String principalNip,
    String teacherName,
    String teacherNik,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'REKAP KEHADIRAN SISWA',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'RAUDHATUL ATHFAL AL-ISLAM',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'TAHUN AJARAN ${DateTime.now().year}/${DateTime.now().year + 1}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          ),
        ),

        // Info
        pw.Row(
          children: [
            pw.SizedBox(width: 100, child: pw.Text('Kelompok')),
            pw.Text(': $className'),
          ],
        ),
        pw.Row(
          children: [
            pw.SizedBox(width: 100, child: pw.Text('Tanggal')),
            pw.Text(': $periodText'),
          ],
        ),
        pw.Row(
          children: [
            pw.SizedBox(width: 100, child: pw.Text('Semester')),
            pw.Text(': $semesterText'),
          ],
        ),
        pw.SizedBox(height: 20),

        // Table
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FixedColumnWidth(40),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(3),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableCell('No', isHeader: true),
                _buildTableCell('Nama', isHeader: true),
                _buildTableCell('Status', isHeader: true),
                _buildTableCell('Keterangan', isHeader: true),
              ],
            ),
            // Data rows
            ...attendanceData.asMap().entries.map((entry) {
              final index = entry.key;
              final attendance = entry.value;
              return pw.TableRow(
                children: [
                  _buildTableCell('${index + 1}'),
                  _buildTableCell(attendance['student_name'] ?? '-'),
                  _buildTableCell(_formatStatus(attendance['status'] ?? '-')),
                  _buildTableCell(attendance['notes'] ?? '-'),
                ],
              );
            }).toList(),
          ],
        ),

        pw.Spacer(),

        // Footer
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Tempat dan Tanggal di atas
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Sindangkasih, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
              ),
            ),
            pw.SizedBox(height: 20),
            // Kepala RA dan Wali Kelas sejajar
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('Kepala Raudhatul Athfal,')],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('Wali Kelas,')],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 60),
            // Nama sejajar
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        principalName,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        teacherName,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            // NIP/NIK sejajar
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('NIP/NIK: $principalNip')],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('NIP/NIK: $teacherNik')],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPeriodReport(
    String periodText,
    String semesterText,
    String className,
    List<Map<String, dynamic>> attendanceData,
    String principalName,
    String principalNip,
    String teacherName,
    String teacherNik,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'REKAP KEHADIRAN SISWA',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'RAUDHATUL ATHFAL AL-ISLAM',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'TAHUN AJARAN ${DateTime.now().year}/${DateTime.now().year + 1}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          ),
        ),

        // Info
        pw.Row(
          children: [
            pw.SizedBox(width: 100, child: pw.Text('Kelompok')),
            pw.Text(': $className'),
          ],
        ),
        pw.Row(
          children: [
            pw.SizedBox(
              width: 100,
              child: pw.Text(
                selectedPeriod.value == PeriodFilter.week ? 'Minggu' : 'Bulan',
              ),
            ),
            pw.Text(': $periodText'),
          ],
        ),
        pw.Row(
          children: [
            pw.SizedBox(width: 100, child: pw.Text('Semester')),
            pw.Text(': $semesterText'),
          ],
        ),
        pw.SizedBox(height: 20),

        // Table
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FixedColumnWidth(40),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(2),
            5: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableCell('No', isHeader: true),
                _buildTableCell('Nama', isHeader: true),
                _buildTableCell('Hadir', isHeader: true),
                _buildTableCell('Sakit', isHeader: true),
                _buildTableCell('Izin', isHeader: true),
                _buildTableCell('Alpa', isHeader: true),
              ],
            ),
            // Data rows
            ...attendanceData.asMap().entries.map((entry) {
              final index = entry.key;
              final attendance = entry.value;
              return pw.TableRow(
                children: [
                  _buildTableCell('${index + 1}'),
                  _buildTableCell(attendance['student_name'] ?? '-'),
                  _buildTableCell(
                    '${attendance['jumlah_hadir'] ?? attendance['hadir'] ?? attendance['present_count'] ?? 0}',
                  ),
                  _buildTableCell(
                    '${attendance['jumlah_sakit'] ?? attendance['sakit'] ?? attendance['sick_count'] ?? 0}',
                  ),
                  _buildTableCell(
                    '${attendance['jumlah_izin'] ?? attendance['izin'] ?? attendance['permission_count'] ?? 0}',
                  ),
                  _buildTableCell(
                    '${attendance['jumlah_alpa'] ?? attendance['alpa'] ?? attendance['absent_count'] ?? 0}',
                  ),
                ],
              );
            }).toList(),
          ],
        ),

        pw.Spacer(),

        // Footer
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Tempat dan Tanggal di atas
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Sindangkasih, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
              ),
            ),
            pw.SizedBox(height: 20),
            // Kepala RA dan Wali Kelas sejajar
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('Kepala Raudhatul Athfal,')],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('Wali Kelas,')],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 60),
            // Nama sejajar
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        principalName,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        teacherName,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            // NIP/NIK sejajar
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('NIP/NIK: $principalNip')],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [pw.Text('NIP/NIK: $teacherNik')],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'sakit':
        return 'Sakit';
      case 'izin':
        return 'Izin';
      case 'alpa':
        return 'Alpa';
      default:
        return status;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
