import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'admin_attendance_management_controller.dart';

class AdminAttendanceManagementView
    extends GetView<AdminAttendanceManagementController> {
  const AdminAttendanceManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildSummaryCards(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredAttendances.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data presensi',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchAttendances,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.alternate),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        // Check if we're in aggregate view (week/month)
                        final isAggregateView =
                            controller.selectedPeriod.value ==
                                PeriodFilter.week ||
                            controller.selectedPeriod.value ==
                                PeriodFilter.month;

                        if (isAggregateView) {
                          return _buildAggregateTable();
                        } else {
                          return _buildDailyTable();
                        }
                      }),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(bottom: BorderSide(color: AppColors.alternate)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Manajemen Presensi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: controller.exportAttendance,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: controller.fetchAttendances,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Period Filter
              Obx(
                () => SegmentedButton<PeriodFilter>(
                  segments: const [
                    ButtonSegment(
                      value: PeriodFilter.day,
                      label: Text('Hari'),
                      icon: Icon(Icons.today, size: 16),
                    ),
                    ButtonSegment(
                      value: PeriodFilter.week,
                      label: Text('Minggu'),
                      icon: Icon(Icons.date_range, size: 16),
                    ),
                    ButtonSegment(
                      value: PeriodFilter.month,
                      label: Text('Bulan'),
                      icon: Icon(Icons.calendar_month, size: 16),
                    ),
                  ],
                  selected: {controller.selectedPeriod.value},
                  onSelectionChanged: (Set<PeriodFilter> selection) {
                    controller.changePeriod(selection.first);
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Date Picker
              OutlinedButton.icon(
                onPressed: () => controller.selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: Obx(() => Text(controller.periodLabel)),
              ),
              const SizedBox(width: 16),
              // Class Filter
              Obx(
                () => DropdownButton<int?>(
                  value: controller.selectedClassFilter.value,
                  hint: const Text('Semua Kelas'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua Kelas'),
                    ),
                    ...controller.classes.map(
                      (c) => DropdownMenuItem(
                        value: c['id'],
                        child: Text(c['name'] ?? ''),
                      ),
                    ),
                  ],
                  onChanged: controller.filterByClass,
                ),
              ),
              const SizedBox(width: 16),
              // Search
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari siswa (nama, NISN)...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.primaryBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final summary = controller.attendanceSummary;
      return Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Hadir',
                '${summary['hadir'] ?? 0}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Sakit',
                '${summary['sakit'] ?? 0}',
                Icons.local_hospital,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Izin',
                '${summary['izin'] ?? 0}',
                Icons.info,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Alpa',
                '${summary['alpa'] ?? 0}',
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.alternate),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String label;

    switch (status?.toLowerCase()) {
      case 'hadir':
        color = Colors.green;
        label = 'Hadir';
        break;
      case 'sakit':
        color = Colors.orange;
        label = 'Sakit';
        break;
      case 'izin':
        color = Colors.blue;
        label = 'Izin';
        break;
      case 'alpa':
        color = Colors.red;
        label = 'Alpa';
        break;
      default:
        color = Colors.grey;
        label = 'Belum Presensi';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // Daily table (for day period)
  Widget _buildDailyTable() {
    return DataTable(
      horizontalMargin: 24,
      columnSpacing: 24,
      headingRowColor: WidgetStateProperty.all(AppColors.primary.withAlpha(25)),
      headingRowHeight: 56,
      dataRowMaxHeight: 64,
      columns: [
        DataColumn(
          label: Text(
            'NISN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Nama Siswa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Kelas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Keterangan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ],
      rows: controller.filteredAttendances.map((attendance) {
        return DataRow(
          cells: [
            DataCell(Text(attendance['nisn'] ?? '-')),
            DataCell(
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  attendance['student_name'] ?? '-',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(Text(attendance['class_name'] ?? '-')),
            DataCell(
              InkWell(
                onTap: () => controller.editAttendance(attendance),
                child: _buildStatusBadge(attendance['status']),
              ),
            ),
            DataCell(
              Container(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(
                  attendance['notes'] ?? '-',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Aggregate table (for week/month period)
  Widget _buildAggregateTable() {
    final showClassColumn = controller.selectedClassFilter.value == null;

    return DataTable(
      horizontalMargin: 24,
      columnSpacing: 24,
      headingRowColor: WidgetStateProperty.all(AppColors.primary.withAlpha(25)),
      headingRowHeight: 56,
      dataRowMaxHeight: 64,
      columns: [
        DataColumn(
          label: Text(
            'NISN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Nama Siswa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        if (showClassColumn)
          DataColumn(
            label: Text(
              'Kelas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
        DataColumn(
          label: Text(
            'Hadir',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Sakit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Izin',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Alpa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ],
      rows: controller.filteredAttendances.map((attendance) {
        return DataRow(
          cells: [
            DataCell(Text(attendance['nisn'] ?? '-')),
            DataCell(
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  attendance['student_name'] ?? '-',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (showClassColumn)
              DataCell(Text(attendance['class_name'] ?? '-')),
            DataCell(
              Text(
                '${attendance['jumlah_hadir'] ?? 0}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Text(
                '${attendance['jumlah_sakit'] ?? 0}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Text(
                '${attendance['jumlah_izin'] ?? 0}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Text(
                '${attendance['jumlah_alpa'] ?? 0}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
