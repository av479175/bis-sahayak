import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/main_scaffold.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/assistant/assistant_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/standard_details/standard_details_screen.dart';
import '../screens/compliance_journey/compliance_journey_screen.dart';
import '../screens/verify/verify_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Only redirect to splash during initial app bootstrap (when loading and no value/error yet)
      final isInitialBootstrap = authState.isLoading && !authState.hasValue && !authState.hasError;
      if (isInitialBootstrap) return loc == '/splash' ? null : '/splash';

      final isLoggedIn = authState.valueOrNull != null;
      if (!isLoggedIn && loc != '/auth') return '/auth';
      if (isLoggedIn && (loc == '/auth' || loc == '/splash')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/assistant', builder: (context, state) => const AssistantScreen()),
          GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
          GoRoute(path: '/saved', builder: (context, state) => const SavedScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/verify',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => VerifyScreen(initialType: state.uri.queryParameters['type']),
      ),
      GoRoute(
        path: '/standard-details/:standardId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StandardDetailsScreen(standardId: state.pathParameters['standardId']!),
      ),
      GoRoute(
        path: '/compliance-journey/:categoryId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ComplianceJourneyScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(
        path: '/conversation/:conversationId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AssistantScreen(conversationId: state.pathParameters['conversationId']),
      ),
    ],
  );
});
