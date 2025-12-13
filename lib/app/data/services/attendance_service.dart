import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';

class AttendanceService extends GetxService {
  late final ApiClient _api;
  late final LocalStorageService _storage;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    _storage = Get.find<LocalStorageService>();
  }

  Future<Map<String, dynamic>> scanAttendance(String nisn) async {
    final res = await _api.post('/attendance/scan', {
      'nisn': nisn,
    }, needsAuth: true);
    return res;
  }

  Future<List<Map<String, dynamic>>> getStudentHistory(
    String nisn, {
    int limit = 30,
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, String>{
      'limit': '$limit',
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };
    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    final res = await _api.get(
      '/attendance/student/$nisn${queryString.isEmpty ? '' : '?$queryString'}',
    );
    return List<Map<String, dynamic>>.from(res['attendance'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getClassAttendance(
    int classId,
    String date,
  ) async {
    final res = await _api.get('/attendance/class/$classId/date/$date');
    return List<Map<String, dynamic>>.from(res['attendance'] ?? []);
  }

  Future<Map<String, dynamic>> getStatsToday() async {
    final res = await _api.get('/attendance/stats');
    return res;
  }

  String? getStoredChildNisn() {
    final profile = _storage.read<Map<String, dynamic>>('profile');
    return profile?['nisn'] as String?;
  }
}
