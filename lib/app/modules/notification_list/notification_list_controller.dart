import 'package:get/get.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String category;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      time: time,
      category: category,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationListController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  Future<void> refreshList() async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 400));
    _loadDummyData();
    isLoading(false);
  }

  void markAllRead() {
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  void toggleRead(String id) {
    notifications.assignAll(
      notifications.map((n) => n.id == id ? n.copyWith(isRead: !n.isRead) : n),
    );
  }

  void _loadDummyData() {
    final now = DateTime.now();
    notifications.assignAll([
      NotificationItem(
        id: '1',
        title: 'Pengumuman Baru',
        body: 'Pengumuman ujian tengah semester telah dipublikasikan.',
        time: now.subtract(const Duration(minutes: 12)),
        category: 'Pengumuman',
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Izin Disetujui',
        body: 'Permohonan izin ananda Aisyah pada 12 Jan telah disetujui.',
        time: now.subtract(const Duration(hours: 2)),
        category: 'Izin',
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Presensi Hari Ini',
        body: 'Ananda sudah melakukan presensi pukul 07.05 WIB.',
        time: now.subtract(const Duration(hours: 5)),
        category: 'Presensi',
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Profil Diperbarui',
        body: 'Foto profil berhasil diperbarui.',
        time: now.subtract(const Duration(days: 1, hours: 1)),
        category: 'Profil',
        isRead: true,
      ),
    ]);
  }
}
