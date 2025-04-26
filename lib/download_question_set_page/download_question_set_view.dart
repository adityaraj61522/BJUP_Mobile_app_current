import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/download_question_set_page/download_question_set_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadQuestionSetView extends GetView<DownloadQuestionSetController> {
  final sessionManager = Get.find<SessionManager>();

  DownloadQuestionSetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                return controller.isLoading.value
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.green))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProjectDetails(),
                          const SizedBox(height: 10),
                          Text(controller.selectedLanguage.value),
                          const SizedBox(height: 20),
                          _buildReportTypeSelector(),
                          const SizedBox(height: 10),
                          Text(controller.selectedReportType.value),
                          const SizedBox(height: 20),
                          _buildQuestionSetSelector(),
                          const SizedBox(height: 10),
                          Text(controller.selectedQuestionSet.value),
                          const SizedBox(height: 200),
                        ],
                      );
              }),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildDownloadButton(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Download Question Set",
        style: TextStyle(color: AppColors.white),
      ),
      backgroundColor: AppColors.green,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Get.back(result: {
          "projectId": controller.selectedProject.value,
          "projectTitle": controller.projectTitle,
        }),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.white),
          onPressed: () => sessionManager.forceLogout(),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/assets/images/bjup_logo_zoom.png"),
          fit: BoxFit.fitWidth,
          opacity: 0.1,
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Report Type", style: TextStyle(color: AppColors.gray)),
        Obx(() => Wrap(
              children: controller.reportType
                      ?.map(
                        (report) => RadioListTile<String>(
                          title: Text(report.type),
                          value: report.id,
                          groupValue: controller.selectedReportType.value,
                          onChanged: (value) => controller.changeReportType,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList() ??
                  [
                    const Center(
                        child: Text('No Report Types Available',
                            style: TextStyle(color: AppColors.gray)))
                  ],
            )),
      ],
    );
  }

  Widget _buildQuestionSetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Question Set", style: TextStyle(color: AppColors.gray)),
        Obx(() => Wrap(
              children: controller.questionSet
                      ?.map(
                        (set) => RadioListTile<String>(
                          title: Text(set.title),
                          value: set.id,
                          groupValue: controller.selectedQuestionSet.value,
                          onChanged: (value) => controller.changeQuestionSet,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList() ??
                  [
                    const Center(
                        child: Text('No Question Sets Available',
                            style: TextStyle(color: AppColors.gray)))
                  ],
            )),
      ],
    );
  }

  Widget _buildProjectDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow("Project name:", controller.projectTitle),
        _buildDetailRow("Office name:", controller.officeName),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.gray)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return ElevatedButton(
      onPressed: controller.onDownloadQuestionSetClicked,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        "Download",
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
