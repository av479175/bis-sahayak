import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import 'providers/network_providers.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kick off the wake-up ping immediately, don't block startup on it.
  // ignore: unawaited_futures
  warmUpBackend();

  CookieJar cookieJar;
  if (kIsWeb) {
    // File-based persistence isn't supported on web; the browser owns
    // cookies there anyway, so an in-memory jar is enough to satisfy the type.
    cookieJar = CookieJar();
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(storage: FileStorage('${appDocDir.path}/.bis_cookies/'));
  }

  runApp(
    ProviderScope(
      overrides: [cookieJarProvider.overrideWithValue(cookieJar)],
      child: const BISSahayakApp(),
    ),
  );
}

class BISSahayakApp extends ConsumerWidget {
  const BISSahayakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'BIS Sahayak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
