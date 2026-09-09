import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../network/api_exception.dart';

class FeedbackRepository {
  final Dio _dio;

  const FeedbackRepository(this._dio);

  Future<void> sendFeedback({
    required String rating, // 'helpful' | 'not_helpful'
    String? messageId,
    String? question,
    String? answer,
    String? comments,
  }) async {
    try {
      await _dio.post(ApiConfig.feedback, data: {
        'rating': rating,
        'helpful': rating == 'helpful',
        if (messageId != null) 'messageId': messageId,
        if (question != null) 'question': question,
        if (answer != null) 'answer': answer,
        if (comments != null) 'comments': comments,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
