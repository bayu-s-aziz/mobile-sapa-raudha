import 'package:get/get.dart';
import 'api_client.dart';

class ClassService extends GetxService {
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  /// Get all classes with pagination
  Future<Map<String, dynamic>> getClasses({
    int? academicYearId,
    int perPage = 15,
    int page = 1,
  }) async {
    final query = <String, String>{};
    if (academicYearId != null) {
      query['academic_year_id'] = academicYearId.toString();
    }
    query['per_page'] = perPage.toString();
    query['page'] = page.toString();

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/classes${queryString.isNotEmpty ? '?$queryString' : ''}',
    );
    return res;
  }

  /// Get single class detail
  Future<Map<String, dynamic>?> getClassById(int id) async {
    try {
      final res = await _api.get('/classes/$id');
      return res['data'] ?? res;
    } catch (e) {
      return null;
    }
  }

  /// Create new class
  Future<Map<String, dynamic>> createClass({
    required String name,
    required int academicYearId,
    String? description,
  }) async {
    final res = await _api.post('/classes', {
      'name': name,
      'academic_year_id': academicYearId,
      if (description != null) 'description': description,
    });
    return res;
  }

  /// Update class
  Future<Map<String, dynamic>> updateClass(
    int id, {
    String? name,
    int? academicYearId,
    String? description,
  }) async {
    final res = await _api.put('/classes/$id', {
      if (name != null) 'name': name,
      if (academicYearId != null) 'academic_year_id': academicYearId,
      if (description != null) 'description': description,
    });
    return res;
  }

  /// Delete class
  Future<void> deleteClass(int id) async {
    await _api.delete('/classes/$id');
  }

  /// Add academic year to class
  Future<Map<String, dynamic>> addAcademicYear(
    int classId,
    int academicYearId,
  ) async {
    final res = await _api.post('/classes/add-academic-year', {
      'class_id': classId,
      'academic_year_id': academicYearId,
    });
    return res;
  }
}
