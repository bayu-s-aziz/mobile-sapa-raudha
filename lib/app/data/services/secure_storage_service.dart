import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> save(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _secure.read(key: key);
  }

  Future<void> remove(String key) async {
    await _secure.delete(key: key);
  }

  Future<void> clearAll() async {
    await _secure.deleteAll();
  }
}
