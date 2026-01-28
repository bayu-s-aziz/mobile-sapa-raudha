import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'local_storage_service.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';
import 'package:sapa_raudha/app/routes/app_pages.dart';

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

  LocalStorageService? _storage;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<LocalStorageService>()) {
      _storage = Get.find<LocalStorageService>();
    } else {
      _storage = null;
      developer.log(
        '[API] LocalStorageService not registered yet',
        name: 'ApiClient',
      );
    }
  }

  LocalStorageService? get _storageInstance {
    if (Get.isRegistered<LocalStorageService>()) {
      return Get.find<LocalStorageService>();
    }
    return _storage;
  }

  bool _handlingUnauthorized = false;

  /// Centralized handler for unauthorized (401) responses.
  /// This clears stored auth data and navigates the user back to login.
  /// Idempoten: subsequent calls while handling are ignored to avoid
  /// repeated snackbars/navigation when many requests fail at once.
  Future<void> handleUnauthorized({String? reason}) async {
    if (_handlingUnauthorized) {
      developer.log(
        '[API] handleUnauthorized already in progress',
        name: 'ApiClient',
      );
      return;
    }
    _handlingUnauthorized = true;

    developer.log(
      '[API] Handling unauthorized: ${reason ?? 'unknown'}',
      name: 'ApiClient',
    );

    try {
      final storage = _storageInstance;
      await storage?.remove('auth_token');
      await storage?.remove('user');
      developer.log('[API] Cleared auth storage', name: 'ApiClient');
    } catch (_) {}

    // Show user-friendly message and redirect to login (only if context available)
    try {
      if (Get.context != null) {
        SnackbarHelper.showError('Sesi berakhir. Silakan login kembali.');
      }
    } catch (_) {}

    try {
      if (Get.context != null) {
        Get.offAllNamed(Routes.login);
      }
    } catch (_) {}

    _handlingUnauthorized = false;
  }

  Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (needsAuth) {
      final storage = _storageInstance;
      final token = storage?.read<String>('auth_token');
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

    // Centralized unauthorized handling
    if (res.statusCode == 401) {
      await handleUnauthorized();
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

    if (res.statusCode == 401) {
      await handleUnauthorized();
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

      if (res.statusCode == 401) {
        await handleUnauthorized();
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

    if (res.statusCode == 401) {
      await handleUnauthorized();
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

    if (res.statusCode == 401) {
      await handleUnauthorized();
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
    final token = _storageInstance?.read<String>('auth_token');
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

    if (response.statusCode == 401) {
      await handleUnauthorized();
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
    final token = _storageInstance?.read<String>('auth_token');
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

    if (response.statusCode == 401) {
      await handleUnauthorized();
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

  /// Build a full absolute URL from a possibly-relative path returned by the API.
  /// If [rawPath] is already an absolute URL (starts with http/https), it will
  /// be returned unchanged. Otherwise it is prefixed with `baseUrl`.
  String buildFullUrl(String rawPath) {
    if (rawPath.startsWith('http')) return rawPath;
    var base = baseUrl;

    // If the returned path points to public storage (e.g. storage, uploads, files, photos)
    // and the API base URL includes '/api', prefer using the site root instead of
    // the API prefix so the resulting URL points to the correct public path.
    final normalizedPath = rawPath.startsWith('/') ? rawPath : '/$rawPath';

    // Detect public storage-like paths which are served under /storage or /public
    final isPublicResource =
        normalizedPath.startsWith('/storage') ||
        normalizedPath.startsWith('/uploads') ||
        normalizedPath.startsWith('/files') ||
        normalizedPath.startsWith('/photos') ||
        // Also handle raw paths like 'photos/...'
        normalizedPath.startsWith('/photos');

    if (isPublicResource && base.endsWith('/api')) {
      base = base.substring(0, base.length - 4); // remove trailing '/api'
    }

    // Special-case: some APIs return paths like 'photos/..' (without leading slash)
    // and the public file-serving path on the site is under '/storage/photos/...'
    if (!normalizedPath.startsWith('/storage') &&
        (normalizedPath.contains('/photos') ||
            normalizedPath.startsWith('/photos'))) {
      final photosPath = normalizedPath.startsWith('/photos')
          ? '/storage$normalizedPath'
          : '/storage/$rawPath'.replaceAll('//', '/');
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      return '$base$photosPath';
    }

    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base$normalizedPath';
  }
}
