import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String tokenKey = 'aquatrack_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: tokenKey);
  }
}
