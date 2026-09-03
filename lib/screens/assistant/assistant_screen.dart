import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart' show Uuid;

import '../../data/mock_chat_data.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chat_bubble.dart';

/// NOTE: chat state is local (setState) for now, purely to keep this step
/// self-contained. Step 6 lifts this into a ChatController backed by
/// Riverpod's AsyncNotifier, exposing loading/error states the same way
/// `_isSending` does here — the widget tree below barely changes.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  static const _uuid = Uuid();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.ai,
      text: MockChatData.welcomeMessage,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.user,
      text: text,
      timestamp: DateTime.now(),
    );
    final loadingMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.ai,
      text: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() {
      _messages.addAll([userMessage, loadingMessage]);
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    final response = await MockChatData.generateResponse(text);

    setState(() {
      final idx = _messages.indexWhere((m) => m.id == loadingMessage.id);
      _messages[idx] = loadingMessage.copyWith(text: response, isLoading: false);
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _onCitationTap(String standardId) {
    context.push('/standard-details/$standardId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BIS Sahayak Assistant'),
        actions: [
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              setState(() {
                _messages
                  ..clear()
                  ..add(ChatMessage(
                    id: _uuid.v4(),
                    sender: MessageSender.ai,
                    text: MockChatData.welcomeMessage,
                    timestamp: DateTime.now(),
                  ));
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                itemCount: _messages.length,
                itemBuilder: (context, i) => ChatBubble(
                  message: _messages[i],
                  onCitationTap: _onCitationTap,
                ),
              ),
            ),
            _ChatInputBar(
              controller: _controller,
              enabled: !_isSending,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Ask about a standard, product, or certification...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color(0xFFF3F6FA),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: enabled ? AppTheme.primaryBlue : Colors.grey.shade300,
            child: IconButton(
              icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
              onPressed: enabled ? onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}
