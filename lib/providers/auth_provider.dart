import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import 'network_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider));
});

/// Owns only the LOGGED-IN SESSION: null = logged out, data = logged in.
/// Register/verify don't produce a session (no token returned), so they're
/// exposed as plain pass-through methods below that don't touch `state` —
/// the Auth screen manages their loading/error locally instead.
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (token == null) return null;
    try {
      return await ref.read(authRepositoryProvider).getMe();
    } catch (_) {
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email: email, password: password),
    );
  }

  Future<void> register({required String username, required String email, required String password}) {
    return ref.read(authRepositoryProvider).register(username: username, email: email, password: password);
  }

  Future<void> verifyEmail({required String email, required String otp}) {
    return ref.read(authRepositoryProvider).verifyEmail(email: email, otp: otp);
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }

  Future<void> logoutAll() async {
    try {
      await ref.read(authRepositoryProvider).logoutAll();
    } catch (_) {}
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }

  Future<void> forceLogout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);
