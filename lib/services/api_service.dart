import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ApiService {
  static const String baseUrl =
      'https://api.example.com'; // Replace with your API URL
  static const String authTokenKey = 'auth_token';

  late final Dio _dio;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Content-Type': 'application/json'},
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get auth token from Hive
        final box = await Hive.openBox('auth');
        final token = box.get(authTokenKey);

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        }

        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print(
              '⚠️ ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        }

        return handler.next(e);
      },
    ));
  }

  // API Methods
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      // Save token if login successful
      if (response.statusCode == 200 && response.data['token'] != null) {
        final box = await Hive.openBox('auth');
        await box.put(authTokenKey, response.data['token']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getUserProfile() async {
    try {
      return await _dio.get('/profile');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final box = await Hive.openBox('auth');
      await box.delete(authTokenKey);
    } catch (e) {
      rethrow;
    }
  }
}
