import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/project_action_list/project_action_list_controller.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMonitoringActionListView extends StatelessWidget {
  ProjectMonitoringActionListView({super.key});

  final controller = Get.put(ProjectMonitoringActionListController(),
      permanent: false, tag: DateTime.now().millisecondsSinceEpoch.toString());

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Data Collection",
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
            color: AppColors.white,
            icon: const Icon(Icons.logout),
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
          LayoutBuilder(
            builder: (_, constraints) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: (constraints.maxWidth - 260) / 3,
                  runSpacing: (constraints.maxWidth - 300) / 3,
                  children: [
                    _buildDashboardButton(
                      icon: Icons.download_for_offline_rounded,
                      label: "Download Village Data",
                      onTap: () => controller.routeToDownloadVillageData(),
                      tileColor: AppColors.green,
                      // onTap: () => Get.to(() => const FieldAttendanceScreen()),
                    ),
                    _buildDashboardButton(
                      icon: Icons.question_mark_rounded,
                      label: "Download Question Set",
                      onTap: () => controller.routeToDownloadQuestionSet(),
                      tileColor: AppColors.green,
                      // onTap: () => Get.to(() => const ProjectMonitoringScreen()),
                    ),
                    _buildDashboardButton(
                      icon: Icons.analytics,
                      label: "Start Monitoring",
                      tileColor: AppColors.green,
                      onTap: () => controller.routeToStartMonitoring(),
                      // onTap: () => Get.to(() => const ProjectMonitoringScreen()),
                    ),
                    _buildDashboardButton(
                      icon: Icons.save_as_rounded,
                      label: "Local Saved Surveys",
                      onTap: () => {},
                      tileColor: AppColors.green,
                      // onTap: () => Get.to(() => const ProjectMonitoringScreen()),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color tileColor,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          SizedBox(
            height: 10,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
