import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/main_scaffold.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/assistant/assistant_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/standard_details/standard_details_screen.dart';
import '../screens/compliance_journey/compliance_journey_screen.dart';

/// MOCK auth state — swap for a real auth provider once the backend lands.
final isLoggedInProvider = StateProvider<bool>((ref) => false);

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/auth';
      if (!isLoggedIn && !loggingIn) return '/auth';
      if (isLoggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Persistent bottom nav bar — the 5 core tabs live inside this shell.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/assistant',
            builder: (context, state) => const AssistantScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Pushed full-screen routes — parentNavigatorKey pins them to the ROOT
      // navigator, so they cover the bottom nav bar instead of living inside it.
      GoRoute(
        path: '/standard-details/:standardId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['standardId']!;
          return StandardDetailsScreen(standardId: id);
        },
      ),
      GoRoute(
        path: '/compliance-journey/:categoryId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['categoryId']!;
          return ComplianceJourneyScreen(categoryId: id);
        },
      ),
    ],
  );
});
