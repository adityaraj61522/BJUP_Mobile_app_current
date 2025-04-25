import 'dart:io';

import 'package:bjup_application/attendence_list_page/attendence_list_controller.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/response_models/attendence_record_model/attendence_record_model.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendenceListView extends StatelessWidget {
  final AttendenceListController controller =
      Get.put(AttendenceListController());
  final sessionManager = SessionManager();

  AttendenceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Attendence",
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            color: AppColors.white,
            icon: const Icon(Icons.logout),
            onPressed: () => {
              sessionManager.forceLogout(),
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/images/bjup_logo_zoom.png"),
                fit: BoxFit.fitWidth,
                opacity: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: AppColors.blue,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Punch In Time',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Obx(
                                () => Text(
                                  controller.isPunchActive.value == true &&
                                          controller.attendanceRecord != null &&
                                          controller.attendanceRecord!
                                                  .inDateTime !=
                                              null &&
                                          controller.attendanceRecord!
                                              .inDateTime!.isNotEmpty
                                      ? controller.attendanceRecord!.inDateTime!
                                      : '--',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Punch Out Time',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                '--',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _showBottomSheet(context),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(62, 255, 255, 255),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.login_outlined,
                                    color: AppColors.white,
                                    size: 40,
                                  ),
                                  Spacer(),
                                  Text(
                                    'Punch In',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Obx(() {
                        // The builder function starts here
                        return Column(
                          children: [
                            ...controller.attendanceCardList,
                          ],
                        );
                      }), // The builder function ends here
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            height: 700,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: Obx(() => Text(
                            DateFormat('yyyy-MM-dd')
                                .format(controller.selectedDate.value),
                            style: TextStyle(fontWeight: FontWeight.w700),
                          )),
                    ),
                    GestureDetector(
                      onTap: () => controller.changeDate(context),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Time Picker Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Punch In Time',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.selectedTime.value.format(context),
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: Colors.blue),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.changeTime(context),
                      child:
                          Icon(Icons.access_time, color: Colors.blue, size: 40),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                // Location Picker Row
                Row(
                  children: [
                    Expanded(
                      child: Text('Current Location',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: Obx(() => Text(
                            controller.currentLocation.value,
                            style: TextStyle(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                    GestureDetector(
                      onTap: () => controller.getCurrentLocation(),
                      child: Icon(Icons.my_location,
                          color: Colors.green, size: 40),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Location:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => RadioListTile<String>(
                                title: Text("Office"),
                                value: "Office",
                                groupValue: controller.selectedLocation.value,
                                onChanged: (value) =>
                                    controller.changeLocation(value!),
                              )),
                        ),
                        Expanded(
                          child: Obx(() => RadioListTile<String>(
                                title: Text("Field"),
                                value: "Field",
                                groupValue: controller.selectedLocation.value,
                                onChanged: (value) =>
                                    controller.changeLocation(value!),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                Center(
                  child: ImagePickerWidget(),
                ),
                SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                      ),
                      onPressed: () =>
                          controller.saveattendence(context: context),
                      child: Text(
                        controller.isPunchActive.isTrue
                            ? "Punch Out"
                            : "Punch In",
                        style: TextStyle(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final ValueNotifier<File?> imageNotifier = ValueNotifier<File?>(null);

  ImagePickerWidget({Key? key}) : super(key: key);

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    bool permissionGranted = await _requestPermissions(source);

    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source == ImageSource.gallery
              ? "Gallery access denied! Enable it in settings."
              : "Camera access denied! Enable it in settings."),
        ),
      );
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // 🔍 Debugging: Print file path
      print("Picked Image Path: ${pickedFile.path}");

      if (await imageFile.exists()) {
        imageNotifier.value = imageFile;
        imageNotifier.notifyListeners(); // 🔄 Ensure UI updates
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Image file not found!")),
        );
      }
    } else {
      print("Image picking cancelled.");
    }
  }

  Future<bool> _requestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await Permission.camera.request().isGranted;
    } else if (source == ImageSource.gallery) {
      if (Platform.isAndroid) {
        if (await Permission.photos.request().isGranted) return true;
        if (await Permission.mediaLibrary.request().isGranted) return true;
        if (await Permission.storage.request().isGranted) return true;
      } else {
        if (await Permission.photos.request().isGranted) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<File?>(
          valueListenable: imageNotifier,
          builder: (context, image, child) {
            return image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey[600]),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                  );
          },
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, context),
              icon: Icon(Icons.photo_library),
              label: Text("Gallery"),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera, context),
              icon: Icon(Icons.camera_alt),
              label: Text("Camera"),
            ),
          ],
        ),
      ],
    );
  }
}

class AttendenceCard extends StatelessWidget {
  final AttendanceRecord attendanceRecord;

  const AttendenceCard({super.key, required this.attendanceRecord});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(2, 4),
          ),
        ],
        color: AppColors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text(
                  attendanceRecord.inDateTime != null
                      ? DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(attendanceRecord.inDateTime!))
                      : '--',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Punch In Time',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text(
                  attendanceRecord.inDateTime != null
                      ? DateFormat('hh:mm a').format(
                          DateTime.parse(attendanceRecord.inDateTime!),
                        )
                      : '--',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Punch Out Time',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text(
                  attendanceRecord.outDateTime != null &&
                          attendanceRecord.outDateTime!.isNotEmpty
                      ? DateFormat('hh:mm a').format(
                          DateTime.parse(attendanceRecord.outDateTime!),
                        )
                      : '--',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text(
                  attendanceRecord.inLocationName != null &&
                          attendanceRecord.inLocationName!.isNotEmpty
                      ? attendanceRecord.inLocationName!
                      : '--',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
