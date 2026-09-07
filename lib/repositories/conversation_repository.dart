import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/conversation.dart';
import '../network/api_exception.dart';

class ConversationRepository {
  final Dio _dio;
  const ConversationRepository(this._dio);

  Future<Conversation> createConversation() async {
    try {
      final res = await _dio.post(ApiConfig.conversations);
      return Conversation.fromJson(_unwrapItem(res.data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final res = await _dio.get(ApiConfig.conversations);
      return _unwrapList(res.data).map(Conversation.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<ConversationMessage>> getMessages(String conversationId) async {
    try {
      final res = await _dio.get(ApiConfig.conversationMessages(conversationId));
      return _unwrapList(res.data).map(ConversationMessage.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Map<String, dynamic> _unwrapItem(dynamic data) {
    if (data is Map) {
      final inner = data['conversation'] ?? data['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  List<Map<String, dynamic>> _unwrapList(dynamic data) {
    if (data is List) return data.map((e) => Map<String, dynamic>.from(e)).toList();
    if (data is Map) {
      final inner = data['conversations'] ?? data['messages'] ?? data['data'];
      if (inner is List) return inner.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}
