import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/data/services/local_storage_service.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import 'attendance_state_manager.dart';

class AttendanceService extends GetxService {
  late final ApiClient _api;
  late final LocalStorageService _storage;
  AttendanceStateManager? _attendanceStateManager;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    _storage = Get.find<LocalStorageService>();
    // optional: AttendanceStateManager may not be registered in unit tests
    if (Get.isRegistered<AttendanceStateManager>()) {
      _attendanceStateManager = Get.find<AttendanceStateManager>();
    }
  }

  void _maybeSyncAttendance(Map<String, dynamic> res) {
    try {
      final mgr = _attendanceStateManager;
      if (mgr == null) return;

      Map<String, dynamic>? record;
      dynamic studentIdRaw;

      if (res['data'] is Map) {
        record = Map<String, dynamic>.from(res['data'] as Map);
        studentIdRaw = record['student_id'] ?? record['studentId'];
      } else if (res['attendance'] is Map) {
        record = Map<String, dynamic>.from(res['attendance'] as Map);
        studentIdRaw = record['student_id'] ?? record['studentId'];
      } else if (res['student'] is Map && res['attendance'] is Map) {
        final student = res['student'] as Map;
        studentIdRaw = student['id'];
        record = Map<String, dynamic>.from(res['attendance'] as Map);
      } else if (res['student'] is Map && res['data'] is Map) {
        final student = res['student'] as Map;
        studentIdRaw = student['id'];
        record = Map<String, dynamic>.from(res['data'] as Map);
      }

      if (studentIdRaw == null || record == null || record.isEmpty) return;

      final sid = studentIdRaw is int
          ? studentIdRaw
          : int.tryParse(studentIdRaw.toString());
      if (sid == null) return;

      mgr.updateAttendance(sid, record);
    } catch (_) {}
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

    final path =
        '/attendance/statistics${queryString.isNotEmpty ? '?$queryString' : ''}';
    final res = await _api.get(path);
    developer.log(
      'AttendanceService.getStatistics request=$path response=$res',
      name: 'AttendanceService',
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
    // Hit API dengan rentang tanggal untuk hari ini berdasarkan zona waktu GMT+7
    // (server mengharapkan start_date & end_date di zona lokal sekolah)
    final nowUtc = DateTime.now().toUtc();
    final nowGmt7 = nowUtc.add(const Duration(hours: 7));
    final today = DateFormat('yyyy-MM-dd').format(nowGmt7);

    return getStatistics(classId: classId, startDate: today, endDate: today);
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

  /// Find a student by NIS (search endpoint).
  /// Returns a student map if found, or null.
  Future<Map<String, dynamic>?> findStudentByNis(String nis) async {
    final searchRes = await _api.get(
      '/students?search=${Uri.encodeQueryComponent(nis)}',
    );
    final items = searchRes['data'] ?? searchRes;
    if (items is List && items.isNotEmpty) {
      for (final item in items) {
        final m = item as Map<String, dynamic>;
        if (m['nis']?.toString() == nis || m['nisn']?.toString() == nis) {
          return m;
        }
      }
      // fallback to first
      return Map<String, dynamic>.from(items.first as Map);
    } else if (items is Map) {
      return Map<String, dynamic>.from(items);
    }
    return null;
  }

  /// Scan attendance via code (controller expects positional param)
  /// Scan attendance via code (controller expects positional param)
  /// If [confirmCheckout] is true, include a confirmation flag to indicate
  /// the second-scan checkout should be processed.
  Future<Map<String, dynamic>> scanAttendance(
    dynamic code, {
    bool confirmCheckout = false,
  }) async {
    // Log the incoming code for debugging
    developer.log(
      'scanAttendance called with code: $code',
      name: 'AttendanceService',
    );

    // Include a fallback 'nis' field for servers that expect 'nis' instead of 'code'
    final payload = {
      'code': code,
      'nis': code,
      if (confirmCheckout) 'confirm_checkout': true,
    };

    try {
      final res = await _api.post('/attendance/scan', payload, needsAuth: true);
      developer.log('scanAttendance response: $res', name: 'AttendanceService');

      // Sync successful scan/create/update result to shared state manager so
      // student list / detail views update in real time
      try {
        _maybeSyncAttendance(res);
      } catch (_) {}

      return res;
    } on ApiException catch (e, st) {
      developer.log(
        'scanAttendance ApiException: ${e.statusCode} - ${e.message}',
        name: 'AttendanceService',
        error: e,
        stackTrace: st,
      );
      // If server rejects POST (405), fall back to an implementation using the
      // attendance index/create endpoints. This server seems to expect
      // POST /attendance (create), GET /students (search) and PUT /attendance/{id}
      // (update). We'll implement a safe fallback:
      // 1) Look up student by NIS using /students?search=nis
      // 2) If not found -> rethrow with a helpful message
      // 3) Check today's attendance via /attendance?student_id=&start_date=&end_date=
      // 4) If no attendance -> createAttendance (status: 'hadir')
      // 5) If attendance exists and no check_out -> return a response with
      //    'confirm_checkout' => controller will prompt user; if controller calls
      //    again with confirmCheckout == true we'll perform the update
      if (e.statusCode == 405) {
        try {
          developer.log(
            'Falling back to student search + attendance create/update',
            name: 'AttendanceService',
          );

          // 1) Search student by NIS using the students index
          final searchRes = await _api.get(
            '/students?search=${Uri.encodeQueryComponent(code.toString())}',
          );
          final items = searchRes['data'] ?? searchRes;
          Map<String, dynamic>? student;
          if (items is List) {
            // Find exact match by 'nis' if possible
            for (final item in items) {
              final m = item as Map<String, dynamic>;
              if (m['nis']?.toString() == code.toString() ||
                  m['nisn']?.toString() == code.toString()) {
                student = m;
                break;
              }
            }
            // Fallback: take first item if exact match not found but list has something
            if (student == null && items.isNotEmpty) {
              student = (items.first as Map<String, dynamic>);
            }
          } else if (items is Map) {
            student = Map<String, dynamic>.from(items);
          }

          if (student == null) {
            throw ApiException(404, 'Siswa tidak ditemukan untuk kode $code');
          }

          final studentId = student['id'];
          if (studentId == null) {
            throw ApiException(
              400,
              'Tidak dapat menentukan ID siswa untuk $code',
            );
          }

          // Today's date in server expected format
          final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
          final String today = dateFormatter.format(DateTime.now());

          // 3) Check existing attendance for today
          final attRes = await getAttendance(studentId: studentId, date: today);
          final attItems =
              attRes['data'] ?? attRes['attendance'] ?? attRes['items'] ?? [];
          Map<String, dynamic>? todayRecord;
          if (attItems is List && attItems.isNotEmpty) {
            todayRecord = Map<String, dynamic>.from(attItems.first as Map);
          }

          // 4) If no attendance record -> create one (include check_in timestamp)
          final timeFormatter = DateFormat('HH:mm:ss');
          final nowTime = timeFormatter.format(DateTime.now());
          if (todayRecord == null) {
            // Try create attendance; if server rejects check_in format (422), retry
            final List<String> alternateTimes = [
              DateFormat('HH:mm').format(DateTime.now()),
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            ];

            try {
              final createRes = await createAttendance({
                'student_id': studentId,
                'date': today,
                'status': 'hadir',
                'check_in': nowTime,
              });
              return createRes;
            } on ApiException catch (e) {
              // If validation error for check_in, try alternate formats
              final body = e.body;
              final hasCheckInError =
                  body is Map &&
                  (body['check_in'] != null ||
                      (body.values.any(
                        (v) => v.toString().toLowerCase().contains('check in'),
                      )));
              if (e.statusCode == 422 && hasCheckInError) {
                developer.log(
                  'createAttendance failed validation for check_in, trying alternate formats',
                  name: 'AttendanceService',
                );
                for (final alt in alternateTimes) {
                  try {
                    final createRes2 = await createAttendance({
                      'student_id': studentId,
                      'date': today,
                      'status': 'hadir',
                      'check_in': alt,
                    });
                    developer.log(
                      'createAttendance succeeded with alternate check_in: $alt',
                      name: 'AttendanceService',
                    );
                    return createRes2;
                  } catch (e2) {
                    developer.log(
                      'Alternate check_in $alt failed: $e2',
                      name: 'AttendanceService',
                    );
                    continue;
                  }
                }
              }

              // Re-throw original exception if we couldn't recover
              rethrow;
            }
          }

          // 5) Attendance exists. If confirmCheckout flag present, perform checkout update
          if (confirmCheckout) {
            final attendanceId = todayRecord['id'];
            if (attendanceId == null) {
              throw ApiException(400, 'Record presensi tidak memiliki ID');
            }
            final timeFormatter = DateFormat('HH:mm:ss');
            final nowTime = timeFormatter.format(DateTime.now());
            final updateRes = await updateAttendance(attendanceId, {
              'check_out': nowTime,
            });

            try {
              _maybeSyncAttendance(updateRes);
            } catch (_) {}

            return updateRes;
          }

          // If we reach here, attendance exists but confirmCheckout was not passed;
          // signal to the caller that checkout confirmation is required.
          return {
            'confirm_checkout': true,
            'student': student,
            'attendance': todayRecord,
          };
        } catch (fallbackError, fallbackSt) {
          developer.log(
            'Fallback attempt failed: $fallbackError',
            name: 'AttendanceService',
            error: fallbackError,
            stackTrace: fallbackSt,
          );
          // As a last resort, keep trying the previous GET fallbacks for /attendance/scan
          try {
            developer.log(
              'Attempting GET fallback /attendance/scan?code=$code',
              name: 'AttendanceService',
            );
            final resGet = await _api.get(
              '/attendance/scan?code=${Uri.encodeQueryComponent(code.toString())}',
            );
            developer.log(
              'scanAttendance GET fallback response: $resGet',
              name: 'AttendanceService',
            );
            return resGet;
          } catch (e2, st2) {
            developer.log(
              'GET fallback failed: $e2',
              name: 'AttendanceService',
              error: e2,
              stackTrace: st2,
            );
            try {
              developer.log(
                'Attempting GET fallback /attendance/scan?nis=$code',
                name: 'AttendanceService',
              );
              final resGet2 = await _api.get(
                '/attendance/scan?nis=${Uri.encodeQueryComponent(code.toString())}',
              );
              developer.log(
                'scanAttendance GET fallback(2) response: $resGet2',
                name: 'AttendanceService',
              );
              return resGet2;
            } catch (e3, st3) {
              developer.log(
                'GET fallback(2) failed: $e3',
                name: 'AttendanceService',
                error: e3,
                stackTrace: st3,
              );
              // Rethrow the original ApiException to preserve context
              throw e;
            }
          }
        }
      }
      rethrow;
    } catch (e, st) {
      developer.log(
        'scanAttendance unexpected error: $e',
        name: 'AttendanceService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
