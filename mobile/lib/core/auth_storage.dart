import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the user's TelDrive server URL + JWT cookie in encrypted storage.
/// On Android: backed by EncryptedSharedPreferences. On iOS: Keychain.
class AuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kServerUrl = 'server_url';
  static const _kToken     = 'access_token';

  static Future<void> setServerUrl(String url) =>
      _storage.write(key: _kServerUrl, value: url);

  static Future<String?> getServerUrl() => _storage.read(key: _kServerUrl);

  static Future<bool> hasServerUrl() async =>
      (await getServerUrl())?.isNotEmpty ?? false;

  static Future<void> setToken(String token) =>
      _storage.write(key: _kToken, value: token);

  static Future<String?> getToken() => _storage.read(key: _kToken);

  static Future<bool> hasToken() async =>
      (await getToken())?.isNotEmpty ?? false;

  static Future<void> clearToken() => _storage.delete(key: _kToken);

  static Future<void> clearAll() async {
    await _storage.delete(key: _kServerUrl);
    await _storage.delete(key: _kToken);
  }
}
