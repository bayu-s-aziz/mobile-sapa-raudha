import 'dart:io';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';

class LeaveService extends GetxService {
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  /// Submit new leave request
  Future<Map<String, dynamic>> submitLeave({
    // Compatibility: controllers may pass `studentNisn` and `requestDate`
    String? studentNisn,
    String? requestDate,
    String? startDate,
    String? endDate,
    required String reason,
    File? attachment,
  }) async {
    final payload = <String, dynamic>{
      if (studentNisn != null) 'student_nisn': studentNisn,
      if (requestDate != null) 'request_date': requestDate,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'reason': reason,
    };

    if (attachment != null) {
      final res = await _api.postMultipart(
        '/leave-requests',
        payload.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        'attachment',
        attachment.path,
      );
      return res;
    }

    final res = await _api.post('/leave-requests', payload);
    return res;
  }

  /// Get all leave requests with optional filtering
  /// Query params: status (pending, approved, rejected), student_id, per_page
  Future<List<Map<String, dynamic>>> getLeaveRequests({
    String? status,
    dynamic studentId,
    int perPage = 15,
    int page = 1,
  }) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (studentId != null) query['student_id'] = studentId.toString();
    query['per_page'] = perPage.toString();
    query['page'] = page.toString();

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final res = await _api.get(
      '/leave-requests${queryString.isNotEmpty ? '?$queryString' : ''}',
    );
    final items = res['data'] ?? res['items'] ?? res;
    if (items is List) {
      return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Get pending leave requests only
  Future<List<Map<String, dynamic>>> getPending({
    int perPage = 15,
    int page = 1,
  }) async {
    final query = {'per_page': perPage.toString(), 'page': page.toString()};
    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    final res = await _api.get('/leave-requests/pending?$queryString');
    final items = res['data'] ?? res;
    if (items is List) {
      return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Get leave requests by student
  Future<List<Map<String, dynamic>>> getByStudent(dynamic studentId) async {
    final res = await _api.get(
      '/leave-requests/student/${studentId.toString()}',
    );
    final items = res['data'] ?? res;
    if (items is List) {
      return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final res = await _api.get('/leave-requests/statistics');
    return res;
  }

  /// Get single leave request detail
  Future<Map<String, dynamic>?> getById(dynamic id) async {
    try {
      final res = await _api.get('/leave-requests/${id.toString()}');
      return res['data'] ?? res;
    } catch (e) {
      return null;
    }
  }

  /// Approve leave request
  Future<Map<String, dynamic>> approve(dynamic id) async {
    final res = await _api.post('/leave-requests/${id.toString()}/approve', {});
    return res;
  }

  /// Reject leave request
  Future<Map<String, dynamic>> reject(
    dynamic id, {
    String? rejectionReason,
  }) async {
    final res = await _api.post('/leave-requests/${id.toString()}/reject', {
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    });
    return res;
  }

  /// Bulk approve leave requests
  Future<Map<String, dynamic>> bulkApprove(List<dynamic> ids) async {
    final res = await _api.post('/leave-requests/bulk-approve', {'ids': ids});
    return res;
  }

  /// Bulk reject leave requests
  Future<Map<String, dynamic>> bulkReject(
    List<dynamic> ids, {
    String? rejectionReason,
  }) async {
    final res = await _api.post('/leave-requests/bulk-reject', {
      'ids': ids,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    });
    return res;
  }

  /// Update leave request
  Future<Map<String, dynamic>> update(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    final res = await _api.put('/leave-requests/${id.toString()}', data);
    return res;
  }

  /// Delete leave request
  Future<void> delete(dynamic id) async {
    await _api.delete('/leave-requests/${id.toString()}');
  }

  /// Upload attachment to leave request
  Future<Map<String, dynamic>> uploadAttachment(
    int leaveRequestId,
    File file,
  ) async {
    final res = await _api.postMultipart(
      '/leave-requests/$leaveRequestId/upload-attachment',
      {},
      'attachment',
      file.path,
    );
    return res;
  }
}
