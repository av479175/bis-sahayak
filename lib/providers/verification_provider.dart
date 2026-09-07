import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/verification_models.dart';
import '../repositories/verification_repository.dart';
import 'network_providers.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(ref.watch(dioProvider));
});

final huidVerificationNotifierProvider = StateNotifierProvider<HuidVerificationNotifier, AsyncValue<HuidResult?>>((ref) {
  return HuidVerificationNotifier(ref.watch(verificationRepositoryProvider));
});

class HuidVerificationNotifier extends StateNotifier<AsyncValue<HuidResult?>> {
  final VerificationRepository _repository;

  HuidVerificationNotifier(this._repository) : super(const AsyncData(null));

  Future<void> verify(String huid) async {
    final trimmed = huid.trim();
    if (trimmed.isEmpty) {
      state = const AsyncError('Please enter a valid 6-digit HUID code (e.g. A8F2X9)', StackTrace.empty);
      return;
    }
    state = const AsyncLoading();
    try {
      final result = await _repository.verifyHuid(trimmed);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncData(null);
}

final licenseVerificationNotifierProvider = StateNotifierProvider<LicenseVerificationNotifier, AsyncValue<LicenseResult?>>((ref) {
  return LicenseVerificationNotifier(ref.watch(verificationRepositoryProvider));
});

class LicenseVerificationNotifier extends StateNotifier<AsyncValue<LicenseResult?>> {
  final VerificationRepository _repository;

  LicenseVerificationNotifier(this._repository) : super(const AsyncData(null));

  Future<void> verify(String licenseNumber) async {
    final trimmed = licenseNumber.trim();
    if (trimmed.isEmpty) {
      state = const AsyncError('Please enter a valid License Number (e.g. CM/L-1234567)', StackTrace.empty);
      return;
    }
    state = const AsyncLoading();
    try {
      final result = await _repository.verifyLicense(trimmed);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncData(null);
}
