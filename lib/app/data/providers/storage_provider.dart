import 'package:get_storage/get_storage.dart';

class StorageProvider {
  late final GetStorage _box;

  Future<void> init() async {
    _box = GetStorage();
    await _box.erase();
  }

  // Token management
  void setToken(String token) => _box.write('auth_token', token);
  String? getToken() => _box.read('auth_token');
  void removeToken() => _box.remove('auth_token');

  // User data
  void setUser(Map<String, dynamic> user) => _box.write('user', user);
  Map<String, dynamic>? getUser() {
    final user = _box.read('user');
    return user is Map<String, dynamic> ? user : null;
  }

  void removeUser() => _box.remove('user');

  // Other helpers
  void setString(String key, String value) => _box.write(key, value);
  String? getString(String key) => _box.read(key);

  void setBool(String key, bool value) => _box.write(key, value);
  bool? getBool(String key) => _box.read(key);

  void remove(String key) => _box.remove(key);
  void clear() => _box.erase();
}
