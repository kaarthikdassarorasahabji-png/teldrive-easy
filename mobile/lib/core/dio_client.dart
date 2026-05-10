import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_storage.dart';

/// Riverpod-managed Dio singleton.
/// Picks up the server URL + JWT from secure storage on every request,
/// so reading them once at app start vs. switching servers mid-session
/// both Just Work.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final base = await AuthStorage.getServerUrl();
      if (base == null || base.isEmpty) {
        return handler.reject(DioException(
          requestOptions: options,
          message: 'No TelDrive server configured',
        ));
      }
      options.baseUrl = base.endsWith('/') ? base : '$base/';

      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Cookie'] = 'access_token=$token';
      }
      handler.next(options);
    },
    onError: (e, handler) {
      // 401 -> token expired/revoked; trigger relogin by clearing it.
      if (e.response?.statusCode == 401) {
        AuthStorage.clearToken();
      }
      handler.next(e);
    },
  ));

  return dio;
});
