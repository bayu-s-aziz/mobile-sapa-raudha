import 'package:get/get.dart';
import 'api_client.dart';
import 'local_storage_service.dart';

/// Handles fetching and caching the authenticated user's profile.
class ProfileService extends GetxService {
  late final ApiClient _api;
  late final LocalStorageService _storage;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    _storage = Get.find<LocalStorageService>();
  }

  /// Return the cached profile (if any).
  Map<String, dynamic>? getStoredProfile() {
    return _storage.read<Map<String, dynamic>>('profile');
  }

  /// Convenience getters.
  String? getStoredRole() => _storage.read<String>('role');
  String? getStoredNisn() => _storage.read<String>('nisn');

  /// Fetch profile from API, cache it, and return the map.
  Future<Map<String, dynamic>> fetchProfile() async {
    final res = await _api.get('/profile');
    final profile = Map<String, dynamic>.from(res['profile'] ?? {});

    if (profile.isNotEmpty) {
      // Ensure role is present (server's /profile may omit role for parents)
      final storedRole = getStoredRole();
      if (storedRole != null &&
          (profile['role'] == null || profile['role'] == '')) {
        profile['role'] = storedRole;
      }

      await _storage.save('profile', profile);
      if (profile['role'] != null) {
        await _storage.save('role', profile['role']);
      }
      if (profile['nisn'] != null) {
        await _storage.save('nisn', profile['nisn']);
      }
    }

    return profile;
  }

  /// Change password for current user.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.post('/change-password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    }, needsAuth: true);
  }
}
