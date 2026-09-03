import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import 'repository_providers.dart';

const _uuid = Uuid();

/// Owns the chat transcript. Exposes AsyncValue<List<ChatMessage>> so the UI
/// shows a full loading/error state only on first load (session init) —
/// individual message sends instead update state optimistically and use the
/// per-message `isLoading` flag, so the transcript never blanks out mid-chat.
class ChatController extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() async {
    final repo = ref.watch(chatRepositoryProvider);
    return [
      ChatMessage(
        id: _uuid.v4(),
        sender: MessageSender.ai,
        text: repo.welcomeMessage,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = state.valueOrNull ?? [];
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.user,
      text: trimmed,
      timestamp: DateTime.now(),
    );
    final loadingMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.ai,
      text: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = AsyncData([...current, userMessage, loadingMessage]);

    try {
      final repo = ref.read(chatRepositoryProvider);
      final response = await repo.sendMessage(trimmed);

      final updated = [...state.valueOrNull ?? []];
      final idx = updated.indexWhere((m) => m.id == loadingMessage.id);
      if (idx != -1) {
        updated[idx] = loadingMessage.copyWith(text: response, isLoading: false);
      }
      state = AsyncData(updated);
    } catch (e) {
      final updated = [...state.valueOrNull ?? []];
      final idx = updated.indexWhere((m) => m.id == loadingMessage.id);
      if (idx != -1) {
        updated[idx] = loadingMessage.copyWith(
          text: "Sorry, I couldn't process that. Please try again.",
          isLoading: false,
        );
      }
      state = AsyncData(updated);
    }
  }

  void resetChat() => ref.invalidateSelf();
}

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);

/// True while a message is in flight — drives the input bar's disabled state.
final isChatSendingProvider = Provider<bool>((ref) {
  final messages = ref.watch(chatControllerProvider).valueOrNull ?? [];
  return messages.isNotEmpty && messages.last.isLoading;
});
