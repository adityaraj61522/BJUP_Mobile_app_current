import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/project_action_list/project_action_list_controller.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMonitoringActionListView extends StatelessWidget {
  ProjectMonitoringActionListView({super.key});

  final controller = Get.put(ProjectMonitoringActionListController(),
      permanent: false, tag: DateTime.now().millisecondsSinceEpoch.toString());

  final sessionManager = SessionManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (_, constraints) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: calculateSpacing(constraints.maxWidth, 150, 2),
              runSpacing: 20,
              alignment: WrapAlignment.start,
              children: [
                _buildDashboardButton(
                  icon: Icons.download_for_offline_rounded,
                  label: "download_village_data_button".tr,
                  onTap: () => controller.routeToDownloadVillageData(),
                  tileColor: AppColors.primary1,
                ),
                _buildDashboardButton(
                  icon: Icons.question_mark_rounded,
                  label: "download_question_set_button".tr,
                  onTap: () => controller.routeToDownloadQuestionSet(),
                  tileColor: AppColors.primary1,
                ),
                _buildDashboardButton(
                  icon: Icons.analytics,
                  label: "start_monitoring".tr,
                  tileColor: AppColors.primary1,
                  onTap: () => controller.routeToStartMonitoring(),
                ),
                _buildDashboardButton(
                  icon: Icons.save_as_rounded,
                  label: "local_saved_surveys".tr,
                  onTap: () => controller.routeToSyncSurvey(),
                  tileColor: AppColors.primary1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "data_collection".tr,
        style: TextStyle(color: AppColors.white),
      ),
      backgroundColor: AppColors.primary1,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Get.toNamed(AppRoutes.projectList, arguments: {
          "projectId": controller.projectId,
          "projectTitle": controller.projectTitle,
        }),
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

  double calculateSpacing(
      double maxWidth, double itemWidth, int itemCountPerRow) {
    final totalItemWidth = itemWidth * itemCountPerRow;
    return (maxWidth - totalItemWidth) / (itemCountPerRow + 1);
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color tileColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.white, size: 60),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
