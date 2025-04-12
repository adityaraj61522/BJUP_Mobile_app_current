import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/start_monitoring_page/start_monitoring_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartMonitoringView extends StatelessWidget {
  StartMonitoringView({super.key});

  final controller = Get.put(StartMonitoringController());

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Start Monitoring",
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.green,
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
            icon: const Icon(
              Icons.logout,
              color: AppColors.white,
            ),
            onPressed: () => {
              sessionManager.forceLogout(),
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
                  fit: BoxFit.fitWidth, // Covers the entire screen
                  opacity: 0.1,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.green,
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        buildProjectDetails(),
                        Divider(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: () =>
                                controller.onExistingInterviewClicked(),
                            iconAlignment: IconAlignment.end,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              "Existing Interview",
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Obx(() => buildInterviewTypeSelector()),
                        Obx(() => Text(controller.selectedInterviewType.value)),
                        buildVillageSelector(),
                        Obx(() => Text(controller.selectedVillage.value)),
                        SizedBox(height: 200),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInterviewTypeSelector() {
    final Widget questionSetDropdown = controller.questionSetList.isNotEmpty
        ? Expanded(
            child: DropdownButton<String>(
              // value: selectedValue,
              hint: const Text('Select an item'),
              items: controller.questionSetList.map((item) {
                return DropdownMenuItem(
                  value: item.id,
                  child: Text(item.title),
                );
              }).toList(),
              onChanged: (value) {
                // if (value != null) onChanged(value);
              },
            ),
          )
        : Center(
            child: Text(
              'No interview type List Exist',
              style: TextStyle(color: AppColors.gray),
            ),
          );
    final Widget villageDropdown = controller.villageList.isNotEmpty
        ? Expanded(
            child: DropdownButton<String>(
              // value: selectedValue,
              hint: const Text('Select an item'),
              items: controller.villageList.map((item) {
                return DropdownMenuItem(
                  value: item.villageId,
                  child: Text(item.villageName),
                );
              }).toList(),
              onChanged: (value) {
                // if (value != null) onChanged(value);
              },
            ),
          )
        : Center(
            child: Text(
              'No interview type List Exist',
              style: TextStyle(color: AppColors.gray),
            ),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Question Set: ",
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            questionSetDropdown,
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "Village: ",
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            villageDropdown,
          ],
        ),
      ],
    );
  }

  Widget buildVillageSelector() {
    final List<Widget> villageTypeList =
        controller.villages != null && controller.villages!.isNotEmpty
            ? controller.villages!
                .map(
                  (village) => RadioListTile<String>(
                    title: Text(village.villageName),
                    value: village.villageId,
                    groupValue: controller.selectedVillage.value,
                    onChanged: (value) => controller.changeVillage(value!),
                  ),
                )
                .toList()
            : [
                Center(
                  child: Text(
                    'No village List Exist',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
              ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Village's",
          style: TextStyle(color: AppColors.gray),
        ),
        Wrap(
          children: [
            ...villageTypeList,
          ],
        )
      ],
    );
  }

  Widget buildProjectDetails() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Project name:",
              style: TextStyle(color: AppColors.gray),
            ),
            Text(
              controller.projectTitle,
              style: TextStyle(
                  color: AppColors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Office name:",
              style: TextStyle(color: AppColors.gray),
            ),
            Text(
              controller.officeName,
              style: TextStyle(
                  color: AppColors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
