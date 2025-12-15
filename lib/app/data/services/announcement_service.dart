// lib/app/data/services/announcement_service.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import '../models/announcement_model.dart';

class AnnouncementService extends GetxService {
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  // Ambil semua pengumuman
  Future<List<Announcement>> getAllAnnouncements({int limit = 50}) async {
    final res = await _api.get('/announcements?limit=$limit');
    final list = res['announcements'] as List<dynamic>? ?? [];
    return list.map((item) => _mapToAnnouncement(item)).toList();
  }

  // Ambil pengumuman terbaru
  Future<List<Announcement>> getRecentAnnouncements({int count = 3}) async {
    return getAllAnnouncements(limit: count);
  }

  // Detail pengumuman
  Future<Announcement?> getAnnouncementById(String id) async {
    final res = await _api.get('/announcements/$id');
    if (res['announcement'] == null) return null;
    return _mapToAnnouncement(res['announcement']);
  }

  // Buat pengumuman baru
  Future<void> addAnnouncement({
    required String title,
    required String content,
    String targetAudience = 'all',
    int? targetClassId,
    File? attachment,
  }) async {
    if (attachment != null) {
      await _api.postMultipart(
        '/announcements',
        {
          'title': title,
          'content': content,
          'target_audience': targetAudience,
          if (targetClassId != null) 'target_class_id': '$targetClassId',
        },
        'attachment',
        attachment.path,
      );
    } else {
      await _api.post('/announcements', {
        'title': title,
        'content': content,
        'target_audience': targetAudience,
        'target_class_id': targetClassId,
      }, needsAuth: true);
    }
  }

  // Hapus pengumuman
  Future<void> deleteAnnouncement(String id) async {
    await _api.delete('/announcements/$id');
  }

  // Update pengumuman
  Future<void> updateAnnouncement(
    String id, {
    required String title,
    required String content,
  }) async {
    await _api.put('/announcements/$id', {'title': title, 'content': content});
  }

  // Toggle pin
  Future<void> togglePin(String id) async {
    await _api.post('/announcements/$id/toggle-pin', {});
  }

  Announcement _mapToAnnouncement(Map<String, dynamic> item) {
    return Announcement(
      id: item['id'].toString(),
      title: item['title'] ?? '',
      content: item['content'] ?? '',
      timestamp: item['created_at'] != null
          ? DateTime.parse(item['created_at'])
          : DateTime.now(),
      author: item['author_name'] ?? 'Sekolah',
      attachmentName: _extractAttachmentName(item['attachments']),
      isRead: item['is_read'] == true || item['is_read'] == 1 ? true : false,
      isPinned: item['is_pinned'] == true || item['is_pinned'] == 1
          ? true
          : false,
      category: item['category'],
      imageUrl: item['image_url'],
    );
  }

  String? _extractAttachmentName(dynamic attachments) {
    if (attachments is List && attachments.isNotEmpty) {
      final first = attachments.first;
      if (first is Map && first['filename'] != null) {
        return first['filename'] as String;
      }
    }
    return null;
  }
}
