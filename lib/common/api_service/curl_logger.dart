import 'dart:convert';
import 'package:dio/dio.dart';

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final curl = _generateCurlCommand(options);
      print('🚀 CURL Request:\n$curl\n');
    } catch (e) {
      print('❌ Failed to generate CURL command: $e');
    }
    super.onRequest(options, handler);
  }

  String _generateCurlCommand(RequestOptions options) {
    final method = options.method.toUpperCase();
    final buffer = StringBuffer();

    // Start with basic curl command
    buffer.write('curl --location -X $method');

    // Add headers
    options.headers.forEach((key, value) {
      if (value != null) {
        buffer.write(' -H "${key}: $value"');
      }
    });

    // Handle FormData properly
    if (options.data is FormData) {
      FormData formData = options.data as FormData;

      // Add form fields
      for (var field in formData.fields) {
        // Escape single quotes in the value
        String escapedValue = field.value.replaceAll("'", "'\\''");
        buffer.write(" \\\n--form '${field.key}=${escapedValue}'");
      }

      // Add files
      for (var file in formData.files) {
        buffer.write(" \\\n--form '${file.key}=@\"${file.value.filename}\"'");
      }
    } else if (options.data != null) {
      // Handle regular data
      String data;
      if (options.data is String) {
        data = options.data;
      } else {
        try {
          data = json.encode(options.data);
        } catch (e) {
          data = options.data.toString();
        }
      }
      buffer.write(" \\\n--data '$data'");
    }

    // Add URL
    // Handle query parameters if present
    if (options.queryParameters.isNotEmpty) {
      final uri = Uri(
        path: options.path,
        queryParameters: options.queryParameters,
      );
      buffer.write(" \\\n'${options.baseUrl}${uri.toString()}'");
    } else {
      buffer.write(" \\\n'${options.uri.toString()}'");
    }

    return buffer.toString();
  }
}
