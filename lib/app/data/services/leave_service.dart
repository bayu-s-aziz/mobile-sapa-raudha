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

  Future<Map<String, dynamic>> submitLeave({
    required String studentNisn,
    required String requestDate,
    required String reason,
    File? attachment,
  }) async {
    if (attachment != null) {
      return _api.postMultipart(
        '/leave-requests',
        {
          'student_nisn': studentNisn,
          'request_date': requestDate,
          'reason': reason,
        },
        'attachment',
        attachment.path,
      );
    }
    return _api.post('/leave-requests', {
      'student_nisn': studentNisn,
      'request_date': requestDate,
      'reason': reason,
    }, needsAuth: true);
  }

  Future<List<Map<String, dynamic>>> getLeaveRequests({
    String? status,
    String? studentNisn,
  }) async {
    final query = <String, String>{
      if (status != null) 'status': status,
      if (studentNisn != null) 'student_nisn': studentNisn,
    };
    final q = query.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _api.get('/leave-requests${q.isEmpty ? '' : '?$q'}');
    return List<Map<String, dynamic>>.from(res['leave_requests'] ?? []);
  }

  Future<void> approve(String id, {String? notes}) async {
    await _api.put('/leave-requests/$id/approve', {
      'review_notes': notes ?? 'Disetujui',
    });
  }

  Future<void> reject(String id, {String? notes}) async {
    await _api.put('/leave-requests/$id/reject', {
      'review_notes': notes ?? 'Ditolak',
    });
  }
}
