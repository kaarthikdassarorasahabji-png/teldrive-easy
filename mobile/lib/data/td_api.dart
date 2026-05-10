import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dio_client.dart';
import 'td_models.dart';

/// Thin REST wrapper around TelDrive's HTTP API.
/// Endpoints follow the upstream OpenAPI spec at
/// https://github.com/tgdrive/teldrive/tree/main/openapi
///
/// We add new methods here as Phase B/C/D needs them.
class TdApi {
  TdApi(this._dio);
  final Dio _dio;

  Future<TdSession> session() async {
    final r = await _dio.get<Map<String, dynamic>>('api/auth/session');
    return TdSession.fromJson(r.data ?? {});
  }

  Future<List<TdFile>> listFolder(String path) async {
    final r = await _dio.get<Map<String, dynamic>>(
      'api/files',
      queryParameters: {'path': path, 'sort': 'name', 'order': 'asc'},
    );
    final results = (r.data?['results'] ?? r.data?['files'] ?? []) as List;
    return results
        .whereType<Map<String, dynamic>>()
        .map(TdFile.fromJson)
        .toList(growable: false);
  }

  /// Returns a Dio response stream for a file's bytes.
  /// Used by the image/video viewers via cached_network_image / VideoPlayer.
  String streamUrl(String fileId, String fileName) =>
      'api/files/$fileId/stream/$fileName';

  Future<void> logout() async {
    try {
      await _dio.post<void>('api/auth/logout');
    } on DioException {
      // Best-effort - we clear local state regardless.
    }
  }
}

final tdApiProvider = Provider<TdApi>((ref) => TdApi(ref.watch(dioProvider)));
