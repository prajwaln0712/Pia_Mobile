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
  /// org.creatingwings.pia://<domain>/android/org.creatingwings.pia/callback
  static const String _scheme = 'org.creatingwings.pia';

  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _anonymousUserIdKey = 'anonymous_user_id';

  Future<Credentials?> login({String? connection}) async {
    try {
      final credentials = await _auth0.webAuthentication(scheme: _scheme).login(
        audience: 'https://chat.creatingwings.org/api',
        parameters: connection == null ? const {} : {'connection': connection},
      );

      await _storage.write(key: _accessTokenKey, value: credentials.accessToken);
      await _storage.write(key: _userIdKey, value: credentials.user.sub);

      return credentials;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Skips Auth0's hosted login page and goes straight to Google's own
  /// sign-in screen. Requires the Google social connection to be enabled
  /// for this app in the Auth0 dashboard.
  Future<Credentials?> loginWithGoogle() => login(connection: 'google-oauth2');

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// The backend's guest identity (`POST /api/user/anonymous`), persisted so
  /// a not-logged-in user keeps the same chat identity across app restarts.
  Future<String?> getAnonymousUserId() async {
    return await _storage.read(key: _anonymousUserIdKey);
  }

  Future<void> setAnonymousUserId(String id) async {
    await _storage.write(key: _anonymousUserIdKey, value: id);
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