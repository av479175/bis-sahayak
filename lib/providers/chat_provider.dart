import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../network/api_exception.dart';
import 'conversation_provider.dart';
import 'repository_providers.dart';

const _uuid = Uuid();

/// Follows the documented flow: on open, GET /conversations — reuse the
/// most recent one and load its history if it exists, else create one via
/// POST /conversations. Every sendMessage() call hits real POST /chat.
class ChatController extends AsyncNotifier<List<ChatMessage>> {
  String? _conversationId;
  String? get conversationId => _conversationId;

  @override
  Future<List<ChatMessage>> build() async {
    try {
      final convoRepo = ref.read(conversationRepositoryProvider);
      final existing = await convoRepo.getConversations();

      if (existing.isNotEmpty) {
        _conversationId = existing.first.id;
        final history = await convoRepo.getMessages(_conversationId!);
        if (history.isNotEmpty) {
          return history.map(_toChatMessage).toList();
        }
      } else {
        final created = await convoRepo.createConversation();
        _conversationId = created.id;
        ref.invalidate(conversationsListProvider);
      }
    } catch (_) {
      // Offline / not logged in — show welcome message
    }
    return [_welcomeMessage()];
  }

  ChatMessage _welcomeMessage() => ChatMessage(
        id: _uuid.v4(),
        sender: MessageSender.ai,
        text: "Namaste! I'm BIS Sahayak — ask me about product certification, "
            "hallmarking, or any Indian Standard.",
        timestamp: DateTime.now(),
      );

  ChatMessage _toChatMessage(ConversationMessage m) => ChatMessage(
        id: m.id.isNotEmpty ? m.id : _uuid.v4(),
        sender: m.role == 'user' ? MessageSender.user : MessageSender.ai,
        text: m.content,
        timestamp: m.createdAt ?? DateTime.now(),
      );

  Future<void> startNewChat() async {
    state = const AsyncLoading();
    try {
      final created = await ref.read(conversationRepositoryProvider).createConversation();
      _conversationId = created.id;
      ref.invalidate(conversationsListProvider);
      state = AsyncData([_welcomeMessage()]);
    } catch (_) {
      _conversationId = null;
      state = AsyncData([_welcomeMessage()]);
    }
  }

  Future<void> loadConversation(String id) async {
    _conversationId = id;
    state = const AsyncLoading();
    try {
      final history = await ref.read(conversationRepositoryProvider).getMessages(id);
      if (history.isNotEmpty) {
        state = AsyncData(history.map(_toChatMessage).toList());
      } else {
        state = AsyncData([_welcomeMessage()]);
      }
    } catch (_) {
      state = AsyncData([_welcomeMessage()]);
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _conversationId ??= await _ensureConversation();
    final current = state.valueOrNull ?? [];

    if (_conversationId == null) {
      state = AsyncData([
        ...current,
        ChatMessage(id: _uuid.v4(), sender: MessageSender.user, text: trimmed, timestamp: DateTime.now()),
        ChatMessage(
          id: _uuid.v4(),
          sender: MessageSender.ai,
          text: "I couldn't start a conversation. Please make sure you're logged in and try again.",
          timestamp: DateTime.now(),
        ),
      ]);
      return;
    }

    final userMessage = ChatMessage(id: _uuid.v4(), sender: MessageSender.user, text: trimmed, timestamp: DateTime.now());
    final loadingMessage = ChatMessage(id: _uuid.v4(), sender: MessageSender.ai, text: '', timestamp: DateTime.now(), isLoading: true);
    state = AsyncData([...current, userMessage, loadingMessage]);

    try {
      final reply = await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: _conversationId!,
            question: trimmed,
          );
      final updated = <ChatMessage>[...state.valueOrNull ?? []];
      final idx = updated.indexWhere((m) => m.id == loadingMessage.id);
      if (idx != -1) {
        updated[idx] = loadingMessage.copyWith(text: reply.answer, isLoading: false, sources: reply.sources);
      }
      state = AsyncData(updated);
      ref.invalidate(conversationsListProvider);
    } catch (e) {
      final updated = <ChatMessage>[...state.valueOrNull ?? []];
      final idx = updated.indexWhere((m) => m.id == loadingMessage.id);
      if (idx != -1) {
        updated[idx] = loadingMessage.copyWith(
          text: e is ApiException ? e.message : "Sorry, I couldn't process that. Please try again.",
          isLoading: false,
        );
      }
      state = AsyncData(updated);
    }
  }

  Future<String?> _ensureConversation() async {
    try {
      final created = await ref.read(conversationRepositoryProvider).createConversation();
      ref.invalidate(conversationsListProvider);
      return created.id;
    } catch (_) {
      return null;
    }
  }

  void resetChat() {
    startNewChat();
  }
}

final chatControllerProvider = AsyncNotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);

final isChatSendingProvider = Provider<bool>((ref) {
  final messages = ref.watch(chatControllerProvider).valueOrNull ?? [];
  return messages.isNotEmpty && messages.last.isLoading;
});
