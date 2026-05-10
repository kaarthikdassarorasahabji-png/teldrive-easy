import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth_storage.dart';
import '../../data/td_api.dart';
import '../../data/td_models.dart';

class ImageViewerScreen extends ConsumerStatefulWidget {
  const ImageViewerScreen({super.key, required this.file});
  final TdFile file;

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  String? _url;
  Map<String, String>? _headers;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  Future<void> _resolveUrl() async {
    final base = await AuthStorage.getServerUrl();
    final token = await AuthStorage.getToken();
    final api = ref.read(tdApiProvider);
    setState(() {
      _url = '$base/${api.streamUrl(widget.file.id, widget.file.name)}';
      _headers = {if (token != null) 'Cookie': 'access_token=$token'};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: Text(widget.file.name),
      ),
      body: Center(
        child: _url == null
            ? const CircularProgressIndicator()
            : InteractiveViewer(
                maxScale: 6,
                child: CachedNetworkImage(
                  imageUrl: _url!,
                  httpHeaders: _headers,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const CircularProgressIndicator(),
                  errorWidget: (_, __, e) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load: $e',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
      ),
    );
  }
}
