import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/project_list_page/project_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMonitoringListView extends StatelessWidget {
  ProjectMonitoringListView({super.key});

  final ProjectMonitoringListController controller =
      Get.put(ProjectMonitoringListController());

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Project List",
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
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
                fit: BoxFit.fitWidth, // Covers the entire screen
                opacity: 0.3,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Obx(
              () => Column(
                children: [
                  ...List.generate(
                    controller.projectList.length,
                    (index) => _buildProjectMonitoringCard(
                      projectItem: controller.projectList[index],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectMonitoringCard({required ProjectList projectItem}) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.projectActionList, arguments: {
        "projectId": projectItem.projectId,
        "projectTitle": projectItem.projectTitle,
      }),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.gray.withOpacity(0.5), // Shadow color with opacity
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
                    flex: 1,
                    child: Text(
                      'Project Id :',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      projectItem.projectId,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ))
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'Project Name :',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      projectItem.projectTitle,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ))
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
