import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';

import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const stats = [
      _Stat(
        title: 'Total Siswa',
        value: '1.240',
        trend: '+24 bulan ini',
        icon: Icons.school,
        badgeColor: AppColors.accent1,
      ),
      _Stat(
        title: 'Guru Aktif',
        value: '84',
        trend: '+3 bulan ini',
        icon: Icons.people_alt,
        badgeColor: AppColors.accent2,
      ),
      _Stat(
        title: 'Orang Tua',
        value: '1.180',
        trend: 'Stabil',
        icon: Icons.family_restroom,
        badgeColor: AppColors.accent3,
      ),
      _Stat(
        title: 'Tugas Tertangani',
        value: '92%',
        trend: 'SLA terpenuhi',
        icon: Icons.task_alt,
        badgeColor: AppColors.accent1,
      ),
    ];

    final activities = [
      'Pengumuman baru dikirim ke kelas 7B',
      'Absensi hari ini 97% tercatat',
      '3 akun orang tua menunggu verifikasi',
      'Kalender ujian tengah semester diperbarui',
    ];

    const quickActions = [
      _QuickAction(label: 'Tambah Pengumuman', icon: Icons.campaign),
      _QuickAction(label: 'Kelola Pengguna', icon: Icons.group_add),
      _QuickAction(label: 'Buat Jadwal', icon: Icons.calendar_today),
      _QuickAction(label: 'Lihat Absensi', icon: Icons.fact_check),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Dasbor Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifikasi',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridCount = constraints.maxWidth >= 1100
                ? 4
                : constraints.maxWidth >= 820
                ? 3
                : 2;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang kembali, Admin',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau aktivitas sekolah, kelola pengguna, dan buat pengumuman dari satu tempat.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Actions
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: quickActions
                        .map(
                          (action) => ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(action.icon, size: 18),
                            label: Text(action.label),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Stats Cards
                  GridView.count(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.4,
                    children: stats
                        .map(
                          (item) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: item.badgeColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.title,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.value,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent4,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.alternate,
                                      ),
                                    ),
                                    child: Text(
                                      item.trend,
                                      style: textTheme.labelMedium?.copyWith(
                                        color: AppColors.secondaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Activities and announcements
                  if (constraints.maxWidth >= 900)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _ActivityCard(
                            activities: activities,
                            textTheme: textTheme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _AgendaCard(textTheme: textTheme),
                        ),
                      ],
                    )
                  else ...[
                    _ActivityCard(activities: activities, textTheme: textTheme),
                    const SizedBox(height: 16),
                    _AgendaCard(textTheme: textTheme),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.badgeColor,
  });

  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color badgeColor;
}

class _QuickAction {
  const _QuickAction({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activities, required this.textTheme});

  final List<String> activities;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas Terbaru',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: AppColors.secondaryText),
                  onPressed: () {},
                  tooltip: 'Muat ulang',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...activities.map(
              (activity) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primaryText,
                    size: 22,
                  ),
                ),
                title: Text(
                  activity,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                subtitle: Text(
                  'Baru saja',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agenda Pekan Ini',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _AgendaItem(
              title: 'Rapat Koordinasi Guru',
              date: 'Senin, 10:00',
              color: AppColors.accent2,
              textTheme: textTheme,
            ),
            _AgendaItem(
              title: 'Review Absensi Mingguan',
              date: 'Rabu, 09:00',
              color: AppColors.accent1,
              textTheme: textTheme,
            ),
            _AgendaItem(
              title: 'Pengiriman Pengumuman UTS',
              date: 'Jumat, 13:00',
              color: AppColors.accent3,
              textTheme: textTheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  const _AgendaItem({
    required this.title,
    required this.date,
    required this.color,
    required this.textTheme,
  });

  final String title;
  final String date;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.alternate),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: AppColors.primaryText),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
