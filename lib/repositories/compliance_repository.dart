import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/compliance_models.dart';
import '../network/api_exception.dart';

class ComplianceRepository {
  final Dio _dio;

  const ComplianceRepository(this._dio);

  Future<List<ComplianceProduct>> getComplianceProducts() async {
    try {
      final res = await _dio.get(ApiConfig.complianceProducts);
      final data = res.data;
      if (data is List) {
        return data.map((e) => ComplianceProduct.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      if (data is Map) {
        final list = data['products'] ?? data['data'];
        if (list is List) {
          return list.map((e) => ComplianceProduct.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ComplianceProductJourney> getComplianceJourney(String productId) async {
    try {
      final res = await _dio.get(ApiConfig.complianceJourney(productId));
      final map = Map<String, dynamic>.from(res.data as Map);
      return ComplianceProductJourney.fromJson(map);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
