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
      // Laravel expects 'email' + 'password' (+ optional device_name)
      final payloadEmail = (email ?? identifier)?.trim();
      if (payloadEmail == null || payloadEmail.isEmpty) {
        throw ArgumentError('email is required');
      }

      final res = await _api.post('/auth/login', {
        'email': payloadEmail,
        'password': password,
        'device_name': 'flutter-app',
      }, needsAuth: false);

      // Laravel response: { "token": "...", "user": { ... } } or
      // Fortify session response: { "two_factor": false } (or true)
      // Handle two_factor flow explicitly so UI can react.
      final token = res['token'] as String?;
      if (res.containsKey('two_factor')) {
        return {'two_factor': res['two_factor']};
      }
      Map<String, dynamic>? user;
      if (res.containsKey('user') && res['user'] != null) {
        user = Map<String, dynamic>.from(res['user'] as Map);
      } else if (res.containsKey('data') && res['data'] is Map) {
        user = Map<String, dynamic>.from(res['data'] as Map);
      }

      if (token != null) {
        await _storage.save('auth_token', token);
      }
      if (user != null) {
        await _storage.save('user', user);
        return user;
      }
      return null;
    } catch (e, st) {
      developer.log(
        '[AUTH] Login error: $e',
        name: 'AuthService',
        error: e,
        stackTrace: st,
      );
      // If API returned structured errors (validation), log them for UI
      if (e is ApiException) {
        developer.log(
          '[AUTH] ApiException body: ${e.body}',
          name: 'AuthService',
        );
      }
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

  /// Get current user profile (Laravel: returns { "user": ... })
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await _api.get('/auth/profile');
      final user = res['user'] ?? res;
      if (user != null) {
        await _storage.save('user', user);
        return Map<String, dynamic>.from(user as Map);
      }
      return null;
    } catch (e, st) {
      developer.log(
        '[AUTH] Get profile error: $e',
        name: 'AuthService',
        error: e,
        stackTrace: st,
      );
      return null;
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
