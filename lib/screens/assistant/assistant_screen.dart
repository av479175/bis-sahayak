import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/chat_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_view.dart';
import '../../widgets/chat_bubble.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  const AssistantScreen({super.key, this.conversationId});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatControllerProvider.notifier).loadConversation(widget.conversationId!);
      });
    }
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

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await ref.read(chatControllerProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _onCitationTap(String standardId) => context.push('/standard-details/$standardId');

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatControllerProvider);
    final isSending = ref.watch(isChatSendingProvider);
    final activeConvoId = ref.watch(chatControllerProvider.notifier).conversationId;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Chat history',
          icon: const Icon(Icons.history_outlined),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'BIS Sahayak Assistant',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              ref.read(chatControllerProvider.notifier).startNewChat();
            },
          ),
        ],
      ),
      drawer: _ChatHistoryDrawer(
        activeConversationId: activeConvoId,
        onSelectConversation: (id) {
          Navigator.of(context).pop(); // Close drawer
          ref.read(chatControllerProvider.notifier).loadConversation(id);
        },
        onNewChat: () {
          Navigator.of(context).pop(); // Close drawer
          ref.read(chatControllerProvider.notifier).startNewChat();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => const AsyncLoadingView(label: 'Loading conversation...'),
                error: (err, st) => AsyncErrorView(
                  onRetry: () => ref.invalidate(chatControllerProvider),
                ),
                data: (messages) {
                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => ChatBubble(
                      message: messages[i],
                      onCitationTap: _onCitationTap,
                    ),
                  );
                },
              ),
            ),
            _ChatInputBar(
              controller: _controller,
              enabled: !isSending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHistoryDrawer extends ConsumerWidget {
  final String? activeConversationId;
  final ValueChanged<String> onSelectConversation;
  final VoidCallback onNewChat;

  const _ChatHistoryDrawer({
    required this.activeConversationId,
    required this.onSelectConversation,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsListProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with New Chat button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'BIS Sahayak AI',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onNewChat,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Chat'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Conversations',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
              ),
            ),

            // History List
            Expanded(
              child: conversationsAsync.when(
                loading: () => const AsyncLoadingView(label: 'Loading history...'),
                error: (err, st) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Could not load history', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ),
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return Center(
                      child: Text('No previous conversations', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    );
                  }
                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, i) {
                      final c = conversations[i];
                      final isSelected = c.id == activeConversationId;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade600,
                        ),
                        title: Text(
                          c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, h:mm a').format(c.updatedAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        onTap: () => onSelectConversation(c.id),
                      );
                    },
                  );
                },
              ),
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
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Ask about standards, ISI mark, or HUID...',
                hintMaxLines: 1,
                hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
