import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/response_models/user_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var obscureText = true.obs;
  var errorText = ''.obs;

  late Box _sessionBox;
  final ApiService apiService = ApiService();

  @override
  void onInit() async {
    super.onInit();
    // await Hive.initFlutter();
    _sessionBox = await Hive.openBox('session');
    _checkSession();
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

    var response = await apiService.post("/login", {
      "username": username,
      "password": password,
    });

    if (response != null && response.statusCode == 200) {
      var data = response.data;
      UserModel user = UserModel.fromJson(data['user']);

      // Store user session info in Hive
      var box = await Hive.openBox('session');
      await box.put('token', data['token']);
      await box.put('user', user.toJson());

      Get.offAllNamed('/dashboard'); // Navigate to Dashboard
    } else {
      errorText.value = "incorrect_username_password".tr;
    }
  }

  void _checkSession() {
    var user = _sessionBox.get('user');
    if (user != null) {
      Get.offNamed('/home');
    }
  }

  void logout() async {
    await _sessionBox.clear();
    Get.offNamed('/login');
  }
}
