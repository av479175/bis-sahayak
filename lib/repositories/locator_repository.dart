import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/bis_centre.dart';
import '../network/api_exception.dart';

class LocatorRepository {
  final Dio _dio;

  const LocatorRepository(this._dio);

  Future<GeocodeResult> geocode(String query) async {
    try {
      final res = await _dio.post(ApiConfig.geocode, data: {
        'location': query.trim(),
        'query': query.trim(),
      });
      return GeocodeResult.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<BisCentre>> getBisCentres({
    required double lat,
    required double lon,
    double radius = 25,
  }) async {
    try {
      final res = await _dio.get(ApiConfig.bisCentres, queryParameters: {
        'lat': lat,
        'lon': lon,
        'radius': radius,
      });
      final data = res.data;
      if (data is List) {
        return data.map((e) => BisCentre.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      if (data is Map) {
        final list = data['centres'] ?? data['data'] ?? data['results'];
        if (list is List) {
          return list.map((e) => BisCentre.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
