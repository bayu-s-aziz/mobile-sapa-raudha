// lib/app/data/services/teacher_service.dart

import 'dart:io';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'api_client.dart';

class TeacherService extends GetxService {
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  /// Get all teachers
  Future<Map<String, dynamic>> getTeachers({
    int perPage = 15,
    int page = 1,
  }) async {
    final query = {'per_page': perPage.toString(), 'page': page.toString()};

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get('/teachers?$queryString');
    return res;
  }

  /// Get single teacher detail by ID
  Future<Map<String, dynamic>?> getTeacherById(dynamic id) async {
    try {
      final response = await _api.get('/teachers/${id.toString()}');
      return response['data'] ?? response;
    } catch (e, st) {
      developer.log(
        'Error fetching teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Create new teacher
  Future<Map<String, dynamic>> createTeacher({
    required String name,
    required String email,
    required String password,
    String? nip,
    String? phone,
    String? gender,
  }) async {
    try {
      final response = await _api.post('/teachers', {
        'name': name,
        'email': email,
        'password': password,
        if (nip != null) 'nip': nip,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
      });
      return response;
    } catch (e, st) {
      developer.log(
        'Error creating teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Update teacher
  Future<Map<String, dynamic>> updateTeacher(
    int id, {
    String? name,
    String? email,
    String? phone,
    String? gender,
  }) async {
    try {
      final response = await _api.put('/teachers/$id', {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
      });
      return response;
    } catch (e, st) {
      developer.log(
        'Error updating teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Delete teacher
  Future<void> deleteTeacher(int id) async {
    try {
      await _api.delete('/teachers/$id');
    } catch (e, st) {
      developer.log(
        'Error deleting teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Upload teacher photo
  Future<Map<String, dynamic>> uploadPhoto(int id, File photo) async {
    try {
      final response = await _api.postMultipart(
        '/teachers/$id/upload-photo',
        {},
        'photo',
        photo.path,
      );
      return response;
    } catch (e, st) {
      developer.log(
        'Error uploading teacher photo: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
