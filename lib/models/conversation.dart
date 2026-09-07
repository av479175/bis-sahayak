class Conversation {
  final String id;
  final String title;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Untitled conversation').toString(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class ConversationMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime? createdAt;

  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    this.createdAt,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      role: (json['role'] ?? json['sender'] ?? 'assistant').toString(),
      content: (json['content'] ?? json['text'] ?? json['question'] ?? json['answer'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
