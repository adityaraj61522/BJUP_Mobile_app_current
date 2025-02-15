import 'package:bjup_application/common/api_config/api_config.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl, // Use centralized base URL
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    // Attach authentication token if available
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        var box = Hive.box('session');
        var token = box.get('token'); // Retrieve stored token
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("API Error: ${e.response?.statusCode} - ${e.response?.data}");
        return handler.next(e);
      },
    ));
  }

  Future<Response?> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } catch (e) {
      print("GET Error: $e");
      return null;
    }
  }

  Future<Response?> post(String endpoint, dynamic data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      print("POST Error: $e");
      return null;
    }
  }

  Future<Response?> put(String endpoint, dynamic data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      print("PUT Error: $e");
      return null;
    }
  }

  Future<Response?> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      print("DELETE Error: $e");
      return null;
    }
  }
}
