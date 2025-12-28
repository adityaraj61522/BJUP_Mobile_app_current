import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/notification_card.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/project_list_page/project_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMonitoringListView extends StatelessWidget {
  ProjectMonitoringListView({super.key});

  final ProjectMonitoringListController controller = Get.put(
      ProjectMonitoringListController(),
      permanent: false,
      tag: DateTime.now().millisecondsSinceEpoch.toString());
  final sessionManager = SessionManager();
  final notificationController = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Obx(
              () => Column(
                children: controller.projectList
                    .map((projectItem) => _buildProjectMonitoringCard(
                          projectItem: projectItem,
                        ))
                    .toList(),
              ),
            ),
          ),
          NotificationCardsList(controller: notificationController),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "project_list".tr,
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.primary1,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Get.toNamed(AppRoutes.moduleSelection),
        tooltip: 'back_to_modules'.tr,
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

  Widget _buildProjectMonitoringCard({required ProjectList projectItem}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.projectActionList, arguments: {
          "projectId": projectItem.projectId,
          "projectTitle": projectItem.projectTitle,
        }),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectDetailRow('project_id'.tr, projectItem.projectId),
              const SizedBox(height: 10),
              _buildProjectDetailRow(
                  'project_name'.tr, projectItem.projectTitle),
            ],
          ),
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
