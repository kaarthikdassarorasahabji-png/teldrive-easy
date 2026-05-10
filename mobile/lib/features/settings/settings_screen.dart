import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth_storage.dart';
import '../../data/td_api.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          FutureBuilder<String?>(
            future: AuthStorage.getServerUrl(),
            builder: (_, snap) => ListTile(
              leading: const Icon(Icons.dns),
              title: const Text('Server URL'),
              subtitle: Text(snap.data ?? '(not set)'),
              onTap: () async {
                await AuthStorage.clearAll();
                if (context.mounted) context.go('/setup');
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              await ref.read(tdApiProvider).logout();
              await AuthStorage.clearToken();
              if (context.mounted) context.go('/login');
            },
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'TelDrive Easy',
            applicationVersion: '0.1.0 (Phase A)',
            applicationLegalese: 'Made by Kaarthik Dass Arora\n'
                'Based on tgdrive/teldrive\n\n'
                'iOS app coming soon. Stay tuned.',
          ),
        ],
      ),
    );
  }
}
