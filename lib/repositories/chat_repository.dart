import '../data/mock_chat_data.dart';

/// Simulates the RAG/LLM backend endpoint. Swap sendMessage's body for a
/// real dio POST to your teammates' /chat endpoint once it's ready — keep
/// the same return contract (markdown string with `bis://` citation links)
/// so nothing above this layer needs to change.
class ChatRepository {
  const ChatRepository();

  Future<String> sendMessage(String query) {
    return MockChatData.generateResponse(query);
  }

  String get welcomeMessage => MockChatData.welcomeMessage;
}
