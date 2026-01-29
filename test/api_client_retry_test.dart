import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'package:sapa_raudha/app/data/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class DummyLocal extends LocalStorageService {}

class DummySecure extends SecureStorageService {}

class RetryApiClient extends ApiClient {
  int calls = 0;
  RetryApiClient() : super(baseUrl: 'https://test');

  @override
  Future<http.Response> performPost(
    Uri uri,
    Map<String, String> headers,
    String body,
  ) async {
    calls++;
    if (calls == 1) {
      return http.Response('Unauthorized', 401);
    }
    return http.Response('{"result":"ok"}', 200);
  }
}

void main() {
  group('ApiClient retry-on-401', () {
    late RetryApiClient api;

    setUp(() {
      Get.reset();
      Get.put<LocalStorageService>(DummyLocal());
      Get.put<SecureStorageService>(DummySecure());
      api = RetryApiClient();
      api.onInit();
    });

    test('post retries once on 401 and succeeds', () async {
      final res = await api.post('/test', {'a': 1});
      expect(res['result'], 'ok');
      expect(api.calls, 2);
    });
  });
}
