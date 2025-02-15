import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/response_models/user_response.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AttendenceListController extends GetxController {
  var selectedDate = DateTime.now().obs; // Observable Date
  var selectedTime = TimeOfDay.now().obs; // Observable Time
  var currentLocation = 'Not Available'.obs; // Observable Location
  var selectedLocation = "Office".obs;

  // Function to select date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  // Function to select time
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );

    if (pickedTime != null) {
      selectedTime.value = pickedTime;
    }
  }

  // Function to get current location
  Future<void> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Location Error", "Please enable location services.");
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permission Denied", "Location permission is required.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Permission Denied",
            "Location access is permanently denied. Enable from settings.");
        return;
      }

      // Try to fetch current position with error handling
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10), // Avoids infinite waiting
      );

      // Update observable location value
      currentLocation.value = "${position.latitude}, ${position.longitude}";
    } on TimeoutException {
      Get.snackbar(
          "Timeout Error", "Failed to fetch location. Please try again.");
    } on PermissionDeniedException {
      Get.snackbar("Permission Error", "Location permission was denied.");
    } on LocationServiceDisabledException {
      Get.snackbar("Service Disabled", "Location service is turned off.");
    } catch (e) {
      Get.snackbar("Unexpected Error", "Something went wrong: $e");
    }
  }

  void changeLocation(String value) {
    selectedLocation.value = value;
  }

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
