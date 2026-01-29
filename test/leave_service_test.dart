import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/leave_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';

class TestApiClient extends ApiClient {
  bool? lastNeedsAuth;

  TestApiClient() : super(baseUrl: 'https://test.example');

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool needsAuth = false,
  }) async {
    lastNeedsAuth = needsAuth;
    return {
      'message': 'ok',
      'data': {'id': 1},
    };
  }
}

void main() {
  group('LeaveService', () {
    late TestApiClient api;
    late LeaveService svc;

    setUp(() {
      Get.reset();
      api = TestApiClient();
      Get.put<ApiClient>(api);
      svc = LeaveService();
      svc.onInit();
    });

    test('submitLeave uses authenticated POST when no attachment', () async {
      await svc.submitLeave(
        reason: 'Sakit',
        studentNisn: '1234',
        requestDate: '2026-01-29',
      );
      expect(api.lastNeedsAuth, isTrue);
    });
  });
}
