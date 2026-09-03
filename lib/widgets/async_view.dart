import 'package:flutter/material.dart';

/// Shared loading state for any AsyncValue.when(loading: ...) across the app.
class AsyncLoadingView extends StatelessWidget {
  final String? label;
  const AsyncLoadingView({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.5),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          ],
        ],
      ),
    );
  }
}

/// Shared error state with retry, used for AsyncValue.when(error: ...).
class AsyncErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AsyncErrorView({
    super.key,
    this.message = 'Something went wrong. Please try again.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
