import 'package:flutter/material.dart';

import '../../data/td_models.dart';

class FileTile extends StatelessWidget {
  const FileTile({super.key, required this.file, required this.onTap});
  final TdFile file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(_iconFor(file), color: scheme.primary, size: 32),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(file.isFolder ? 'Folder' : _formatSize(file.size)),
      trailing: file.isFolder ? const Icon(Icons.chevron_right) : null,
    );
  }

  IconData _iconFor(TdFile f) {
    if (f.isFolder) return Icons.folder;
    if (f.isImage)  return Icons.image;
    if (f.isVideo)  return Icons.video_file;
    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
