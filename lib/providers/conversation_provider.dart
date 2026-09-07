import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../repositories/conversation_repository.dart';
import 'network_providers.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository(ref.watch(dioProvider));
});

final conversationsListProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.watch(conversationRepositoryProvider).getConversations();
});

final conversationMessagesProvider = FutureProvider.family<List<ConversationMessage>, String>((ref, conversationId) {
  return ref.watch(conversationRepositoryProvider).getMessages(conversationId);
});
