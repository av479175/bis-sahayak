enum MessageSender { user, ai }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final bool isLoading;
  final List<String> sources; // raw source strings from /chat, AI messages only

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isLoading = false,
    this.sources = const [],
  });

  ChatMessage copyWith({String? text, bool? isLoading, List<String>? sources}) {
    return ChatMessage(
      id: id,
      sender: sender,
      text: text ?? this.text,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
      sources: sources ?? this.sources,
    );
  }
}
