import 'dart:async';
import 'dart:io';

import 'package:bjup_application/attendence_list_page/attendence_list_view.dart';
import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/attendence_list_storage.dart';
import 'package:bjup_application/common/response_models/attendence_record_model/attendence_record_model.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:intl/intl.dart';

class AttendenceListController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  AttendenceStorageService attendenceStorageService =
      AttendenceStorageService();

  final attendanceDataList = <AttendanceRecord>[].obs;
  Rx<AttendanceRecord?> activeAttendanceRecord = Rx<AttendanceRecord?>(null);

  UserLoginResponse? userData;

  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final selectedDateTime = DateTime.now().obs;

  final isPunchActive = false.obs;
  final activeInTime = '--'.obs;
  final activeOutTime = '--'.obs;

  final currentLocation = 'Not Available'.obs;
  final selectedLocation = "Office".obs;

  final selectedLatitude = 0.0.obs;
  final selectedLongitude = 0.0.obs;

  final isMarkingAttendance = false.obs;
  Rx<File?> capturedImage = Rx<File?>(null);

  final attendanceCardList = <Widget>[].obs;

  final ApiService apiService = ApiService();

  @override
  void onInit() async {
    super.onInit();
    userData = await sessionManager.getUserData();
    await loadAttendanceData();
    await getCurrentLocation();

    // Initialize time and date to current
    resetDateTimeSelectors();
  }

  void resetDateTimeSelectors() {
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
    selectedDateTime.value = DateTime.now();
  }

  Future<void> loadAttendanceData() async {
    try {
      final data = await attendenceStorageService.getAllAttendanceData();
      attendanceDataList.value = data;

      // Check for active punch-in (not punched out)
      final activePunchIn = attendanceDataList
          .where((record) => record.punchedOut == false)
          .toList();

      if (activePunchIn.isNotEmpty) {
        // Sort by date to get the latest active punch-in
        activePunchIn.sort((a, b) {
          if (a.inDateTime == null || b.inDateTime == null) return 0;
          return DateTime.parse(b.inDateTime!)
              .compareTo(DateTime.parse(a.inDateTime!));
        });

        // Set the active record
        activeAttendanceRecord.value = activePunchIn.first;
        isPunchActive.value = true;

        // Format and display punch-in time
        if (activeAttendanceRecord.value?.inDateTime != null) {
          final inTime =
              DateTime.parse(activeAttendanceRecord.value!.inDateTime!);
          activeInTime.value = DateFormat('hh:mm a').format(inTime);
        } else {
          activeInTime.value = '--';
        }

        // Since it's an active punch-in, out time is empty
        activeOutTime.value = '--';
      } else {
        // No active punch-in
        isPunchActive.value = false;
        activeAttendanceRecord.value = null;
        activeInTime.value = '--';
        activeOutTime.value = '--';
      }

      // Update the UI with attendance records
      updateAttendanceCardList();
    } catch (e) {
      print("Error loading attendance data: $e");
      Get.snackbar("Error", "Failed to load attendance data: $e");
    }
  }

  void updateAttendanceCardList() {
    attendanceCardList.clear();

    // Sort records by date (newest first)
    final sortedRecords = List<AttendanceRecord>.from(attendanceDataList);
    sortedRecords.sort((a, b) {
      if (a.inDateTime == null || b.inDateTime == null) return 0;
      return DateTime.parse(b.inDateTime!)
          .compareTo(DateTime.parse(a.inDateTime!));
    });

    for (final record in sortedRecords) {
      attendanceCardList.add(
        Column(
          children: [
            AttendenceCard(attendanceRecord: record),
            const SizedBox(height: 15),
          ],
        ),
      );
    }
    attendanceCardList.value = attendanceCardList.reversed.toList();
  }

  // Function to select date
  Future<void> changeDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      selectedDate.value = pickedDate;
      selectedDateTime.value = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        selectedTime.value.hour,
        selectedTime.value.minute,
      );
    }
  }

  // Function to select time
  Future<void> changeTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (pickedTime != null) {
      selectedTime.value = pickedTime;
      selectedDateTime.value = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
  }

  // Function to get current location
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Location Error", "Please enable location services.");
        return;
      }
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
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      selectedLatitude.value = position.latitude;
      selectedLongitude.value = position.longitude;
      await getAddressFromCoordinates(
          latitude: position.latitude, longitude: position.longitude);
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

  Future<void> getAddressFromCoordinates(
      {required double latitude, required double longitude}) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentLocation.value = place.street ?? 'Street name not found';
      } else {
        currentLocation.value = 'Address not found for these coordinates';
      }
    } catch (e) {
      currentLocation.value = 'Error fetching address: $e';
      print('Error fetching address: $e');
    }
  }

  void changeLocation(String value) {
    selectedLocation.value = value;
  }

  // Function to mark attendance
  Future<void> saveattendence({required BuildContext context}) async {
    if (isMarkingAttendance.value) {
      Get.snackbar("Processing", "Already processing attendance. Please wait.");
      return;
    }

    // Check if an image is captured
    if (capturedImage.value == null) {
      Get.snackbar("Error", "Please capture an image before submitting.",
          backgroundColor: AppColors.red, colorText: AppColors.white);
      return;
    }

    isMarkingAttendance.value = true;

    try {
      // Create a new attendance record
      final newAttendanceRecord = AttendanceRecord();

      // Set basic info
      newAttendanceRecord.locationType = selectedLocation.value;
      newAttendanceRecord.gpsLatitude = selectedLatitude.value;
      newAttendanceRecord.gpsLongitude = selectedLongitude.value;
      newAttendanceRecord.attendenceIndex =
          DateTime.now().millisecondsSinceEpoch.toInt();

      if (!isPunchActive.value) {
        // This is a punch-in
        newAttendanceRecord.attendenceType = "login";
        newAttendanceRecord.inDateTime = selectedDateTime.value.toString();
        newAttendanceRecord.inLocationName = currentLocation.value;
        newAttendanceRecord.punchedOut = false;
      } else {
        // This is a punch-out for an existing record
        newAttendanceRecord.attendenceType = "logout";

        // Copy the in-time details from active record
        if (activeAttendanceRecord.value != null) {
          newAttendanceRecord.inDateTime =
              activeAttendanceRecord.value!.inDateTime;
          newAttendanceRecord.inLocationName =
              activeAttendanceRecord.value!.inLocationName;
          newAttendanceRecord.attendenceIndex =
              activeAttendanceRecord.value!.attendenceIndex;
        }

        // Add punch-out details
        newAttendanceRecord.outDateTime = selectedDateTime.value.toString();
        newAttendanceRecord.outLocationName = currentLocation.value;
        newAttendanceRecord.punchedOut = true;
      }

      // Handle image
      if (capturedImage.value != null) {
        newAttendanceRecord.picture = await capturedImage.value!.readAsBytes();
      }

      // Send to server
      bool attendenceMarked = await markAttendance(
        context: context,
        newAttendanceRecord: newAttendanceRecord,
      );

      if (attendenceMarked) {
        if (!isPunchActive.value) {
          // For punch-in: add new record
          attendanceDataList.add(newAttendanceRecord);
          await attendenceStorageService
              .storeAttendanceData(newAttendanceRecord);

          // Update active record
          activeAttendanceRecord.value = newAttendanceRecord;
          isPunchActive.value = true;

          // Update displayed times
          final inTime = DateTime.parse(newAttendanceRecord.inDateTime!);
          activeInTime.value = DateFormat('hh:mm a').format(inTime);
          activeOutTime.value = '--';
        } else {
          // For punch-out: update the active record
          int indexToUpdate = attendanceDataList.indexWhere((record) =>
              record.punchedOut != true && record.attendenceType == "login");

          if (indexToUpdate >= 0) {
            // Remove the active record and add the completed one
            attendanceDataList.removeAt(indexToUpdate);
            attendanceDataList.add(newAttendanceRecord);

            // Update in Hive
            await attendenceStorageService
                .replaceAllAttendanceData(attendanceDataList);

            // Reset active state
            isPunchActive.value = false;
            activeAttendanceRecord.value = null;
            activeInTime.value = '--';
            activeOutTime.value = '--';
          }
        }

        // Update UI
        updateAttendanceCardList();

        // Close the bottom sheet
        closeBottomSheet(context: context);

        // Reset the image
        capturedImage.value = null;

        // Reset time and date selectors to current time
        resetDateTimeSelectors();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to process attendance: $e");
    } finally {
      isMarkingAttendance.value = false;
    }
  }

  Future<bool> markAttendance({
    required BuildContext context,
    required AttendanceRecord newAttendanceRecord,
  }) async {
    try {
      var formData = FormData.fromMap({
        'user_id': userData!.userId,
        'attendance_type': newAttendanceRecord.attendenceType,
        'date_time': isPunchActive.value
            ? newAttendanceRecord.outDateTime
            : newAttendanceRecord.inDateTime,
        'location_type': newAttendanceRecord.locationType,
        'gps_latitude': newAttendanceRecord.gpsLatitude,
        'gps_longitude': newAttendanceRecord.gpsLongitude,
      });

      if (capturedImage.value != null) {
        try {
          formData.files.add(MapEntry(
            'picture',
            await MultipartFile.fromFile(capturedImage.value!.path,
                filename:
                    'attendance_${DateTime.now().millisecondsSinceEpoch}.png'),
          ));
        } catch (e) {
          print('Error creating multipart file: $e');
          Get.snackbar("File Error", "Failed to attach the captured image.");
          return false;
        }
      }

      var response = await apiService.post("/markAttendance.php", formData);

      if (response != null && response.statusCode == 200) {
        print('Attendance marked successfully: ${response.data}');
        Get.snackbar("Success", "Attendance marked successfully!");
        return true;
      } else {
        print(
            'Failed to mark attendance: ${response?.statusCode} - ${response?.data}');
        String errorMessage = "Failed to mark attendance.";
        if (response?.data != null &&
            response!.data is Map &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response?.data != null) {
          errorMessage = 'Failed to mark attendance: ${response!.data}';
        }
        Get.snackbar("Error", errorMessage);
        return false;
      }
    } on DioException catch (e) {
      print('Dio error marking attendance: $e');
      String errorMessage = "Something went wrong while marking attendance.";
      if (e.response != null &&
          e.response?.data != null &&
          e.response?.data is Map &&
          e.response?.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      } else if (e.message != null) {
        errorMessage = 'Network error: ${e.message}';
      }
      Get.snackbar("Network Error", errorMessage);
      return false;
    } catch (e) {
      print('Unexpected error marking attendance: $e');
      Get.snackbar("Unexpected Error", "Something went wrong: $e");
      return false;
    }
  }

  void closeBottomSheet({required BuildContext context}) {
    Get.back();
  }

  // Method to check if it's a new day since last punch-in
  bool isNewDay() {
    if (activeAttendanceRecord.value?.inDateTime == null) return false;

    final lastPunchInDate =
        DateTime.parse(activeAttendanceRecord.value!.inDateTime!);
    final now = DateTime.now();

    return lastPunchInDate.year != now.year ||
        lastPunchInDate.month != now.month ||
        lastPunchInDate.day != now.day;
  }

  // Method to auto punch-out at the end of day (if needed)
  Future<void> checkAndHandleDayChange() async {
    // If there's an active punch-in from a previous day
    if (isPunchActive.value && isNewDay()) {
      try {
        // Create an automatic punch-out record for end of previous day
        final autoPunchOutRecord = AttendanceRecord();

        // Copy data from active record
        autoPunchOutRecord.attendenceType = "logout";
        autoPunchOutRecord.inDateTime =
            activeAttendanceRecord.value!.inDateTime;
        autoPunchOutRecord.inLocationName =
            activeAttendanceRecord.value!.inLocationName;
        autoPunchOutRecord.locationType =
            activeAttendanceRecord.value!.locationType;
        autoPunchOutRecord.attendenceIndex =
            activeAttendanceRecord.value!.attendenceIndex;

        // Set auto punch-out time to 11:59:59 PM of the same day as punch-in
        final punchInTime =
            DateTime.parse(activeAttendanceRecord.value!.inDateTime!);
        final punchOutTime = DateTime(
            punchInTime.year, punchInTime.month, punchInTime.day, 23, 59, 59);

        autoPunchOutRecord.outDateTime = punchOutTime.toString();
        autoPunchOutRecord.outLocationName = "Auto Punch-Out at End of Day";
        autoPunchOutRecord.punchedOut = true;
        autoPunchOutRecord.gpsLatitude =
            activeAttendanceRecord.value!.gpsLatitude;
        autoPunchOutRecord.gpsLongitude =
            activeAttendanceRecord.value!.gpsLongitude;

        // Remove the active record and add the completed one
        int indexToUpdate = attendanceDataList.indexWhere((record) =>
            record.punchedOut != null &&
            !record.punchedOut! &&
            record.attendenceType == "login");

        if (indexToUpdate >= 0) {
          attendanceDataList.removeAt(indexToUpdate);
          attendanceDataList.add(autoPunchOutRecord);

          // Update in Hive
          await attendenceStorageService
              .replaceAllAttendanceData(attendanceDataList);

          // Reset active state
          isPunchActive.value = false;
          activeAttendanceRecord.value = null;
          activeInTime.value = '--';
          activeOutTime.value = '--';

          // Update UI
          updateAttendanceCardList();

          Get.snackbar("Auto Punch-Out",
              "You were automatically punched out at the end of the previous day.");
        }
      } catch (e) {
        print("Error during auto punch-out: $e");
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Check for day change when app starts
    checkAndHandleDayChange();
  }
}
