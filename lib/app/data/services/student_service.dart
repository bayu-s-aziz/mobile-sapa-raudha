import 'package:get/get.dart';
import 'api_client.dart';

class StudentService extends GetxService {
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  /// Get list of all students (guru only)
  Future<List<Map<String, dynamic>>> getStudents({int? classId}) async {
    final params = classId != null ? '?class_id=$classId' : '';
    final res = await _api.get('/students$params');
    return List<Map<String, dynamic>>.from(res['students'] ?? []);
  }

  /// Get student detail by ID
  Future<Map<String, dynamic>?> getStudentById(int id) async {
    try {
      final res = await _api.get('/students/$id');
      return res['student'];
    } catch (e) {
      return null;
    }
  }

  /// Get student by NISN
  Future<Map<String, dynamic>?> getStudentByNisn(String nisn) async {
    try {
      final res = await _api.get('/students/nisn/$nisn');
      return res['student'];
    } catch (e) {
      return null;
    }
  }

  /// Get all classes
  Future<List<Map<String, dynamic>>> getClasses() async {
    final res = await _api.get('/classes');
    return List<Map<String, dynamic>>.from(res['classes'] ?? []);
  }
}
