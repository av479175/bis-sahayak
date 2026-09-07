import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/verification_models.dart';
import '../network/api_exception.dart';

class VerificationRepository {
  final Dio _dio;

  const VerificationRepository(this._dio);

  Future<HuidResult> verifyHuid(String huid) async {
    try {
      final res = await _dio.post(ApiConfig.verifyHuid, data: {
        'huid': huid.trim(),
      });
      final map = Map<String, dynamic>.from(res.data as Map);
      return HuidResult.fromJson(map);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LicenseResult> verifyLicense(String licenseNumber) async {
    try {
      final res = await _dio.post(ApiConfig.verifyLicense, data: {
        'license_number': licenseNumber.trim(),
      });
      final map = Map<String, dynamic>.from(res.data as Map);
      return LicenseResult.fromJson(map);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
