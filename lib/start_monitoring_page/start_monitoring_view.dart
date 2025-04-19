import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/start_monitoring_page/start_monitoring_Controller.dart';
import 'package:bjup_application/survey_form/survey_form_view.dart';
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
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    controller.onExistingInterviewClicked(),
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
                            SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    controller.onAddBeneficeryClicked(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: Text(
                                  "Add Beneficery",
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Obx(() => buildInterviewTypeSelector()),
                        // Obx(() => Text(controller.selectedInterviewType.value)),
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
            flex: 2,
            child: DropdownButton<String>(
              value: controller.selectedQuestionSet.value.isEmpty
                  ? null
                  : controller.selectedQuestionSet.value,
              hint: const Text('Select an item'),
              items: controller.questionSetList.map((item) {
                return DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    item.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.changeQuestionSetType(value);
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
            flex: 2,
            child: DropdownButton<String>(
              value: controller.selectedVillage.value.isEmpty
                  ? null
                  : controller.selectedVillage.value,
              hint: const Text('Select an item'),
              items: controller.villageList.map((item) {
                return DropdownMenuItem(
                  value: item.villageId,
                  child: Column(
                    children: [
                      Text(
                        item.villageName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.changeVillage(value);
              },
            ),
          )
        : Center(
            child: Text(
              'No interview type List Exist',
              style: TextStyle(color: AppColors.gray),
            ),
          );
    final Widget beneficiaryDropdown = controller.beneficiaryList.isNotEmpty
        ? Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: controller.selectedBeneficiary.value.isEmpty
                  ? null
                  : controller.selectedBeneficiary.value,
              hint: const Text('Select an item'),
              items: controller.beneficiaryList.map((item) {
                return DropdownMenuItem(
                  value: item.beneficiaryId,
                  child: Column(
                    children: [
                      Text(
                        item.beneficiaryName ?? 'no name',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.changeBeneficery(value);
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
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
              flex: 1,
              child: Text(
                "Village: ",
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            villageDropdown,
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                "Beneficary: ",
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            beneficiaryDropdown,
          ],
        ),
        Divider(),
        Obx(
          () {
            if (controller.selectedQuestionFormSet.isNotEmpty) {
              return SurveyPage(
                formQuestions: controller.selectedQuestionFormSet,
              );
            }
            return SizedBox.shrink();
          },
        ),
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
