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

  /// Get list of all students with optional filtering
  /// Query params: class_id, gender, search, per_page
  Future<List<Map<String, dynamic>>> getStudents({
    int? classId,
    String? gender,
    String? search,
    String? group,
    int perPage = 15,
    int page = 1,
  }) async {
    final params = <String, String>{};
    if (classId != null) params['class_id'] = classId.toString();
    if (gender != null) params['gender'] = gender;
    if (search != null) params['search'] = search;
    if (group != null) {
      params['group'] = group; // Comma-separated groups like 'A,B'
    }
    params['per_page'] = perPage.toString();
    params['page'] = page.toString();

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/students${queryString.isNotEmpty ? '?$queryString' : ''}',
    );

    final items = res['data'] ?? res['students'] ?? res;
    if (items is List) {
      return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Get student detail by ID
  Future<Map<String, dynamic>?> getStudentById(dynamic id) async {
    try {
      final res = await _api.get('/students/${id.toString()}');
      return res['data'] ?? res;
    } catch (e) {
      return null;
    }
  }

  /// Find student by NISN (compatibility helper)
  Future<Map<String, dynamic>?> getStudentByNisn(String nisn) async {
    try {
      final res = await _api.get('/students/nisn/$nisn');
      return res['data'] ?? res;
    } catch (e) {
      return null;
    }
  }

  /// Get all classes
  Future<List<Map<String, dynamic>>> getClasses() async {
    final res = await _api.get('/classes');

    // Handle both paginated and direct list responses
    if (res['data'] != null && res['data'] is List) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return List<Map<String, dynamic>>.from(res['data'] ?? res['classes'] ?? []);
  }

  /// Create new student
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> data) async {
    final res = await _api.post('/students', data);
    return res;
  }

  /// Update student
  Future<Map<String, dynamic>> updateStudent(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await _api.put('/students/$id', data);
    return res;
  }

  /// Delete student
  Future<void> deleteStudent(int id) async {
    await _api.delete('/students/$id');
  }

  /// Upload student photo
  Future<Map<String, dynamic>> uploadStudentPhoto(
    int studentId,
    File photo,
  ) async {
    final res = await _api.postMultipart(
      '/students/$studentId/upload-photo',
      {},
      'photo',
      photo.path,
    );
    return res;
  }

  /// Get student attendance records
  Future<List<Map<String, dynamic>>> getStudentAttendance(int studentId) async {
    final res = await _api.get('/students/$studentId/attendance');

    if (res['data'] != null && res['data'] is List) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }
}
