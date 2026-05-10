import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/auth_storage.dart';

/// Wraps the TelDrive web /login flow in a WebView.
/// On successful Telegram auth, the server sets an `access_token` cookie -
/// we capture it, store it in secure storage, then route to the browser.
class TelegramLoginScreen extends ConsumerStatefulWidget {
  const TelegramLoginScreen({super.key});

  @override
  ConsumerState<TelegramLoginScreen> createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends ConsumerState<TelegramLoginScreen> {
  WebViewController? _controller;
  String? _serverUrl;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final url = await AuthStorage.getServerUrl();
    if (url == null) {
      if (mounted) context.go('/setup');
      return;
    }
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _checkForToken(url),
      ))
      ..loadRequest(Uri.parse('$url/login'));

    setState(() {
      _serverUrl = url;
      _controller = controller;
      _busy = false;
    });
  }

  Future<void> _checkForToken(String serverUrl) async {
    final cookieMgr = WebviewCookieManager();
    final cookies = await cookieMgr.getCookies(serverUrl);
    final token = cookies
        .where((c) => c.name == 'access_token')
        .map((c) => c.value)
        .firstOrNull;

    if (token != null && token.isNotEmpty) {
      await AuthStorage.setToken(token);
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in with Telegram'),
        actions: [
          IconButton(
            tooltip: 'Change server',
            icon: const Icon(Icons.settings_ethernet),
            onPressed: () async {
              await AuthStorage.clearAll();
              if (mounted) context.go('/setup');
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller!),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
