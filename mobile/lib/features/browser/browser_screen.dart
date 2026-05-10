import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/td_api.dart';
import '../../data/td_models.dart';
import '../viewer/image_viewer.dart';
import 'file_tile.dart';

final folderProvider =
    FutureProvider.family<List<TdFile>, String>((ref, path) async {
  return ref.watch(tdApiProvider).listFolder(path);
});

class BrowserScreen extends ConsumerWidget {
  const BrowserScreen({super.key, this.path = '/'});
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(folderProvider(path));
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(segments.isEmpty ? 'My Drive' : segments.last),
        leading: path == '/'
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  final parent = segments.length <= 1
                      ? '/'
                      : '/${segments.sublist(0, segments.length - 1).join('/')}';
                  context.go(parent == '/'
                      ? '/'
                      : '/browser/${Uri.encodeComponent(parent)}');
                },
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(folderProvider(path)),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: files.when(
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.refresh(folderProvider(path)),
          child: items.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) => FileTile(
                    file: items[i],
                    onTap: () => _openFile(context, ref, items[i]),
                  ),
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e, onRetry: () => ref.refresh(folderProvider(path))),
      ),
    );
  }

  void _openFile(BuildContext context, WidgetRef ref, TdFile f) {
    if (f.isFolder) {
      final next = path == '/' ? '/${f.name}' : '$path/${f.name}';
      context.go('/browser/${Uri.encodeComponent(next)}');
      return;
    }
    if (f.isImage) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ImageViewerScreen(file: f),
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preview for ${f.name} coming soon')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => ListView(
        children: [
          const SizedBox(height: 96),
          Icon(Icons.folder_open,
              size: 96, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'This folder is empty.\nUpload from the web UI for now.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}
