import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
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

        if (data['response_code'] == 200) {
          var userData = UserLoginResponse.fromMap(data['data']);
          await _sessionManager.saveValidSession();
          await _sessionManager.saveUserSession(userData: userData);
          await _sessionManager.saveProjectList(projects: userData.projects);
          errorText.value = '';
          Get.offAllNamed(AppRoutes.moduleSelection);
        } else if (data['response_code'] == 100) {
          errorText.value = "incorrect_username_password".tr;
          await _sessionManager.logout();
        } else if (data['response_code'] == 300) {
          await _sessionManager.checkSession();
        } else {
          errorText.value = data['message'] ?? "something_went_wrong".tr;
          await _sessionManager.logout();
        }
      } else {
        errorText.value = "something_went_wrong".tr;
        await _sessionManager.logout();
      }
    } catch (e) {
      print('Login error: $e');
      errorText.value = "something_went_wrong".tr;
      await _sessionManager.logout();
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _sessionBox.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
