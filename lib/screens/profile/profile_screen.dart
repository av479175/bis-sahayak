import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: userAsync.when(
          loading: () => const AsyncLoadingView(),
          error: (err, st) => AsyncErrorView(onRetry: () => ref.invalidate(authControllerProvider)),
          data: (user) {
            if (user == null) return const Center(child: Text('Not signed in'));
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, color: AppTheme.primaryBlue, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    user.username.isNotEmpty ? user.username : 'BIS Sahayak User',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!user.verified) ...[
                  const SizedBox(height: 8),
                  const Center(child: Chip(label: Text('Email not verified', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFFFF6E0))),
                ],
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log out'),
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_outlined, color: Colors.red),
                  title: const Text('Log out of all devices', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logoutAll();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
