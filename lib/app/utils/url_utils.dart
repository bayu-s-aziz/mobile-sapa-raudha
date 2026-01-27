import 'package:get/get.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';

/// Utility to normalize possibly-relative URLs returned by the API.
///
/// Example: '/storage/avatars/1.jpg' -> 'https://api.example.com/storage/avatars/1.jpg'
class UrlUtils {
  static String? normalizeUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      if (raw.startsWith('http')) return raw;
      return Get.find<ApiClient>().buildFullUrl(raw);
    } catch (_) {
      // If ApiClient isn't available for any reason, return raw path.
      return raw;
    }
  }
}
