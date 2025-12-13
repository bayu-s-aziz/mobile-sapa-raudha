import 'package:get/get.dart';
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
    final res = await _api.post('/auth/login', {
      'identifier': identifier,
      'password': password,
    });

    if (res['token'] != null) {
      await _storage.save('auth_token', res['token']);
      final role = (res['profile']?['role'] ?? '') as String;
      await _storage.save('role', role);
      await _storage.save('profile', res['profile']);
      return res;
    }
    return null;
  }
}
