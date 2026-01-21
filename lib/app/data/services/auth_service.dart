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
    String? identifier,
    String? email,
    required String password,
  }) async {
    developer.log(
      '[AUTH] Attempting login with identifier: ${identifier ?? email}',
      name: 'AuthService',
    );

    try {
      // If backend expects `email` but client uses numeric identifier (NISN/NIK),
      // send identifier as `email` as well so Laravel auth still accepts it.
      final inferredEmail =
          (email == null &&
              identifier != null &&
              RegExp(r'^\d+\$').hasMatch(identifier))
          ? identifier
          : email;

      final payload = {
        if (identifier != null) 'identifier': identifier,
        if (inferredEmail != null) 'email': inferredEmail,
        'password': password,
      };

      final res = await _api.post('/auth/login', payload, needsAuth: false);

      developer.log('[AUTH] Login response: $res', name: 'AuthService');

      if (res['success'] == true && res['token'] != null) {
        await _storage.save('auth_token', res['token']);
        await _storage.save('user', res['user']);

        final userType = (res['user']?['userable_type'] ?? '') as String;
        developer.log(
          '[AUTH] Login successful, user type: $userType',
          name: 'AuthService',
        );
        return res;
      }
      developer.log('[AUTH] Login failed', name: 'AuthService');
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

  /// Request password reset (used by login UI)
  Future<void> requestPasswordReset({
    required String identifier,
    required String name,
  }) async {
    try {
      await _api.post('/auth/request-password-reset', {
        'identifier': identifier,
        'name': name,
      }, needsAuth: false);
      developer.log('[AUTH] Password reset requested', name: 'AuthService');
    } catch (e, st) {
      developer.log(
        '[AUTH] Request password reset error: $e',
        name: 'AuthService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await _api.get('/auth/profile');

      if (res['success'] == true && res['user'] != null) {
        await _storage.save('user', res['user']);
        return res['user'];
      }
      return null;
    } catch (e, st) {
      developer.log(
        '[AUTH] Get profile error: $e',
        name: 'AuthService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Logout dan hapus token
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
      await _storage.remove('auth_token');
      await _storage.remove('user');
      developer.log('[AUTH] Logout successful', name: 'AuthService');
    } catch (e, st) {
      developer.log(
        '[AUTH] Logout error: $e',
        name: 'AuthService',
        error: e,
        stackTrace: st,
      );
      // Clear local storage even if API call fails
      await _storage.remove('auth_token');
      await _storage.remove('user');
      rethrow;
    }
  }
}
