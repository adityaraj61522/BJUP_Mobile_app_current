import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Box? _sessionBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        if (!Hive.isAdapterRegistered(1)) {
          Hive.registerAdapter(UserModelAdapter());
        }
        _sessionBox = await Hive.openBox('session');
        _isInitialized = true;
      } catch (e) {
        print('Session initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveSession(Map<String, dynamic> userData) async {
    await init();
    try {
      final user = UserModel.fromJson(userData);
      await _sessionBox?.put('user', user);
    } catch (e) {
      print('Session save error: $e');
      rethrow;
    }
  }

  // Get current user
  UserModel? getUser() {
    try {
      return _sessionBox?.get('user') as UserModel?;
    } catch (e) {
      print('Session read error: $e');
      return null;
    }
  }

  // Quick access helpers
  bool get isLoggedIn => getUser() != null;
  String get userType => getUser()?.userTypeLabel ?? '';
  String get projectTitle => getUser()?.projectTitle ?? '';
  String get officeTitle => getUser()?.officeTitle ?? '';

  // Feature access checks
  bool hasAccess(String accessType) =>
      getUser()?.hasAccess(accessType) ?? false;
  bool hasFeature(String feature) =>
      getUser()?.hasFeatureAccess(feature) ?? false;

  // Logout
  Future<void> logout() async {
    await init();
    await _sessionBox?.clear();
    Get.offAllNamed('/login');
  }

  // Force logout with message
  Future<void> forceLogout() async {
    await init();
    await _sessionBox?.clear();

    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
      Get.snackbar(
        'session_expired'.tr,
        'please_login_again'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Check session status
  Future<void> checkSession() async {
    await init();
    final user = getUser();
    if (user != null) {
      if (user.userTypeId == 300) {
        await forceLogout();
      } else if (Get.currentRoute == '/login') {
        Get.offNamed('/moduleSelection');
      }
    }
  }
}
