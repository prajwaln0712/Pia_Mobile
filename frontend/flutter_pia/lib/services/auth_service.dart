import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Reads a required key from the bundled `.env`, failing loudly rather than
/// letting a missing value surface later as an opaque Auth0 error.
String _requireEnv(final String key) {
  final value = dotenv.env[key];
  if (value == null || value.isEmpty) {
    throw StateError(
      'Missing $key. Copy .env.example to .env and fill in the value.',
    );
  }
  return value;
}

class AuthService {
  final Auth0 _auth0 = Auth0(
    _requireEnv('AUTH0_DOMAIN'),
    _requireEnv('AUTH0_CLIENT_ID'),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Custom URL scheme for the Auth0 callback. Must match the `auth0Scheme`
  /// manifest placeholder and the URLs registered in the Auth0 dashboard:
  /// creatingwings.org://<domain>/android/creatingwings.org/callback
  static const String _scheme = 'creatingwings.org';

  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';

  Future<String?> login() async {
    try {
      final credentials = await _auth0.webAuthentication(scheme: _scheme).login(
        audience: 'https://chat.creatingwings.org/api',
      );  

      final accessToken = credentials.accessToken;
      final userId = credentials.user.sub;

      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _userIdKey, value: userId);

      return accessToken;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }

  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: _scheme).logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _userIdKey);
    }
  }
}