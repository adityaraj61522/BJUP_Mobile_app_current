import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var obscureText = true.obs;
  var errorText = ''.obs;
  var isLoading = false.obs;

  late Box _sessionBox;
  final ApiService apiService = ApiService();
  final SessionManager _sessionManager = SessionManager();

  @override
  void onInit() async {
    super.onInit();
    await _sessionManager.init();
    _sessionManager.checkSession();
  }

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  Future<void> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      errorText.value = "username_password_empty".tr;
      return;
    }

    try {
      isLoading.value = true;
      errorText.value = '';

      // Create FormData
      var formData = FormData.fromMap({
        'username': username,
        'password': password,
      });

      var response = await apiService.post(
        "/mainLogin.php",
        formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': '*/*',
          },
        ),
      );

      if (response != null) {
        var data = response.data;

        // Handle different response codes
        if (data['response_code'] == 200) {
          // Login successful
          var userData = data['data'];
          await _sessionManager.saveSession(userData);
          errorText.value = '';
          Get.offAllNamed('/moduleSelection');
        } else if (data['response_code'] == 100) {
          // Invalid credentials
          errorText.value = "invalid_credentials".tr;
          await _sessionManager.logout();
        } else if (data['response_code'] == 300) {
          // Force logout
          await _sessionManager.checkSession();
        } else {
          // Unknown response code
          errorText.value = data['message'] ?? "unknown_error".tr;
          await _sessionManager.logout();
        }
      } else {
        errorText.value = "server_error".tr;
        await _sessionManager.logout();
      }
    } catch (e) {
      print('Login error: $e');
      errorText.value = "login_failed".tr;
      await _sessionManager.logout();
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _sessionBox.clear();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
