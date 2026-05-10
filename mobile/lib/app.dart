import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/auth_storage.dart';
import 'features/auth/server_url_screen.dart';
import 'features/auth/telegram_login_screen.dart';
import 'features/browser/browser_screen.dart';
import 'features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final hasServer = await AuthStorage.hasServerUrl();
      final hasToken = await AuthStorage.hasToken();
      final loc = state.matchedLocation;

      if (!hasServer && loc != '/setup') return '/setup';
      if (hasServer && !hasToken && loc != '/login' && loc != '/setup') return '/login';
      if (hasServer && hasToken && (loc == '/setup' || loc == '/login')) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/setup', builder: (_, __) => const ServerUrlScreen()),
      GoRoute(path: '/login', builder: (_, __) => const TelegramLoginScreen()),
      GoRoute(path: '/',      builder: (_, __) => const BrowserScreen()),
      GoRoute(
        path: '/browser/:path',
        builder: (_, state) => BrowserScreen(path: Uri.decodeComponent(state.pathParameters['path']!)),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});

class TelDriveApp extends ConsumerWidget {
  const TelDriveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TelDrive Easy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF229ED9)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF229ED9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
