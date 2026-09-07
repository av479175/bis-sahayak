import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/chat_repository.dart';
import '../repositories/standards_repository.dart';
import 'network_providers.dart';

// Chat now hits the real backend.
final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository(ref.watch(dioProvider)));

// Standards/discovery stay mocked — not documented yet.
final standardsRepositoryProvider = Provider<StandardsRepository>((ref) => const StandardsRepository());
