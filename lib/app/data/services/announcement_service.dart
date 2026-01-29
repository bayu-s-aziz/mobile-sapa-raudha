// lib/app/data/services/announcement_service.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/models/announcement_model.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';

class AnnouncementService extends GetxService {
  late final ApiClient _api;
  late final ProfileService _profile;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    _profile = Get.find<ProfileService>();
  }

  /// Get all announcements with optional filtering
  /// Query params: class_id, per_page, page
  Future<Map<String, dynamic>> getAnnouncements({
    int? classId,
    int perPage = 15,
    int page = 1,
  }) async {
    final query = <String, String>{};
    if (classId != null) query['class_id'] = classId.toString();
    query['per_page'] = perPage.toString();
    query['page'] = page.toString();

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/announcements${queryString.isNotEmpty ? '?$queryString' : ''}',
    );
    return res;
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final res = await _api.get('/announcements/statistics');
    return res;
  }

  /// Get announcements by class
  Future<Map<String, dynamic>> getByClass(int classId) async {
    final res = await _api.get('/announcements/class/$classId');
    return res;
  }

  /// Get single announcement detail
  Future<Map<String, dynamic>?> getById(dynamic id) async {
    try {
      final res = await _api.get('/announcements/${id.toString()}');
      return res['data'] ?? res;
    } catch (e) {
      return null;
    }
  }

  /// Create new announcement
  Future<Map<String, dynamic>> create({
    required String title,
    required String content,
    int? classId,
    File? attachment,
    int? authorId,
    String targetAudience = 'all',
  }) async {
    // Default authorId to the authenticated user's `userable_id` when not provided
    final effectiveAuthorId = authorId ?? _profile.getUserableId();

    if (attachment != null) {
      final fields = <String, String>{
        'title': title,
        'content': content,
        'target_audience': targetAudience,
      };
      if (classId != null) fields['class_id'] = classId.toString();
      if (effectiveAuthorId != null) {
        fields['author_id'] = effectiveAuthorId.toString();
      }

      final res = await _api.postMultipart(
        '/announcements',
        fields,
        'attachment',
        attachment.path,
      );
      return res;
    }

    final body = <String, dynamic>{
      'title': title,
      'content': content,
      'target_audience': targetAudience,
      if (classId != null) 'class_id': classId,
      if (effectiveAuthorId != null) 'author_id': effectiveAuthorId,
    };

    final res = await _api.post('/announcements', body, needsAuth: true);
    return res;
  }

  /// Update announcement
  Future<Map<String, dynamic>> update(
    int id, {
    required String title,
    required String content,
    int? classId,
  }) async {
    final res = await _api.put('/announcements/$id', {
      'title': title,
      'content': content,
      if (classId != null) 'class_id': classId,
    });
    return res;
  }

  /// Delete announcement
  Future<void> delete(int id) async {
    await _api.delete('/announcements/$id');
  }

  /// Upload attachment to announcement
  Future<Map<String, dynamic>> uploadAttachment(
    int announcementId,
    File file,
  ) async {
    final res = await _api.postMultipart(
      '/announcements/$announcementId/upload-attachment',
      {},
      'attachment',
      file.path,
    );
    return res;
  }

  /// Delete attachment from announcement
  Future<void> deleteAttachment(int attachmentId) async {
    await _api.delete('/announcements/attachments/$attachmentId');
  }

  // --- Backwards-compatible aliases used by controllers elsewhere ---
  Future<List<Announcement>> getAllAnnouncements({
    int? classId,
    int perPage = 15,
    int page = 1,
    int? limit,
  }) async {
    final effectivePerPage = limit ?? perPage;
    final res = await getAnnouncements(
      classId: classId,
      perPage: effectivePerPage,
      page: page,
    );
    final items = res['data'] ?? res['announcements'] ?? [];
    if (items is List) {
      return items
          .map(
            (e) => Announcement.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    return [];
  }

  Future<Announcement?> getAnnouncementById(dynamic id) async {
    final map = await getById(id);
    if (map == null) return null;
    return Announcement.fromJson(Map<String, dynamic>.from(map));
  }

  Future<Map<String, dynamic>> addAnnouncement({
    required String title,
    required String content,
    int? classId,
    File? attachment,
    int? authorId,
    String targetAudience = 'all',
  }) async {
    return create(
      title: title,
      content: content,
      classId: classId,
      attachment: attachment,
      authorId: authorId,
      targetAudience: targetAudience,
    );
  }
}
