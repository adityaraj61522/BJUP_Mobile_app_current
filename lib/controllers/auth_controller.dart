import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final _apiService = ApiService();
  final _isLoading = false.obs;
  final _user = Rxn<User>();
  final _isAuthenticated = false.obs;

  bool get isLoading => _isLoading.value;
  User? get user => _user.value;
  bool get isAuthenticated => _isAuthenticated.value;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final box = await Hive.openBox('auth');
      final token = box.get(ApiService.authTokenKey);

      if (token != null) {
        _isAuthenticated.value = true;
        await fetchUserProfile();
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;

      final response = await _apiService.login(email, password);
      final authResponse = AuthResponse.fromJson(response.data);

      _isAuthenticated.value = true;
      await fetchUserProfile();

      Get.offAllNamed('/home'); // Navigate to home screen
    } catch (e) {
      _isAuthenticated.value = false;
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      _isLoading.value = true;

      final response = await _apiService.getUserProfile();
      _user.value = User.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _apiService.logout();

      _isAuthenticated.value = false;
      _user.value = null;

      Get.offAllNamed('/login'); // Navigate to login screen
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }
}
