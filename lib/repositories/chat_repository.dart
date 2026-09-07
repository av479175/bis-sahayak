import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/chat_reply.dart';
import '../network/api_exception.dart';

class ChatRepository {
  final Dio _dio;
  const ChatRepository(this._dio);

  Future<ChatReply> sendMessage({
    required String conversationId,
    required String question,
  }) async {
    try {
      final res = await _dio.post(ApiConfig.chat, data: {
        'conversationId': conversationId,
        'question': question,
      });
      final map = Map<String, dynamic>.from(res.data as Map);
      final answer = (map['answer'] ?? '').toString();
      final sources = map['sources'] is List
          ? (map['sources'] as List).map((e) => e.toString()).toList()
          : <String>[];
      return ChatReply(answer: answer, sources: sources);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
