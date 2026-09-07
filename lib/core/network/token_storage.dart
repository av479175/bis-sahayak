import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted on-device storage for the access token. The refresh token is
/// expected to live in an httpOnly cookie the backend sets on login (see
/// DioClient's CookieManager) — we never touch it directly from Dart.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage();
  static const _accessTokenKey = 'bis_access_token';

  Future<void> saveAccessToken(String token) => _storage.write(key: _accessTokenKey, value: token);
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}
