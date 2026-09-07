import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'token_storage.dart';

const String kApiBaseUrl = 'https://backend-fkpu.onrender.com';

/// Endpoints that must NOT get an Authorization header attached.
const _publicPaths = [
  '/api/auth/register',
  '/api/auth/login',
  '/api/auth/refresh-token',
  '/api/auth/verify-email',
];

/// Central Dio instance. [onSessionExpired] fires when a 401 survives a
/// refresh attempt — wired to authController.forceLogout() so the app
/// bounces back to the Auth screen instead of silently failing requests.
class DioClient {
  DioClient({required this.onSessionExpired}) {
    _dio = Dio(BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(CookieManager(CookieJar()));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isPublic = _publicPaths.any((p) => options.path.contains(p));
        if (!isPublic) {
          final token = await TokenStorage.instance.getAccessToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isAuthCall = _publicPaths.any((p) => error.requestOptions.path.contains(p));
        final is401 = error.response?.statusCode == 401;

        if (is401 && !isAuthCall && error.requestOptions.extra['retried'] != true) {
          try {
            final newToken = await _refreshAccessToken();
            if (newToken != null) {
              final retryOptions = error.requestOptions..extra['retried'] = true;
              retryOptions.headers['Authorization'] = 'Bearer $newToken';
              return handler.resolve(await _dio.fetch(retryOptions));
            }
          } catch (_) {
            // falls through to session-expired handling below
          }
          await TokenStorage.instance.clear();
          onSessionExpired();
        }
        handler.next(error);
      },
    ));
  }

  late final Dio _dio;
  final void Function() onSessionExpired;
  Dio get dio => _dio;

  Future<String?> _refreshAccessToken() async {
    try {
      final response = await _dio.get('/api/auth/refresh-token');
      final body = response.data;
      final Map<String, dynamic> data = (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>)
          ? body['data'] as Map<String, dynamic>
          : (body is Map<String, dynamic> ? body : {});
      final newToken = data['accessToken'] ?? data['token'] ?? data['access_token'];
      if (newToken is String) {
        await TokenStorage.instance.saveAccessToken(newToken);
        return newToken;
      }
    } catch (_) {}
    return null;
  }
}
