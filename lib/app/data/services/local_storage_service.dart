import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  final GetStorage _box = GetStorage();

  Future<void> saveToken(String token) => _box.write('token', token);
  String? get token => _box.read<String>('token');

  Future<void> clear() => _box.erase();
}
