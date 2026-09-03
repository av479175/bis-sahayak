import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/chat_repository.dart';
import '../repositories/standards_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => const ChatRepository());
final standardsRepositoryProvider = Provider<StandardsRepository>((ref) => const StandardsRepository());
