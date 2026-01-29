import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/announcement_service.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/profile_service.dart';

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
    // Return a simple success payload
    return {
      'message': 'ok',
      'data': {'id': 1},
    };
  }
}

class DummyProfileService extends ProfileService {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  int? getUserableId() => 2;
}

void main() {
  group('AnnouncementService', () {
    late TestApiClient api;
    late AnnouncementService svc;

    setUp(() {
      Get.reset();
      api = TestApiClient();
      Get.put<ApiClient>(api);
      Get.put<ProfileService>(DummyProfileService());
      Get.put<AnnouncementService>(AnnouncementService());
      svc = Get.find<AnnouncementService>();
    });

    test('create uses authenticated POST when no attachment', () async {
      await svc.create(title: 'T', content: 'C');
      expect(api.lastNeedsAuth, isTrue);
    });
  });
}
