import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth_storage.dart';

class ServerUrlScreen extends ConsumerStatefulWidget {
  const ServerUrlScreen({super.key});

  @override
  ConsumerState<ServerUrlScreen> createState() => _ServerUrlScreenState();
}

class _ServerUrlScreenState extends ConsumerState<ServerUrlScreen> {
  final _ctrl = TextEditingController(text: 'http://192.168.1.');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your TelDrive URL';
    final uri = Uri.tryParse(v.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return 'Must start with http:// or https://';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    var url = _ctrl.text.trim();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    await AuthStorage.setServerUrl(url);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.cloud, size: 96, color: Color(0xFF229ED9)),
                const SizedBox(height: 24),
                Text('TelDrive Easy',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('by Kaarthik Dass Arora',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 48),
                Text('Server URL', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'The address of your TelDrive server. Find your PC\'s IP with '
                  '"ipconfig" in Command Prompt - look for IPv4 Address.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ctrl,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'http://192.168.1.42:8080',
                  ),
                  validator: _validate,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
