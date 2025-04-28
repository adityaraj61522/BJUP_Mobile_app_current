import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/sync_survey_page/sync_survey_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SyncSurveyView extends StatelessWidget {
  SyncSurveyView({super.key});

  final SyncSurveyController controller =
      Get.put(SyncSurveyController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sync Surveys",
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
                "projectId": controller.projectId,
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
      body: Stack(
        children: [
          // Container(
          //   padding: EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage(
          //           "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
          //       fit: BoxFit.fitWidth, // Covers the entire screen
          //       opacity: 0.3,
          //     ),
          //   ),
          // ),
          Obx(
            () => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            {controller.selectedSyncedSurveys.value = false},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              controller.selectedSyncedSurveys.value == true
                                  ? AppColors.white
                                  : AppColors.primary1,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: BorderSide(
                              color: AppColors.primary1,
                              width: 0,
                            ),
                          ),
                        ),
                        child: Text(
                          'Locally Saved',
                          style: TextStyle(
                              color:
                                  controller.selectedSyncedSurveys.value == true
                                      ? AppColors.primary1
                                      : AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            {controller.selectedSyncedSurveys.value = true},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              controller.selectedSyncedSurveys.value == false
                                  ? AppColors.white
                                  : AppColors.primary1,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: BorderSide(
                              color: AppColors.primary1,
                              width: 0,
                            ),
                          ),
                        ),
                        child: Text(
                          'Synced Surveys',
                          style: TextStyle(
                              color: controller.selectedSyncedSurveys.value ==
                                      false
                                  ? AppColors.primary1
                                  : AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Obx(
                      () => Column(
                        children: [
                          if (controller.selectedSyncedSurveys.value ==
                              true) ...{
                            ...List.generate(
                              controller.synkedSurveyData.length,
                              (index) => _buildSurveySyncTile(
                                  questionSetName:
                                      controller.synkedSurveyData[index]
                                              ['questionSetName'] ??
                                          '',
                                  beneficeryId:
                                      controller.synkedSurveyData[index]
                                              ['beneficiaryId'] ??
                                          ''),
                            ),
                          } else ...{
                            ...List.generate(
                              controller.notSynkedSurveyData.length,
                              (index) => _buildSurveySyncTile(
                                  questionSetName:
                                      controller.notSynkedSurveyData[index]
                                              ['questionSetName'] ??
                                          '',
                                  beneficeryId:
                                      controller.notSynkedSurveyData[index]
                                              ['beneficiaryId'] ??
                                          ''),
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                ),
                if (controller.selectedSyncedSurveys.value == false) ...{
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () => controller.onSyncSurveyClicked(),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary1,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        "Sync Survey",
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                },
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveySyncTile(
      {required String questionSetName, required String beneficeryId}) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.5), // Shadow color with opacity
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
                'Question Set Name :',
                style: TextStyle(fontWeight: FontWeight.w700),
              )),
              Expanded(
                  child: Text(
                questionSetName,
                style: TextStyle(fontWeight: FontWeight.w700),
              ))
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: Text(
                'Beneficiary Id :',
                style: TextStyle(fontWeight: FontWeight.w700),
              )),
              Expanded(
                  child: Text(
                beneficeryId,
                style: TextStyle(fontWeight: FontWeight.w700),
              ))
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
