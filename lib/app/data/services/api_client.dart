import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'local_storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final dynamic body;
  final String message;

  ApiException(this.statusCode, this.body, [String? message])
    : message =
          message ??
          (body is Map && body['message'] != null
              ? body['message'].toString()
              : body?.toString() ?? 'HTTP $statusCode');

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient extends GetxService {
  final String baseUrl;
  ApiClient({required this.baseUrl});

  late final LocalStorageService _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<LocalStorageService>();
  }

  Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (needsAuth) {
      final token = _storage.read<String>('auth_token');
      developer.log('[API] Token from storage: $token', name: 'ApiClient');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        developer.log('[API] Authorization header set', name: 'ApiClient');
      } else {
        developer.log('[API] No token found', name: 'ApiClient');
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final headers = await _getHeaders(needsAuth: true);
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final parsed = _parseBody(res.body);
    throw ApiException(res.statusCode, parsed);
  }

  Future<List<dynamic>> getList(String path) async {
    final headers = await _getHeaders(needsAuth: true);
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      return decoded is List ? decoded : [];
    }
    final parsed = _parseBody(res.body);
    throw ApiException(res.statusCode, parsed);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool needsAuth = false,
  }) async {
    final headers = await _getHeaders(needsAuth: needsAuth);
    final url = '$baseUrl$path';
    developer.log('[API] POST $url', name: 'ApiClient');
    developer.log('[API] Body: ${jsonEncode(body)}', name: 'ApiClient');

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      developer.log(
        '[API] Response ${res.statusCode}: ${res.body}',
        name: 'ApiClient',
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      final parsed = _parseBody(res.body);
      throw ApiException(res.statusCode, parsed);
    } catch (e, st) {
      developer.log(
        '[API] Error: $e',
        name: 'ApiClient',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders(needsAuth: true);
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final parsed = _parseBody(res.body);
    throw ApiException(res.statusCode, parsed);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final headers = await _getHeaders(needsAuth: true);
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final parsed = _parseBody(res.body);
    throw ApiException(res.statusCode, parsed);
  }

  /// Upload file dengan multipart
  Future<Map<String, dynamic>> postMultipart(
    String path,
    Map<String, String> fields,
    String fileField,
    String filePath,
  ) async {
    final token = _storage.read<String>('auth_token');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['X-Requested-With'] = 'XMLHttpRequest';

    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final parsed = _parseBody(response.body);
    throw ApiException(response.statusCode, parsed);
  }

  /// Upload file dengan multipart menggunakan PUT
  Future<Map<String, dynamic>> putMultipart(
    String path,
    String fileField,
    String filePath,
  ) async {
    final token = _storage.read<String>('auth_token');
    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl$path'));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['X-Requested-With'] = 'XMLHttpRequest';

    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final parsed = _parseBody(response.body);
    throw ApiException(response.statusCode, parsed);
  }

  dynamic _parseBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
