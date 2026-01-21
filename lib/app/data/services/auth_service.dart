import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'local_storage_service.dart';
import 'api_client.dart';

class AuthService extends GetxService {
  late final ApiClient _api;
  late final LocalStorageService _storage;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    _storage = Get.find<LocalStorageService>();
  }

  Future<Map<String, dynamic>?> login({
    required String identifier, // NIK or NISN
    required String password,
  }) async {
    developer.log(
      '[AUTH] Attempting login with identifier: $identifier',
      name: 'AuthService',
    );

    try {
      final res = await _api.post('/auth/login', {
        'identifier': identifier,
        'password': password,
      });

      developer.log('[AUTH] Login response: $res', name: 'AuthService');

      if (res['token'] != null) {
        await _storage.save('auth_token', res['token']);
        final role = (res['profile']?['role'] ?? '') as String;
        await _storage.save('role', role);
        await _storage.save('profile', res['profile']);
        developer.log(
          '[AUTH] Login successful, role: $role',
          name: 'AuthService',
        );
        return res;
      }
      developer.log('[AUTH] No token in response', name: 'AuthService');
      return null;
    } catch (e, st) {
      developer.log(
        '[AUTH] Login error: $e',
        name: 'AuthService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> requestPasswordReset({
    required String identifier,
    required String name,
  }) async {
    await _api.post('/auth/forgot-password', {
      'identifier': identifier,
      'name': name,
    }, needsAuth: false);
  }
}
