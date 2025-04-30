import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/download_question_set_page/download_question_set_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadQuestionSetView extends StatelessWidget {
  DownloadQuestionSetView({super.key});

  final controller = Get.put(DownloadQuestionSetController());

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Download Question Set",
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
                        buildLanguageSelector(),
                        Obx(() => Text(controller.selectedLanguage.value)),
                        buildReportTypeSelector(),
                        Obx(() => Text(controller.selectedReportType.value)),
                        buildQuestionSetSelector(),
                        Obx(() => Text(controller.selectedQuestionSet.value)),
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
              "Hi ${controller.userData?.username}!!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildProjectDetailRow(
              'Office Id',
              controller.officeName,
            ),
            const SizedBox(height: 10),
            _buildProjectDetailRow(
              'Project Name',
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

  Widget buildLanguageSelector() {
    final List<Widget> languageList =
        controller.languages != null && controller.languages!.isNotEmpty
            ? controller.languages!
                .map(
                  (lang) => RadioListTile<String>(
                    title: Text(lang.language),
                    value: lang.key,
                    groupValue: controller.selectedLanguage.value,
                    onChanged: (value) => controller.changeLanguage(value!),
                  ),
                )
                .toList()
            : [
                Center(
                  child: Text(
                    'No Question List Exist',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
              ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Language",
          style: TextStyle(color: AppColors.gray),
        ),
        Wrap(
          children: [
            ...languageList,
          ],
        )
      ],
    );
  }

  Widget buildReportTypeSelector() {
    final List<Widget> reportTypeList =
        controller.reportType != null && controller.reportType!.isNotEmpty
            ? controller.reportType!
                .map(
                  (report) => RadioListTile<String>(
                    title: Text(report.type),
                    value: report.id,
                    groupValue: controller.selectedReportType.value,
                    onChanged: (value) => controller.changeReportType(value!),
                  ),
                )
                .toList()
            : [
                Center(
                  child: Text(
                    'No Question List Exist',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
              ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Report Type",
          style: TextStyle(color: AppColors.gray),
        ),
        Wrap(
          children: [
            ...reportTypeList,
          ],
        )
      ],
    );
  }

  Widget buildQuestionSetSelector() {
    final List<Widget> questionSetList =
        controller.questionSet != null && controller.questionSet!.isNotEmpty
            ? controller.questionSet!
                .map(
                  (set) => RadioListTile<String>(
                    title: Text(set.title),
                    value: set.id,
                    groupValue: controller.selectedQuestionSet.value,
                    onChanged: (value) => controller.changeQuestionSet(value!),
                  ),
                )
                .toList()
            : [
                Center(
                  child: Text(
                    'No Question List Exist',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
              ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question Set",
          style: TextStyle(color: AppColors.gray),
        ),
        Wrap(
          children: [
            ...questionSetList,
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
