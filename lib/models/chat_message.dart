enum MessageSender { user, ai }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text; // markdown for AI messages, plain text for user messages
  final DateTime timestamp;
  final bool isLoading; // true = shows a "thinking" bubble instead of text

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({String? text, bool? isLoading}) {
    return ChatMessage(
      id: id,
      sender: sender,
      text: text ?? this.text,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
