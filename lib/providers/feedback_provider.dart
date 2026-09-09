import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/feedback_repository.dart';
import 'network_providers.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(dioProvider));
});

final feedbackNotifierProvider = StateNotifierProvider<FeedbackNotifier, AsyncValue<void>>((ref) {
  return FeedbackNotifier(ref.watch(feedbackRepositoryProvider));
});

class FeedbackNotifier extends StateNotifier<AsyncValue<void>> {
  final FeedbackRepository _repository;

  FeedbackNotifier(this._repository) : super(const AsyncData(null));

  Future<bool> sendFeedback({
    required String rating, // 'helpful' | 'not_helpful'
    String? messageId,
    String? question,
    String? answer,
    String? comments,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.sendFeedback(
        rating: rating,
        messageId: messageId,
        question: question,
        answer: answer,
        comments: comments,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
