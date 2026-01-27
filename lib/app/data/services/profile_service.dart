import 'package:get/get.dart';
import 'api_client.dart';
import 'local_storage_service.dart';
import 'dart:developer' as developer;

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

  /// Return the cached user profile (if any).
  Map<String, dynamic>? getStoredUser() {
    return _storage.read<Map<String, dynamic>>('user');
  }

  /// Get specific user field from cached profile
  dynamic getStoredUserField(String key) {
    final user = getStoredUser();
    return user?[key];
  }

  /// Fetch profile from API and cache it
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      // If no auth token in storage, skip calling /user to avoid 401 noise
      final token = _storage.read<String>('auth_token');
      if (token == null || token.isEmpty) {
        developer.log(
          '[PROFILE] No auth token present - skipping profile fetch',
          name: 'ProfileService',
        );
        return {};
      }

      final res = await _api.get('/user');

      if (res['success'] == true && res['data'] != null) {
        final user = Map<String, dynamic>.from(res['data']);
        await _storage.save('user', user);
        developer.log(
          '[PROFILE] Profile fetched and cached',
          name: 'ProfileService',
        );
        return user;
      }
      return {};
    } catch (e, st) {
      developer.log(
        '[PROFILE] Error fetching profile: $e',
        name: 'ProfileService',
        error: e,
        stackTrace: st,
      );

      // Suppress unauthenticated errors (401) during app init to avoid noisy snackbars
      if (e is ApiException && e.statusCode == 401) {
        developer.log(
          '[PROFILE] Unauthenticated - returning empty profile',
          name: 'ProfileService',
        );
        return {};
      }

      rethrow;
    }
  }

  /// Get current user ID from cached profile
  int? getUserId() {
    final user = getStoredUser();
    if (user != null && user['id'] is int) {
      return user['id'] as int;
    }
    return null;
  }

  /// Get current user name with fallback to userable
  String? getUserName() {
    final user = getStoredUser();
    if (user != null) {
      // Prioritas: name dari user, lalu dari userable
      final name = user['name'] as String?;
      if (name != null && name.isNotEmpty) return name;

      final userable = user['userable'] as Map<String, dynamic>?;
      if (userable != null) {
        // Untuk Guru: name
        if (userable.containsKey('name')) return userable['name'];
        // Untuk Orang Tua: father_name, mother_name, guardian_name
        final father = userable['father_name'] as String?;
        final mother = userable['mother_name'] as String?;
        final guardian = userable['guardian_name'] as String?;
        return father?.isNotEmpty == true
            ? father
            : (mother?.isNotEmpty == true ? mother : guardian);
      }
    }
    return null;
  }

  /// Get current user email
  String? getUserEmail() {
    return getStoredUserField('email') as String?;
  }

  /// Get user type (App\Models\Siswa, App\Models\Guru, etc)
  String? getUserType() {
    return getStoredUserField('userable_type') as String?;
  }

  /// Get user role
  String? getUserRole() {
    final user = getStoredUser();
    final userableType = user?['userable_type'] as String?;
    if (userableType?.contains('Guru') == true) return 'guru';
    if (userableType?.contains('Parent') == true) return 'orangtua';
    return null;
  }

  /// Get user's related ID (e.g., siswa_id, guru_id, parent_id)
  int? getUserableId() {
    final id = getStoredUserField('userable_id');
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  /// Get user's photo URL
  String? getUserPhotoUrl() {
    return getStoredUserField('photo_url') as String?;
  }

  /// Check if user is a student
  bool isStudent() {
    final userType = getUserType();
    return userType != null && userType.contains('Siswa');
  }

  /// Check if user is a teacher/guru
  bool isTeacher() {
    final userType = getUserType();
    return userType != null && userType.contains('Guru');
  }

  /// Check if user is a parent
  bool isParent() {
    final userType = getUserType();
    return userType != null && userType.contains('ParentModel');
  }

  /// Clear cached user profile
  Future<void> clearProfile() async {
    await _storage.remove('user');
  }

  // --- Backwards-compatible helpers ---
  Map<String, dynamic>? getStoredProfile() {
    return getStoredUser();
  }

  String? getStoredRole() {
    return getUserRole();
  }

  String? getStoredNisn() {
    final user = getStoredUser();
    if (user == null) return null;

    // Untuk siswa: langsung dari user
    if (user['nisn'] != null) return user['nisn'].toString();

    // Untuk orang tua: dari relasi student di userable
    final userable = user['userable'] as Map<String, dynamic>?;
    if (userable != null) {
      final student = userable['student'] as Map<String, dynamic>?;
      if (student != null && student['nisn'] != null) {
        return student['nisn'].toString();
      }
    }

    // Fallback tambahan: cek field lain di user
    if (user['student_nisn'] != null) return user['student_nisn'].toString();
    if (user['nisn_anak'] != null) return user['nisn_anak'].toString();
    if (user['anak']?['nisn'] != null) return user['anak']['nisn'].toString();

    return null;
  }

  /// Change password for the current user
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _api.post('/auth/change-password', {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      developer.log('[PROFILE] Password changed', name: 'ProfileService');
    } catch (e, st) {
      developer.log(
        '[PROFILE] Change password error: $e',
        name: 'ProfileService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
