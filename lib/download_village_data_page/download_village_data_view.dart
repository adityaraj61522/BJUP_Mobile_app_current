import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/download_village_data_page/download_village_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadVillageDataView extends StatelessWidget {
  DownloadVillageDataView({super.key});

  final controller = Get.put(DownloadVillageDataController());

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Download Village Data",
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
            Get.toNamed(
              AppRoutes.projectActionList,
              arguments: {
                "projectId": controller.selectedProject.value,
                "projectTitle": controller.projectTitle,
              },
            );
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
                        buildInterviewTypeSelector(),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () => controller.onDownloadQuestionSetClicked(),
                iconAlignment: IconAlignment.end,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Download",
                  style: TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInterviewTypeSelector() {
    final List<Widget> interviewTypeList = controller.interviewTypes != null &&
            controller.interviewTypes!.isNotEmpty
        ? controller.interviewTypes!
            .map(
              (interviewType) => RadioListTile<String>(
                title: Text(interviewType.type),
                value: interviewType.id,
                groupValue: controller.selectedInterviewType.value,
                onChanged: (value) => controller.changeInterviewType(value!),
              ),
            )
            .toList()
        : [
            Center(
              child: Text(
                'No Interview Type List Exist',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Interview Type",
          style: TextStyle(color: AppColors.gray),
        ),
        Wrap(
          children: [
            ...interviewTypeList,
          ],
        )
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
