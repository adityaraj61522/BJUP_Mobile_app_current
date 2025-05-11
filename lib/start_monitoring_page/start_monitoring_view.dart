import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/start_monitoring_page/start_monitoring_Controller.dart';
import 'package:bjup_application/survey_form/survey_form_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartMonitoringView extends StatelessWidget {
  StartMonitoringView({super.key});

  final controller = Get.put(StartMonitoringController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "start_monitoring_title".tr,
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary1,
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
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    controller.onExistingInterviewClicked(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary1,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: Text(
                                  "current_interview".tr,
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
                                  backgroundColor: AppColors.primary1,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: Text(
                                  "add_beneficery".tr,
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Obx(() => Column(
                              children: [
                                if (controller.showSelector.value) ...{
                                  buildInterviewTypeSelector(),
                                },
                              ],
                            )),
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
    // Question Set Dropdown
    final Widget questionSetDropdown = controller.questionSetList.isNotEmpty
        ? Expanded(
            flex: 2,
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedQuestionSet.value.isEmpty
                  ? null
                  : controller.selectedQuestionSet.value,
              hint: Text('select_question_set'.tr),
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
        : Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'no_question_set_available'.tr,
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          );

    // Village Dropdown
    final Widget villageDropdown = controller.villageList.isNotEmpty
        ? Expanded(
            flex: 2,
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedVillage.value.isEmpty
                  ? null
                  : controller.selectedVillage.value,
              hint: Text('select_village'.tr),
              items: controller.villageList.map((item) {
                return DropdownMenuItem(
                  value: item.villageId,
                  child: Text(
                    item.villageName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.changeVillage(value);
              },
            ),
          )
        : Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'no_villages_available'.tr,
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          );

    // Beneficiary/CBO Dropdown
    final Widget beneficiaryDropdown = Obx(() {
      if (controller.beneficiaryOrCBOList.isEmpty) {
        return Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'no_data_available'.tr,
              style: TextStyle(color: AppColors.gray),
            ),
          ),
        );
      }

      return Expanded(
        flex: 2,
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedBeneficiary.value.isEmpty
              ? null
              : controller.selectedBeneficiary.value,
          hint: Text(controller.selectedInterviewId.value == "44"
              ? 'select_beneficiary'.tr
              : 'select_cbo'.tr),
          items: controller.beneficiaryOrCBOList
              .map((item) {
                if (item is BeneficiaryData) {
                  return DropdownMenuItem(
                    value: item.beneficiaryId,
                    child: Text(
                      item.beneficiaryName ?? 'No Name',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                } else if (item is CBOData) {
                  return DropdownMenuItem(
                    value: item.cboid,
                    child: Text(
                      item.cboname,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }
                return null;
              })
              .whereType<DropdownMenuItem<String>>()
              .toList(),
          onChanged: (value) {
            if (value != null) controller.changeBeneficery(value);
          },
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                "question_set_label".tr,
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            questionSetDropdown,
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                "village_label".tr,
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            villageDropdown,
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                controller.selectedInterviewId.value == "44"
                    ? "beneficiary_label".tr
                    : "cbo_label".tr,
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            beneficiaryDropdown,
          ],
        ),
        const Divider(height: 32),
        Obx(() {
          if (controller.selectedQuestionFormSet.isNotEmpty) {
            return SurveyPage(
              formQuestions: controller.selectedQuestionFormSet,
              questionSetId: controller.selectedQuestionSet.value,
              userId: controller.userData!.userId,
              beneficeryId: controller.selectedBeneficiary.value,
              projectId: controller.selectedProject.value,
              questionSetName: controller.questionSetList
                  .firstWhere((element) =>
                      element.id == controller.selectedQuestionSet.value)
                  .title,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
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
              "hi_user"
                  .trParams({'username': controller.userData?.username ?? ''}),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildProjectDetailRow(
              'office_id_label'.tr,
              controller.officeName,
            ),
            const SizedBox(height: 10),
            _buildProjectDetailRow(
              'project_name_label'.tr,
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

  Widget buildProjectDetails() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "project_name_prefix".tr,
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
              "office_name_prefix".tr,
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
