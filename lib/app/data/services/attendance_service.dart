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

  /// Get attendance records with optional filtering
  /// Query params: student_id, date, status, per_page
  Future<Map<String, dynamic>> getAttendance({
    int? studentId,
    String? date,
    String? status,
    int perPage = 15,
    int page = 1,
  }) async {
    final query = <String, String>{};
    if (studentId != null) query['student_id'] = studentId.toString();

    // Map single date to start_date & end_date so backend filtering works correctly
    if (date != null) {
      query['start_date'] = date;
      query['end_date'] = date;
    }

    if (status != null) query['status'] = status;
    query['per_page'] = perPage.toString();
    query['page'] = page.toString();

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/attendance${queryString.isNotEmpty ? '?$queryString' : ''}',
    );
    return res;
  }

  /// Get attendance summary statistics
  Future<Map<String, dynamic>> getStatistics({
    int? classId,
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, String>{};
    if (classId != null) query['class_id'] = classId.toString();
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/attendance/statistics${queryString.isNotEmpty ? '?$queryString' : ''}',
    );
    return res;
  }

  /// Get class attendance summary
  Future<Map<String, dynamic>> getClassSummary({
    int? classId,
    String? date,
  }) async {
    final query = <String, String>{};
    if (classId != null) query['class_id'] = classId.toString();
    if (date != null) query['date'] = date;

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/attendance/class-summary${queryString.isNotEmpty ? '?$queryString' : ''}',
    );
    return res;
  }

  /// Get student attendance report
  Future<dynamic> getStudentReport({
    required dynamic studentId,
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, String>{};
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/attendance/student/${studentId.toString()}/report${queryString.isNotEmpty ? '?$queryString' : ''}',
    );
    return res;
  }

  /// Create new attendance record
  /// Accepts a full payload map for compatibility with controllers.
  Future<Map<String, dynamic>> createAttendance(
    Map<String, dynamic> data,
  ) async {
    final res = await _api.post('/attendance', data, needsAuth: true);
    return res;
  }

  /// Bulk update attendance
  Future<Map<String, dynamic>> bulkUpdate({
    required int classId,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    final res = await _api.post('/attendance/bulk-update', {
      'class_id': classId,
      'date': date,
      'records': records,
    }, needsAuth: true);
    return res;
  }

  /// Get single attendance record
  Future<Map<String, dynamic>?> getAttendanceById(dynamic id) async {
    try {
      final res = await _api.get('/attendance/${id.toString()}');
      return res['data'] ?? res;
    } catch (e) {
      return null;
    }
  }

  /// Update attendance record
  Future<Map<String, dynamic>> updateAttendance(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    final res = await _api.put('/attendance/${id.toString()}', data);
    return res;
  }

  /// Delete attendance record
  Future<void> deleteAttendance(dynamic id) async {
    await _api.delete('/attendance/${id.toString()}');
  }

  /// Get stored user profile
  Map<String, dynamic>? getStoredUser() {
    return _storage.read<Map<String, dynamic>>('user');
  }

  // --- Compatibility helpers used by controllers ---
  String? getStoredChildNisn() {
    final user = _storage.read<Map<String, dynamic>>('user');
    if (user == null) return null;
    // Try common locations for nisn
    if (user['nisn'] != null) return user['nisn'].toString();
    if (user['student'] is Map && user['student']['nisn'] != null) {
      return user['student']['nisn'].toString();
    }
    if (user['child'] is Map && user['child']['nisn'] != null) {
      return user['child']['nisn'].toString();
    }
    return null;
  }

  Future<Map<String, dynamic>> getStatsToday({int? classId}) async {
    return getStatistics(classId: classId);
  }

  Future<List<Map<String, dynamic>>> getStudentHistory(
    dynamic studentId, {
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    // If a single day range is requested, use the attendance index endpoint
    // which supports date filtering and returns paginated results.
    if (startDate != null && endDate != null && startDate == endDate) {
      try {
        final id = studentId is int
            ? studentId
            : int.tryParse(studentId?.toString() ?? '');
        if (id == null) return [];

        final res = await getAttendance(
          studentId: id,
          date: startDate,
          perPage: 1,
        );
        final items =
            res['data'] ??
            res['attendance'] ??
            res['attendance_records'] ??
            res['items'];
        if (items is List) {
          final list = items
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          if (limit != null && list.length > limit) {
            return list.sublist(0, limit);
          }
          return list;
        }
        return [];
      } catch (e) {
        return [];
      }
    }

    final res = await getStudentReport(
      studentId: studentId is int
          ? studentId
          : int.tryParse(studentId?.toString() ?? ''),
      startDate: startDate,
      endDate: endDate,
    );

    // Normalize response: prefer 'attendance_records', then 'data', and handle raw list
    dynamic items;
    if (res is Map) {
      if (res.containsKey('attendance_records') &&
          res['attendance_records'] is List) {
        items = res['attendance_records'];
      } else if (res.containsKey('data') && res['data'] is List) {
        items = res['data'];
      } else {
        // No list available in response
        items = null;
      }
    } else if (res is List) {
      items = res;
    } else {
      items = null;
    }

    if (items == null) return [];

    final list = (items as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (limit != null && list.length > limit) return list.sublist(0, limit);
    return list;
  }

  /// Scan attendance via code (controller expects positional param)
  Future<Map<String, dynamic>> scanAttendance(dynamic code) async {
    final res = await _api.post('/attendance/scan', {
      'code': code,
    }, needsAuth: true);
    return res;
  }
}
