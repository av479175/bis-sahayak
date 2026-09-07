import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/conversation_provider.dart';
import '../../widgets/async_view.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Conversations')),
      body: SafeArea(
        child: conversationsAsync.when(
          loading: () => const AsyncLoadingView(label: 'Loading your conversations...'),
          error: (err, st) => AsyncErrorView(onRetry: () => ref.invalidate(conversationsListProvider)),
          data: (conversations) {
            if (conversations.isEmpty) {
              return Center(child: Text('No saved conversations yet', style: TextStyle(color: Colors.grey.shade600)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: conversations.length,
              itemBuilder: (context, i) {
                final c = conversations[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(DateFormat('MMM d, h:mm a').format(c.updatedAt)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/conversation/${c.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
