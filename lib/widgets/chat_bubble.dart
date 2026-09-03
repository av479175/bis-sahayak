import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/chat_message.dart';
import '../theme/app_theme.dart';
import 'citation_chip.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String standardId) onCitationTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onCitationTap,
  });

  bool get _isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!_isUser) _AiAvatar(),
          if (!_isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _isUser ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_isUser ? 16 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 16),
                ),
                border: _isUser ? null : Border.all(color: Colors.grey.shade200),
              ),
              child: message.isLoading ? const _TypingIndicator() : _buildContent(context),
            ),
          ),
          if (_isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isUser) {
      return Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.4),
      );
    }

    // AI messages render as markdown, with `bis://` links swapped for
    // tappable CitationChip widgets via CitationLinkBuilder.
    return MarkdownBody(
      data: message.text,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null && href.startsWith('bis://')) {
          onCitationTap(href.substring('bis://'.length));
        }
      },
      builders: {
        'a': CitationLinkBuilder(onCitationTap: onCitationTap),
      },
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 14.5, height: 1.45, color: Colors.black87),
        strong: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        listBullet: const TextStyle(fontSize: 14.5, color: Colors.black87),
        h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        h2: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
        code: TextStyle(
          backgroundColor: Colors.grey.shade100,
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 14,
      backgroundColor: AppTheme.primaryBlue,
      child: Icon(Icons.auto_awesome, size: 14, color: Colors.white),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 36,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Dot(delayMs: 0),
          _Dot(delayMs: 150),
          _Dot(delayMs: 300),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delayMs;
  const _Dot({required this.delayMs});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
      ),
    );
  }
}
