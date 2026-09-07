import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'token_storage.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final Dio refreshDio;
  final TokenStorage tokenStorage;
  final void Function() onSessionExpired;

  AuthInterceptor({
    required this.refreshDio,
    required this.tokenStorage,
    required this.onSessionExpired,
  });

  static const _noAuthHeaderPaths = [
    ApiConfig.login,
    ApiConfig.register,
    ApiConfig.refreshToken,
  ];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_noAuthHeaderPaths.any((p) => options.path.contains(p))) {
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthEndpoint = _noAuthHeaderPaths.any((p) => err.requestOptions.path.contains(p));

    if (isUnauthorized && !isAuthEndpoint) {
      try {
        // FIX: this is POST, not GET, per the real backend doc.
        final response = await refreshDio.post(ApiConfig.refreshToken);
        final newToken = _extractAccessToken(response.data);
        if (newToken != null) {
          await tokenStorage.saveAccessToken(newToken);
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          final cloned = await refreshDio.fetch(retryOptions);
          return handler.resolve(cloned);
        }
      } catch (_) {
        // refresh failed — session is genuinely over
      }
      await tokenStorage.clear();
      onSessionExpired();
    }

    handler.next(err);
  }

  String? _extractAccessToken(dynamic data) {
    if (data is Map && data['accessToken'] is String) return data['accessToken'] as String;
    return null;
  }
}
