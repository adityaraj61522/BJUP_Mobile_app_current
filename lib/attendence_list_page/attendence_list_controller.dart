import 'dart:async';
import 'dart:io';

import 'package:bjup_application/attendence_list_page/attendence_list_view.dart';
import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/hive_storage_controllers/attendence_list_storage.dart';
import 'package:bjup_application/common/response_models/attendence_record_model/attendence_record_model.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';

class AttendenceListController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  AttendenceStorageService attendenceStorageService =
      AttendenceStorageService();

  AttendanceRecord? attendanceRecord;
  final attendanceDataList = <AttendanceRecord>[].obs;

  UserLoginResponse? userData;

  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;

  final selectedDateTime = DateTime.now().obs;

  final isPunchActive = false.obs;

  final currentLocation = 'Not Available'.obs;
  final selectedLocation = "Office".obs;

  final selectedLatitude = 0.0.obs;
  final selectedLongitude = 0.0.obs;

  final isMarkingAttendance =
      false.obs; // To track if attendance is being marked
  Rx<File?> capturedImage = Rx<File?>(null); // To store the captured image

  final obscureText = true.obs;
  final errorText = ''.obs;

  final RxList<Widget> attendanceCardList = <Widget>[].obs;

  final ApiService apiService = ApiService();

  @override
  void onInit() async {
    super.onInit();
    userData = await sessionManager.getUserData();
    await loadAttendanceData();
    await getCurrentLocation();
  }

  Future<void> loadAttendanceData() async {
    final data = await attendenceStorageService.getAllAttendanceData();
    attendanceDataList.value = data;
    if (attendanceDataList.isNotEmpty &&
        attendanceDataList.any((e) => e.punchedOut == false)) {
      isPunchActive.value = true;
      // attendanceRecord =
      //     attendanceDataList.firstWhere((e) => e.punchedOut == false);
    }
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
        timeLimit: Duration(seconds: 10),
      );
      selectedLatitude.value = position.latitude;
      selectedLongitude.value = position.longitude;
      await getAddressFromCoordinates(
          latitude: position.latitude, longitude: position.longitude);
      // currentLocation.value = "${position.latitude}, ${position.longitude}";
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

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentLocation.value = place.street ?? 'Street name not found';
        print('Full Address: ${place.toString()}');
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

  Future<void> captureImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      capturedImage.value = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
  }

  // Function to mark attendance
  Future<void> saveattendence({required BuildContext context}) async {
    final newAttendanceRecord = AttendanceRecord();
    newAttendanceRecord.attendenceType =
        isPunchActive.value ? "logout" : "login";
    newAttendanceRecord.locationType = selectedLocation.value;
    newAttendanceRecord.gpsLatitude = selectedLatitude.value;
    newAttendanceRecord.gpsLongitude = selectedLongitude.value;

    if (!isPunchActive.value) {
      newAttendanceRecord.inDateTime = selectedDateTime.value.toString();
      newAttendanceRecord.inLocationName = currentLocation.value;
      newAttendanceRecord.punchedOut = false;
    } else {
      newAttendanceRecord.outDateTime = selectedDateTime.value.toString();
      newAttendanceRecord.outLocationName = currentLocation.value;
      newAttendanceRecord.punchedOut = true;
    }

    newAttendanceRecord.picture = capturedImage.value != null
        ? await capturedImage.value!.readAsBytes()
        : null;
    newAttendanceRecord.attendenceIndex = attendanceDataList.length +
        DateTime.now().millisecondsSinceEpoch.toInt();

    bool attendenceMarked = await markAttendance(
      // ignore: use_build_context_synchronously
      context: context,
      newAttendanceRecord: newAttendanceRecord,
    );

    if (attendenceMarked) {
      try {
        if (!isPunchActive.value) {
          attendanceDataList.add(newAttendanceRecord);
          await attendenceStorageService
              .storeAttendanceData(newAttendanceRecord);
          attendanceCardList.value = List.generate(
            attendanceDataList.length,
            (index) {
              final attendanceRecord = attendanceDataList[index];
              return Column(
                children: [
                  AttendenceCard(attendanceRecord: attendanceRecord),
                  SizedBox(
                    height: 15,
                  )
                ],
              );
            },
          ).toList();
        } else {
          attendanceDataList.removeWhere(
              (e) => e.attendenceType == "login" && e.punchedOut == false);
          attendanceDataList.add(newAttendanceRecord);
          await attendenceStorageService
              .replaceAllAttendanceData(attendanceDataList);
          attendanceCardList.value = List.generate(
            attendanceDataList.length,
            (index) {
              final attendanceRecord = attendanceDataList[index];
              return Column(
                children: [
                  AttendenceCard(attendanceRecord: attendanceRecord),
                  SizedBox(
                    height: 15,
                  )
                ],
              );
            },
          ).toList();
        }
        isPunchActive.value = !isPunchActive.value;
      } catch (e) {
        Get.snackbar("Local Storage Error",
            "Failed to save attendance data locally: $e");
        // Optionally revert the isPunchActive state if local storage fails
        // isPunchActive.value = !isPunchActive.value;
      } finally {
        capturedImage.value = null;
      }
    } else {
      // If markAttendance failed, no need to update local storage or toggle state
      capturedImage.value = null;
    }
  }

  Future<bool> markAttendance({
    required BuildContext context,
    required AttendanceRecord newAttendanceRecord,
  }) async {
    isMarkingAttendance.value = true;

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
        isMarkingAttendance.value = false;
        return false;
      }
    }

    try {
      var response = await apiService.post("/markAttendance.php", formData);

      if (response != null && response.statusCode == 200) {
        print('Attendance marked successfully: ${response.data}');
        Get.snackbar("Success", "Attendance marked successfully!");
        closeBottomSheet(context: context);
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
    } finally {
      isMarkingAttendance.value = false;
    }
  }

  void closeBottomSheet({required BuildContext context}) {
    Navigator.pop(context);
  }
}
