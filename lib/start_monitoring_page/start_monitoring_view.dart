import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/start_monitoring_page/start_monitoring_Controller.dart';
import 'package:bjup_application/survey_form/survey_form_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';

class StartMonitoringView extends StatelessWidget {
  StartMonitoringView({super.key});

  final controller = Get.put(
    StartMonitoringController(),
    permanent: false,
    tag: DateTime.now().microsecondsSinceEpoch.toString(),
  );

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
                            if (controller.familyTypeExist.value) ...[
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
        child: DropdownSearch<String>(
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          items: controller.beneficiaryOrCBOList.map((item) {
            if (item is BeneficiaryData) {
              return "${item.beneficiaryName ?? ''} (${item.guardian})";
            } else if (item is CBOData) {
              return item.cboname;
            }
            return "";
          }).toList(),
          selectedItem: controller.selectedBeneficiary.value.isEmpty
              ? null
              : controller.getBeneficiaryOrCBOName(),
          onChanged: (String? value) {
            if (value != null) {
              final selectedItem = controller.beneficiaryOrCBOList.firstWhere(
                (item) {
                  if (item is BeneficiaryData) {
                    return "${item.beneficiaryName ?? ''} (${item.guardian})" ==
                        value;
                  } else if (item is CBOData) {
                    return item.cboname == value;
                  }
                  return false;
                },
              );

              if (selectedItem is BeneficiaryData) {
                controller.changeBeneficery(selectedItem.beneficiaryId);
              } else if (selectedItem is CBOData) {
                controller.changeBeneficery(selectedItem.cboid);
              }
            }
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: controller.selectedInterviewId.value == "44"
                  ? 'select_beneficiary'.tr
                  : controller.selectedInterviewId.value == "50"
                      ? 'select_institute'.tr
                      : 'select_cbo'.tr,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
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
                    : controller.selectedInterviewId.value == "50"
                        ? "institute_label".tr
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
              beneficeryName: controller.getBeneficiaryOrCBOName(),
              projectName: controller.projectTitle,
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
            // Text(
            //   "hi_user"
            //       .trParams({'username': controller.userData?.username ?? ''}),
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 10),
            Obx(() {
              return _buildProjectDetailRow(
                'office_id_label'.tr,
                controller.officeName.value,
              );
            }),
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
}
