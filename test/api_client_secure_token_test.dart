import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/secure_storage_service.dart';

class DummyLocal extends LocalStorageService {
  final Map<String, dynamic> _store = {};
  @override
  Future<void> save(String key, dynamic value) async {
    _store[key] = value;
  }

  @override
  T? read<T>(String key) {
    final v = _store[key];
    return v as T?;
  }
}

class DummySecure extends SecureStorageService {
  final Map<String, String> _store = {};
  @override
  Future<void> save(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> read(String key) async => _store[key];
}

void main() {
  group('ApiClient uses secure storage token when local missing', () {
    late DummyLocal local;
    late DummySecure secure;
    late ApiClient api;

    setUp(() {
      Get.reset();
      local = DummyLocal();
      secure = DummySecure();
      Get.put<LocalStorageService>(local);
      Get.put<SecureStorageService>(secure);

      api = ApiClient(baseUrl: 'https://test');
      api.onInit();
    });

    test('prefers secure token when local token absent', () async {
      await secure.save('auth_token', 'secure-token-123');

      final headers = await api.getAuthHeaders();
      expect(headers['Authorization'], 'Bearer secure-token-123');
    });

    test('prefers local token when present', () async {
      await local.save('auth_token', 'local-token-abc');
      await secure.save('auth_token', 'secure-token-123');

      final headers = await api.getAuthHeaders();
      expect(headers['Authorization'], 'Bearer local-token-abc');
    });
  });
}
