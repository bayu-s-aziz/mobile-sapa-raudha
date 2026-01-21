// lib/app/data/services/parent_service.dart

import 'dart:io';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'api_client.dart';

class ParentService extends GetxService {
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  /// Get all parents with optional pagination
  Future<Map<String, dynamic>> getParents({
    int perPage = 15,
    int page = 1,
  }) async {
    final query = {'per_page': perPage.toString(), 'page': page.toString()};

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get('/parents?$queryString');
    return res;
  }

  /// Get parent detail by ID
  Future<Map<String, dynamic>?> getParentById(int id) async {
    try {
      final response = await _api.get('/parents/$id');
      return response['data'] ?? response;
    } catch (e, st) {
      developer.log(
        'Error fetching parent: $e',
        name: 'ParentService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Create new parent
  Future<Map<String, dynamic>> createParent({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? fatherName,
    String? motherName,
    String? guardianName,
  }) async {
    try {
      final response = await _api.post('/parents', {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (fatherName != null) 'father_name': fatherName,
        if (motherName != null) 'mother_name': motherName,
        if (guardianName != null) 'guardian_name': guardianName,
      });
      return response;
    } catch (e, st) {
      developer.log(
        'Error creating parent: $e',
        name: 'ParentService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Update parent
  Future<Map<String, dynamic>> updateParent(
    int id, {
    String? name,
    String? email,
    String? phone,
    String? fatherName,
    String? motherName,
    String? guardianName,
  }) async {
    try {
      final response = await _api.put('/parents/$id', {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (fatherName != null) 'father_name': fatherName,
        if (motherName != null) 'mother_name': motherName,
        if (guardianName != null) 'guardian_name': guardianName,
      });
      return response;
    } catch (e, st) {
      developer.log(
        'Error updating parent: $e',
        name: 'ParentService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Delete parent
  Future<void> deleteParent(int id) async {
    try {
      await _api.delete('/parents/$id');
    } catch (e, st) {
      developer.log(
        'Error deleting parent: $e',
        name: 'ParentService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Upload parent photo
  Future<Map<String, dynamic>> uploadPhoto(int id, File photo) async {
    try {
      final response = await _api.postMultipart(
        '/parents/$id/upload-photo',
        {},
        'photo',
        photo.path,
      );
      return response;
    } catch (e, st) {
      developer.log(
        'Error uploading parent photo: $e',
        name: 'ParentService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Switch active parent (for multi-parent scenarios)
  Future<Map<String, dynamic>> switchActiveParent(int id) async {
    try {
      final response = await _api.post('/parents/$id/switch-active-parent', {});
      return response;
    } catch (e, st) {
      developer.log(
        'Error switching active parent: $e',
        name: 'ParentService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
