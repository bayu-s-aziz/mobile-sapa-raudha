import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';

class DummyLocalStorageService extends LocalStorageService {
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

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  bool containsKey(String key) => _store.containsKey(key);
}

void main() {
  group('ApiClient handleUnauthorized', () {
    late DummyLocalStorageService storage;
    late ApiClient api;

    setUp(() {
      Get.reset();
      storage = DummyLocalStorageService();
      storage.save('auth_token', 'token-abc');
      storage.save('user', {'id': 1, 'name': 'Test'});

      Get.put<LocalStorageService>(storage);
      api = ApiClient(baseUrl: 'https://test');
      api.onInit();
    });

    test('clears auth_token and user from storage', () async {
      expect(storage.containsKey('auth_token'), isTrue);
      expect(storage.containsKey('user'), isTrue);

      await api.handleUnauthorized();

      expect(storage.containsKey('auth_token'), isFalse);
      expect(storage.containsKey('user'), isFalse);
    });

    test('calling handleUnauthorized twice is safe (idempotent)', () async {
      // First call should clear storage
      await api.handleUnauthorized(reason: 'first');
      expect(storage.containsKey('auth_token'), isFalse);
      expect(storage.containsKey('user'), isFalse);

      // Re-populate to simulate multiple triggers, then call twice
      storage.save('auth_token', 'token-xyz');
      storage.save('user', {'id': 2});
      expect(storage.containsKey('auth_token'), isTrue);

      await api.handleUnauthorized(reason: 'second');
      // Immediately call again to simulate concurrent/rapid triggers
      await api.handleUnauthorized(reason: 'third');

      expect(storage.containsKey('auth_token'), isFalse);
      expect(storage.containsKey('user'), isFalse);
    });
  });
}
