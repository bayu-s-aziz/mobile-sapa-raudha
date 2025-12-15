import 'package:get/get.dart';
import 'dart:io';
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

  /// Create new student
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> data) async {
    final res = await _api.post('/students', data);
    return res;
  }

  /// Update student
  Future<void> updateStudent(int id, Map<String, dynamic> data) async {
    await _api.put('/students/$id', data);
  }

  /// Delete student
  Future<void> deleteStudent(int id) async {
    await _api.delete('/students/$id');
  }

  /// Upload student photo
  Future<void> uploadStudentPhoto(int studentId, File photo) async {
    await _api.postMultipart(
      '/api/students/$studentId/photo',
      {},
      'photo',
      photo.path,
    );
  }
}
