import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage();

  static final TokenStorage instance = TokenStorage();
  final _storage = const FlutterSecureStorage();
  static const _accessTokenKey = 'bis_access_token';

  Future<void> saveAccessToken(String token) => _storage.write(key: _accessTokenKey, value: token);
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}
