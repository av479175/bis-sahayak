import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_message.dart';
import '../providers/feedback_provider.dart';
import '../theme/app_theme.dart';
import 'citation_chip.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String> onCitationTap;

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
        mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isUser ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: _isUser ? const Radius.circular(0) : null,
                  bottomLeft: !_isUser ? const Radius.circular(0) : null,
                ),
                border: _isUser ? null : Border.all(color: Colors.grey.shade200),
                boxShadow: _isUser
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: message.isLoading
                  ? const _TypingIndicator()
                  : _buildContent(context),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownBody(
          data: message.text,
          selectable: true,
          shrinkWrap: true,
          onTapLink: (text, href, title) {
            if (href != null && href.startsWith('bis://')) {
              onCitationTap(href.substring('bis://'.length));
            }
          },
          builders: {'a': CitationLinkBuilder(onCitationTap: onCitationTap)},
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 14.5, height: 1.45, color: Colors.black87),
            strong: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
            listBullet: const TextStyle(fontSize: 14.5, color: Colors.black87),
            h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            h2: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
            code: TextStyle(
              backgroundColor: Colors.grey.shade100,
              fontSize: 12.5,
              fontFamily: 'monospace',
            ),
            codeblockPadding: const EdgeInsets.all(8),
            codeblockDecoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (message.sources.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: message.sources.map((s) => _SourceChip(source: s)).toList(),
          ),
        ],
        _FeedbackButtons(message: message),
      ],
    );
  }
}

class _FeedbackButtons extends ConsumerStatefulWidget {
  final ChatMessage message;

  const _FeedbackButtons({required this.message});

  @override
  ConsumerState<_FeedbackButtons> createState() => _FeedbackButtonsState();
}

class _FeedbackButtonsState extends ConsumerState<_FeedbackButtons> {
  String? _selectedRating;

  void _onFeedback(String rating) async {
    setState(() => _selectedRating = rating);
    final success = await ref.read(feedbackNotifierProvider.notifier).sendFeedback(
          rating: rating,
          messageId: widget.message.id,
          answer: widget.message.text,
        );
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback recorded. Thank you!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Was this helpful?',
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _onFeedback('helpful'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                _selectedRating == 'helpful' ? Icons.thumb_up : Icons.thumb_up_outlined,
                size: 14,
                color: _selectedRating == 'helpful' ? AppTheme.emeraldGreen : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _onFeedback('not_helpful'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                _selectedRating == 'not_helpful' ? Icons.thumb_down : Icons.thumb_down_outlined,
                size: 14,
                color: _selectedRating == 'not_helpful' ? Colors.red.shade700 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String source;
  const _SourceChip({required this.source});

  bool get _isUrl => source.startsWith('http://') || source.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: _isUrl ? () => launchUrl(Uri.parse(source), mode: LaunchMode.externalApplication) : null,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_isUrl ? Icons.open_in_new : Icons.description_outlined, size: 11, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                source,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CitationLinkBuilder extends MarkdownElementBuilder {
  final ValueChanged<String> onCitationTap;

  CitationLinkBuilder({required this.onCitationTap});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final href = element.attributes['href'] ?? '';
    if (!href.startsWith('bis://')) return null;

    final standardId = href.substring('bis://'.length);
    final text = element.textContent;

    return CitationChip(
      label: text,
      standardId: standardId,
      onTap: () => onCitationTap(standardId),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = (_controller.value + (i * 0.2)) % 1.0;
              final opacity = (value - 0.5).abs() * 2;
              return Opacity(
                opacity: 0.3 + (opacity * 0.7),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}


