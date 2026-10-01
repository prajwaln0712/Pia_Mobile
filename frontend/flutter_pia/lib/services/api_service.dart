import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService;
  final Dio _dio;

  ApiService(this._authService)
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://chat.creatingwings.org/',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final response = await _dio.get('/api/user/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('getUser failed: ${e.response?.statusCode} ${e.response?.data}');
      return null;
    }
  }

  /// Upserts the backend user record for a just-logged-in Auth0 identity.
  /// Must be called after every successful login — without it the sub has no
  /// DB row and `/api/chat`/`/api/user/me` will 404 for it.
  Future<Map<String, dynamic>?> registerUser({
    required String sub,
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.post('/api/auth/callback', data: {
        'sub': sub,
        'name': name,
        'email': email,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('registerUser failed: ${e.response?.statusCode} ${e.response?.data}');
      return null;
    }
  }

  /// Creates a guest identity for chatting without logging in.
  Future<Map<String, dynamic>?> createAnonymousUser() async {
    try {
      final response = await _dio.post('/api/user/anonymous');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('createAnonymousUser failed: ${e.response?.statusCode} ${e.response?.data}');
      return null;
    }
  }

  /// Sends a chat message. The backend keeps one rolling conversation per
  /// user, so `conversationId` is only ever an echo of what it last returned.
  Future<Map<String, dynamic>?> sendMessage({
    required String userId,
    String? conversationId,
    required String message,
  }) async {
    try {
      final response = await _dio.post('/api/chat', data: {
        'user_id': userId,
        if (conversationId != null) 'conversation_id': conversationId,
        'message': message,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('sendMessage failed: ${e.response?.statusCode} ${e.response?.data}');
      return null;
    }
  }

  /// Resolves the guest identity: reuses a cached one, else mints a new one
  /// via `createAnonymousUser()` and persists it.
  Future<String?> continueAsGuest() async {
    final cached = await _authService.getAnonymousUserId();
    if (cached != null) return cached;

    final guest = await createAnonymousUser();
    final guestId = guest?['user_id'] as String?;
    if (guestId != null) {
      await _authService.setAnonymousUserId(guestId);
    }
    return guestId;
  }

  /// Full Google login + backend registration in one call, so screens don't
  /// each reimplement the sequence. `sub` is non-null on success — including
  /// a registration-sync failure, since login itself still succeeded and the
  /// backend falls back to the body `user_id` for unregistered tokens.
  Future<({String? sub, String? email, String? error})> loginWithGoogleAndRegister() async {
    final credentials = await _authService.loginWithGoogle();
    if (credentials == null) {
      return (sub: null, email: null, error: 'Login failed');
    }

    final email = credentials.user.email;
    if (email == null || email.isEmpty) {
      return (
        sub: null,
        email: null,
        error: 'Login succeeded but no email was returned. Please try again.',
      );
    }

    final registered = await registerUser(
      sub: credentials.user.sub,
      name: credentials.user.name ?? '',
      email: email,
    );
    if (registered == null) {
      return (
        sub: credentials.user.sub,
        email: email,
        error: "Signed in, but couldn't sync your profile. Please try again.",
      );
    }

    return (sub: credentials.user.sub, email: email, error: null);
  }
}