import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService;
  final Dio _dio;

  ApiService(this._authService)
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://chatbot-backend-alb-1820253308.us-east-1.elb.amazonaws.com/',
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
}