import 'dart:io';

import 'package:bjup_application/attendence_list_page/attendence_list_controller.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendenceListView extends StatelessWidget {
  final AttendenceListController controller =
      Get.put(AttendenceListController());

  AttendenceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Attendence List",
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.blue,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
                fit: BoxFit.fitWidth, // Covers the entire screen
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
                              Text(
                                '{time}',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                '{time}',
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
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                8), // Optional: Adds rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gray.withOpacity(
                                    0.5), // Shadow color with opacity
                                spreadRadius: 2, // How much the shadow spreads
                                blurRadius: 5, // Softness of the shadow
                                offset: Offset(2, 4), // Shadow position (X, Y)
                              ),
                            ],
                            color: AppColors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  )),
                                  Expanded(
                                      child: Text(
                                    '{date}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Punch In Time',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  )),
                                  Expanded(
                                      child: Text(
                                    '{time}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Punch Out Time',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  )),
                                  Expanded(
                                      child: Text(
                                    '{time}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Location',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  )),
                                  Expanded(
                                      child: Text(
                                    '{location}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Spacer(),
                  // Text(
                  //   'log_in'.tr, // Translatable text
                  //   style: const TextStyle(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColors.black,
                  //   ),
                  // ),
                  // const SizedBox(height: 30),
                  // TextField(
                  //   controller: controller.usernameController,
                  //   decoration: InputDecoration(
                  //     prefixIcon:
                  //         const Icon(Icons.person, color: AppColors.black),
                  //     hintText: 'username'.tr,
                  //     hintStyle: const TextStyle(color: AppColors.black),
                  //     enabledBorder: const UnderlineInputBorder(
                  //       borderSide: BorderSide(color: AppColors.black),
                  //     ),
                  //     focusedBorder: const UnderlineInputBorder(
                  //       borderSide: BorderSide(color: AppColors.orange),
                  //     ),
                  //   ),
                  //   style: const TextStyle(color: AppColors.black),
                  // ),
                  // const SizedBox(height: 20),
                  // Obx(() => TextField(
                  //       controller: controller.passwordController,
                  //       obscureText: controller.obscureText.value,
                  //       decoration: InputDecoration(
                  //         prefixIcon:
                  //             const Icon(Icons.lock, color: AppColors.black),
                  //         suffixIcon: IconButton(
                  //           icon: Icon(
                  //             controller.obscureText.value
                  //                 ? Icons.visibility_off
                  //                 : Icons.visibility,
                  //             color: AppColors.black,
                  //           ),
                  //           onPressed: () =>
                  //               controller.togglePasswordVisibility(),
                  //         ),
                  //         hintText: 'password'.tr, // Translatable text
                  //         hintStyle: const TextStyle(color: AppColors.black),
                  //         enabledBorder: const UnderlineInputBorder(
                  //           borderSide: BorderSide(color: AppColors.black),
                  //         ),
                  //         focusedBorder: const UnderlineInputBorder(
                  //           borderSide: BorderSide(color: AppColors.orange),
                  //         ),
                  //       ),
                  //       style: const TextStyle(color: AppColors.black),
                  //     )),
                  // const SizedBox(height: 10),
                  // Obx(() => controller.errorText.value.isNotEmpty
                  //     ? Text(
                  //         controller.errorText.value,
                  //         style: const TextStyle(
                  //             color: AppColors.red, fontSize: 14),
                  //       )
                  //     : Container()),
                  // const SizedBox(height: 20),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.black,
                  //       padding: const EdgeInsets.symmetric(vertical: 15),
                  //     ),
                  //     onPressed: () => controller.login(),
                  //     child: Text(
                  //       'login'.tr, // Translatable text
                  //       style: const TextStyle(
                  //           fontSize: 18, color: AppColors.white),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  // Spacer(),
                  // Center(
                  //   child: ElevatedButton(
                  //     style: ButtonStyle(
                  //       backgroundColor:
                  //           WidgetStateProperty.all(AppColors.black), // Updated
                  //     ),
                  //     onPressed: () {
                  //       var locale = Get.locale == const Locale('en', 'US')
                  //           ? const Locale('hi', 'IN')
                  //           : const Locale('en', 'US');
                  //       Get.updateLocale(locale);
                  //     },
                  //     child: Text(
                  //       'Switch Language',
                  //       style: TextStyle(color: AppColors.white),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 50),
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
        return Container(
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
                    onTap: () => controller.selectDate(context),
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
                    onTap: () => controller.selectTime(context),
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
                    child:
                        Icon(Icons.my_location, color: Colors.green, size: 40),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Close bottom sheet
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }
  // void _showBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(20),
  //         height: 250,
  //         child: Expanded(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.max,
  //             children: [
  //               Row(
  //                 children: [
  //                   Expanded(
  //                       child: Text(
  //                     'Date',
  //                     style: TextStyle(fontWeight: FontWeight.w700),
  //                   )),
  //                   Expanded(
  //                       child: Text(
  //                     '{date}',
  //                     style: TextStyle(fontWeight: FontWeight.w700),
  //                   )),
  //                   const Icon(
  //                     Icons.calendar_month_outlined,
  //                     color: AppColors.blue,
  //                     size: 40,
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 10),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                       child: Text(
  //                     'Punch In Time',
  //                     style: TextStyle(fontWeight: FontWeight.w700),
  //                   )),
  //                   Expanded(
  //                       child: Text(
  //                     '{time}',
  //                     style: TextStyle(fontWeight: FontWeight.w700),
  //                   ))
  //                 ],
  //               ),
  //               SizedBox(height: 20),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context); // Close the bottom sheet
  //                 },
  //                 child: Text("Close"),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
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
