import 'dart:io';

import 'package:bjup_application/attendence_list_page/attendence_list_controller.dart';
import 'package:bjup_application/common/notification_card.dart';
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
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // _buildBackgroundImage("lib/assets/images/bjup_logo_zoom.png"),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return buildView(context: context);
              }
            }),
          ),
          NotificationCardsList(controller: controller.notificationController),
        ],
      ),
    );
  }

  Widget buildView({required BuildContext context}) {
    return Column(
      children: [
        _buildPunchInOutCard(context),
        const SizedBox(height: 15),
        Expanded(
          child: SingleChildScrollView(
            child: Obx(() => Column(
                  // ignore: invalid_use_of_protected_member
                  children: controller.attendanceCardList.value,
                )),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        "attendance".tr,
        style: TextStyle(color: AppColors.white),
      ),
      backgroundColor: AppColors.primary2,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              sessionManager.forceLogout();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      color: AppColors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('logout'.tr),
                  ],
                ),
              ),
            ];
          },
          icon: Icon(
            Icons.more_vert,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  // Widget _buildBackgroundImage(String imagePath) {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         image: AssetImage(imagePath),
  //         fit: BoxFit.fitWidth,
  //         opacity: 0.3,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPunchInOutCard(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: AppColors.primary2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildPunchTimeColumn(
                'Punch In Time', controller.activeInTime.value)),
          ),
          Expanded(
            child: Obx(() => _buildPunchTimeColumn(
                'Punch Out Time', controller.activeOutTime.value)),
          ),
          Expanded(
            child: _buildPunchButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchTimeColumn(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          title.tr, // 'punch_in_time'.tr or 'punch_out_time'.tr
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPunchButton(BuildContext context) {
    return Obx(() {
      final bool isEnabled = controller.isPunchButtonEnabled();
      return InkWell(
        onTap: isEnabled ? () => _showBottomSheet(context) : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(62, 255, 255, 255),
              ),
              borderRadius: BorderRadius.circular(20),
              color: isEnabled ? null : Colors.grey,
            ),
            child: Column(
              children: [
                Icon(
                  controller.isPunchActive.value
                      ? Icons.logout_outlined
                      : Icons.login_outlined,
                  color: AppColors.white,
                  size: 40,
                ),
                const Spacer(),
                Text(
                  controller.isPunchActive.value
                      ? 'punch_out'.tr
                      : 'punch_in'.tr,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDatePickerRow(context),
              const SizedBox(height: 10),
              _buildTimePickerRow(context),
              const SizedBox(height: 20),
              _buildLocationPickerRow(),
              const SizedBox(height: 20),
              _buildLocationRadioButtons(),
              const Center(child: ImagePickerWidget()),
              Obx(() {
                if (controller.isImageCaptured.value) {
                  return Center(
                    child: Text(
                      "capture_image".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              const SizedBox(height: 9),
              _buildBottomSheetButtons(context),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
    );
  }

  Widget _buildDatePickerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'date'.tr,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Obx(() => Text(
                DateFormat('yyyy-MM-dd').format(controller.selectedDate.value),
                style: const TextStyle(fontWeight: FontWeight.w700),
              )),
        ),
        GestureDetector(
          onTap: () => controller.changeDate(context),
          child: const Icon(
            Icons.calendar_month_outlined,
            color: Colors.blue,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            controller.isPunchActive.value
                ? 'punch_out_time'.tr
                : 'punch_in_time'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Obx(
            () => Text(
              controller.selectedTime.value.format(context),
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.blue),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => controller.changeTime(context),
          child: const Icon(Icons.access_time, color: Colors.blue, size: 40),
        ),
      ],
    );
  }

  Widget _buildLocationPickerRow() {
    return Row(
      children: [
        Expanded(
          child: Text('current_location'.tr,
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: Obx(() => Text(
                controller.currentLocation.value,
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              )),
        ),
        GestureDetector(
          onTap: () => controller.getCurrentLocation(),
          child: const Icon(Icons.my_location,
              color: AppColors.primary1, size: 40),
        ),
      ],
    );
  }

  Widget _buildLocationRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "location".tr,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Obx(() => RadioListTile<String>(
                    title: Text("office".tr),
                    value: "Office",
                    groupValue: controller.selectedLocation.value,
                    onChanged: (value) => controller.changeLocation(value!),
                  )),
            ),
            Expanded(
              child: Obx(() => RadioListTile<String>(
                    title: Text("field".tr),
                    value: "Field",
                    groupValue: controller.selectedLocation.value,
                    onChanged: (value) => controller.changeLocation(value!),
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSheetButtons(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => Get.back(),
          child: Text("close".tr),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary2,
          ),
          onPressed: () {
            controller.saveattendence(context: context);
            Get.back();
          },
          child: Obx(() => Text(
                controller.isPunchActive.isTrue
                    ? "punch_out".tr
                    : "punch_in".tr,
                style: const TextStyle(color: AppColors.white),
              )),
        ),
      ],
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({Key? key}) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  final AttendenceListController controller =
      Get.find<AttendenceListController>();

  @override
  void initState() {
    super.initState();
    if (controller.capturedImage.value != null) {
      _image = controller.capturedImage.value;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        controller.capturedImage.value = _image;
      });
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

  Future<void> _handleImagePick(
      ImageSource source, BuildContext context) async {
    bool permissionGranted = await _requestPermissions(source);
    if (permissionGranted) {
      await _pickImage(source);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source == ImageSource.gallery
              ? "Gallery access denied! Enable it in settings."
              : "Camera access denied! Enable it in settings."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => controller.capturedImage.value != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  controller.capturedImage.value!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder(Icons.broken_image);
                  },
                ),
              )
            : _buildImagePlaceholder(Icons.image)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _handleImagePick(ImageSource.gallery, context),
              icon: const Icon(Icons.photo_library),
              label: Text("gallery".tr),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _handleImagePick(ImageSource.camera, context),
              icon: const Icon(Icons.camera_alt),
              label: Text("camera".tr),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(IconData icon) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 50, color: Colors.grey[600]),
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
      margin: const EdgeInsets.only(bottom: 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttendanceDetailRow(
              'date'.tr,
              attendanceRecord.inDateTime != null
                  ? DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(attendanceRecord.inDateTime!))
                  : '--'),
          const SizedBox(height: 10),
          _buildAttendanceDetailRow(
              'punch_in_time'.tr,
              attendanceRecord.inDateTime != null
                  ? DateFormat('hh:mm a')
                      .format(DateTime.parse(attendanceRecord.inDateTime!))
                  : '--'),
          const SizedBox(height: 10),
          _buildAttendanceDetailRow(
              'punch_out_time'.tr,
              attendanceRecord.outDateTime != null &&
                      attendanceRecord.outDateTime!.isNotEmpty
                  ? DateFormat('hh:mm a')
                      .format(DateTime.parse(attendanceRecord.outDateTime!))
                  : '--'),
          const SizedBox(height: 10),
          _buildAttendanceDetailRow(
              'location_in'.tr, attendanceRecord.inLocationName ?? '--'),
          const SizedBox(height: 10),
          _buildAttendanceDetailRow(
              'location_out'.tr, attendanceRecord.outLocationName ?? '--'),
          const SizedBox(height: 10),
          _buildAttendanceDetailRow(
              'status'.tr,
              attendanceRecord.punchedOut != null &&
                      attendanceRecord.punchedOut == true
                  ? 'Completed'
                  : 'Active'),
        ],
      ),
    );
  }

  Widget _buildAttendanceDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
