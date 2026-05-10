/// Plain Dart models for the TelDrive REST API.
/// Hand-written (no codegen) to keep the project tiny.

class TdFile {
  final String id;
  final String name;
  final String type;       // 'file' or 'folder'
  final int    size;       // bytes
  final String mimeType;
  final DateTime updatedAt;
  final String? parentId;

  const TdFile({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.mimeType,
    required this.updatedAt,
    this.parentId,
  });

  bool get isFolder => type == 'folder';
  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');

  factory TdFile.fromJson(Map<String, dynamic> json) => TdFile(
        id:        (json['id'] ?? '').toString(),
        name:      (json['name'] ?? '').toString(),
        type:      (json['type'] ?? 'file').toString(),
        size:      (json['size'] is int) ? json['size'] : int.tryParse('${json['size']}') ?? 0,
        mimeType:  (json['mimeType'] ?? json['mime_type'] ?? '').toString(),
        updatedAt: DateTime.tryParse((json['updatedAt'] ?? json['updated_at'] ?? '').toString())
            ?? DateTime.fromMillisecondsSinceEpoch(0),
        parentId:  json['parentId']?.toString() ?? json['parent_id']?.toString(),
      );
}

class TdSession {
  final String userId;
  final String userName;
  final String? bio;

  const TdSession({required this.userId, required this.userName, this.bio});

  factory TdSession.fromJson(Map<String, dynamic> json) => TdSession(
        userId:   (json['userId'] ?? json['id'] ?? '').toString(),
        userName: (json['userName'] ?? json['name'] ?? '').toString(),
        bio:      json['bio']?.toString(),
      );
}
