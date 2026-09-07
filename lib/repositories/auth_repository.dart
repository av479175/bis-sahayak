import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/app_user.dart';
import '../network/api_exception.dart';
import '../network/token_storage.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  const AuthRepository(this._dio, this._tokenStorage);

  /// Register does NOT log the user in — no accessToken is returned.
  /// The backend sends an OTP by email; call verifyEmail next.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(ApiConfig.register, data: {
        'username': username,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    try {
      await _dio.get(ApiConfig.verifyEmail, queryParameters: {
        'email': email,
        'otp': otp,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppUser> login({required String email, required String password}) async {
    try {
      final res = await _dio.post(ApiConfig.login, data: {
        'email': email,
        'password': password,
      });
      final map = Map<String, dynamic>.from(res.data as Map);
      final token = map['accessToken'];
      if (token is! String) {
        throw const ApiException('Login succeeded but no access token was returned.');
      }
      await _tokenStorage.saveAccessToken(token);
      return AppUser.fromJson(map);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppUser> getMe() async {
    try {
      final res = await _dio.get(ApiConfig.getMe);
      return AppUser.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } catch (_) {
      // Best-effort remote call — proceed with clearing token
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<void> logoutAll() async {
    try {
      await _dio.post(ApiConfig.logoutAll);
    } catch (_) {
      // Best-effort remote call — proceed with clearing token
    } finally {
      await _tokenStorage.clear();
    }
  }
}
