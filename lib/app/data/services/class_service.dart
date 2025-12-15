import 'package:get/get.dart';
import 'api_client.dart';

class ClassService extends GetxService {
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  /// Get all classes
  Future<List<Map<String, dynamic>>> getClasses() async {
    final res = await _api.get('/classes');
    return List<Map<String, dynamic>>.from(res['classes'] ?? []);
  }

  /// Create new class
  Future<Map<String, dynamic>> createClass(Map<String, dynamic> data) async {
    final res = await _api.post('/classes', data);
    return res;
  }

  /// Update class
  Future<void> updateClass(int id, Map<String, dynamic> data) async {
    await _api.put('/classes/$id', data);
  }

  /// Delete class
  Future<void> deleteClass(int id) async {
    await _api.delete('/classes/$id');
  }
}
