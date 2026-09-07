import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../network/auth_interceptor.dart';
import '../network/token_storage.dart';
import 'auth_provider.dart';

/// Overridden in main() — see main.dart. On web this is a plain in-memory
/// CookieJar and is intentionally unused (see note in dioProvider below).
final cookieJarProvider = Provider<CookieJar>((ref) {
  throw UnimplementedError('cookieJarProvider must be overridden in main()');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

Dio _buildBaseDio() {
  return Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    // Render's free tier can take 30-60s to wake a sleeping instance —
    // 15s was too aggressive and made a cold backend look "broken".
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    // Explicit, rather than relying on Dio's default inference — the /chat
    // contract requires this exactly.
    contentType: Headers.jsonContentType,
    // Needed for the refresh-token/logout cookie to be sent cross-origin,
    // especially relevant on Flutter Web.
    extra: const {'withCredentials': true},
  ));
}

final _refreshDioProvider = Provider<Dio>((ref) {
  final dio = _buildBaseDio();
  if (!kIsWeb) {
    dio.interceptors.add(CookieManager(ref.watch(cookieJarProvider)));
  }
  return dio;
});

final dioProvider = Provider<Dio>((ref) {
  final dio = _buildBaseDio();

  // dio_cookie_manager / cookie_jar's file storage doesn't work on Flutter
  // Web — the browser manages cookies itself there. Adding it anyway is a
  // silent no-op at best; skip it explicitly instead of masking the issue.
  if (!kIsWeb) {
    dio.interceptors.add(CookieManager(ref.watch(cookieJarProvider)));
  }

  dio.interceptors.add(AuthInterceptor(
    refreshDio: ref.watch(_refreshDioProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    onSessionExpired: () => ref.read(authControllerProvider.notifier).forceLogout(),
  ));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrintSafe(obj.toString()),
    ));
  }

  return dio;
});

void debugPrintSafe(String message) {
  // ignore: avoid_print
  print('[dio] $message');
}

/// Fire-and-forget wake-up ping for Render's free tier. Call this from
/// main() before runApp — errors are swallowed since this is purely
/// best-effort warm-up, not a required call.
Future<void> warmUpBackend() async {
  try {
    await Dio().get(
      ApiConfig.healthCheckUrl,
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  } catch (_) {
    // ignored — this is just a best-effort cold-start warm-up
  }
}
