import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/auth_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/secure_storage_service.dart';

class TestApiClient extends ApiClient {
  TestApiClient() : super(baseUrl: 'https://test.example');

  TestApiClient init() => this;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool needsAuth = false,
  }) async {
    if (path == '/auth/login') {
      return {
        'data': {
          'token': 'tok-remember',
          'user': {'id': 7, 'name': 'T'},
        },
      };
    }
    return {};
  }
}

class DummySecureStorage extends SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> save(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> remove(String key) async => _store.remove(key);
}

class DummyLocalStorage extends LocalStorageService {
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
  Future<void> remove(String key) async => _store.remove(key);
}

void main() {
  group('AuthService remember-me', () {
    late TestApiClient api;
    late DummyLocalStorage local;
    late DummySecureStorage secure;
    late AuthService auth;

    setUp(() {
      Get.reset();
      api = TestApiClient().init();
      local = DummyLocalStorage();
      secure = DummySecureStorage();
      Get.put<ApiClient>(api);
      Get.put<LocalStorageService>(local);
      Get.put<SecureStorageService>(secure);
      auth = AuthService();
      auth.onInit();
    });

    test('saves token to secure storage when remember=true', () async {
      final res = await auth.login(
        email: 'x@x.com',
        password: 'p',
        remember: true,
      );
      expect(res, isNotNull);
      final token = await secure.read('auth_token');
      expect(token, 'tok-remember');
      // ensure local storage does not have token
      final localToken = local.read<String>('auth_token');
      expect(localToken, isNull);
    });

    test('saves token to local storage when remember=false', () async {
      final res = await auth.login(
        email: 'x@x.com',
        password: 'p',
        remember: false,
      );
      expect(res, isNotNull);
      final token = local.read<String>('auth_token');
      expect(token, 'tok-remember');
      final secureToken = await secure.read('auth_token');
      expect(secureToken, isNull);
    });
  });
}
