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
        title: Text(
          "download_village_data".tr,
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary1,
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
            // Container(
            //   padding: EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage(
            //           "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
            //       fit: BoxFit.fitWidth, // Covers the entire screen
            //       opacity: 0.1,
            //     ),
            //   ),
            // ),
            SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary1,
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProjectMonitoringCard(),
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
                  backgroundColor: AppColors.primary1,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "download_button".tr,
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

  Widget _buildProjectMonitoringCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "greeting".trParams({'s': controller.userData?.username ?? ''}),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildProjectDetailRow(
              'office_id'.tr,
              controller.officeName,
            ),
            const SizedBox(height: 10),
            _buildProjectDetailRow(
              'project_name'.tr,
              controller.projectTitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            '$label :',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
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
                'no_interview_type_list'.tr,
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "interview_type".tr,
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
    final List<Widget> villageCheckboxes = controller.villages != null &&
            controller.villages!.isNotEmpty
        ? controller.villages!
            .map(
              (village) => Obx(() {
                return CheckboxListTile(
                  title: Text(village.villageName),
                  value: controller.selectedVillageList
                      .contains(village.villageId),
                  onChanged: (bool? value) {
                    if (value != null) {
                      if (value) {
                        controller.selectedVillageList.add(village.villageId);
                      }
                    }
                  },
                  visualDensity: VisualDensity.compact,
                );
              }),
            )
            .toList()
        : [
            Center(
              child: Text(
                'no_village_list'.tr,
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "villages".tr,
          style: TextStyle(color: AppColors.gray),
        ),
        Wrap(
          spacing: 8.0, // Optional: Add spacing between checkboxes horizontally
          runSpacing:
              4.0, // Optional: Add spacing between rows of checkboxes vertically
          children: [
            ...villageCheckboxes,
          ],
        )
      ],
    );
  }
}
