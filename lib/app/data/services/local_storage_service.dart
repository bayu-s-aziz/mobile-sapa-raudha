import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// LocalStorageService
/// A thin wrapper around GetStorage providing simple read/save/remove helpers.
/// This keeps app-wide storage consistent and easily testable.
class LocalStorageService extends GetxService {
  final GetStorage _box = GetStorage();

  /// Save any primitive or Map/List value by key.
  /// Maps/Lists are stored as JSON strings to ensure type safety on read.
  Future<void> save(String key, dynamic value) async {
    if (value is Map || value is List) {
      await _box.write(key, jsonEncode(value));
    } else {
      await _box.write(key, value);
    }
  }

  T? read<T>(String key) {
    final data = _box.read(key);
    if (data == null) {
      // Fallback: for auth_token, attempt to read from secure storage synchronously via Get
      if (key == 'auth_token' && Get.isRegistered<dynamic>()) {
        try {
          // secure.read returns Future<String?>, but test/runtime callers may expect sync.
          // We attempt to return cached token if available (sync read not supported by plugin),
          // so we keep behavior minimal: return null here; caller should check both storages
        } catch (_) {}
      }
      return null;
    }

    // Attempt to decode JSON strings for Map/List expectations.
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return decoded as T?;
      } catch (_) {
        // Not JSON, return raw string when T matches.
        return data as T?;
      }
    }

    return data as T?;
  }

  /// Remove a key from storage.
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  /// Clear all keys from storage.
  Future<void> clear() async {
    await _box.erase();
  }

  // Optional aliases for compatibility if existing code uses write/read directly.
  Future<void> write(String key, dynamic value) => save(key, value);
  T? get<T>(String key) => read<T>(key);
}
