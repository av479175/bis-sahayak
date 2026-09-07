import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        'Server is taking longer to respond. Please try again in a moment.',
      );
    }

    if (e.error != null && e.error.toString().contains('Failed host lookup')) {
      return const ApiException(
        'No internet connection or unable to reach backend server. Please check your network connection.',
      );
    }

    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['msg'] ?? data['details'];
      if (msg != null && msg.toString().isNotEmpty) {
        return ApiException(msg.toString(), statusCode: statusCode);
      }
    } else if (data is String && data.isNotEmpty && !data.startsWith('<!DOCTYPE')) {
      return ApiException(data, statusCode: statusCode);
    }

    switch (statusCode) {
      case 400:
        return const ApiException('Invalid request. Please check your inputs.', statusCode: 400);
      case 401:
        return const ApiException('Unauthorized. Please log in again.', statusCode: 401);
      case 403:
        return const ApiException('Access denied.', statusCode: 403);
      case 404:
        return const ApiException('Requested resource not found.', statusCode: 404);
      case 409:
        return const ApiException('Resource already exists.', statusCode: 409);
      case 500:
        return const ApiException('Server error (500). Please try again later.', statusCode: 500);
      default:
        return ApiException(
          e.message ?? 'An unexpected error occurred. Please try again.',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
