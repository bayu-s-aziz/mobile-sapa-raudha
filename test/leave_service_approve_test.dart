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
    return {'message': 'ok'};
  }
}

void main() {
  group('LeaveService approve/reject auth', () {
    late TestApiClient api;
    late LeaveService svc;

    setUp(() {
      Get.reset();
      api = TestApiClient();
      Get.put<ApiClient>(api);
      svc = LeaveService();
      svc.onInit();
    });

    test('approve uses authenticated POST', () async {
      await svc.approve(123);
      expect(api.lastNeedsAuth, isTrue);
    });

    test('reject uses authenticated POST', () async {
      await svc.reject(123, rejectionReason: 'No');
      expect(api.lastNeedsAuth, isTrue);
    });
  });
}
