import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/sync_survey_page/sync_survey_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SyncSurveyView extends StatelessWidget {
  SyncSurveyView({super.key});

  final SyncSurveyController controller = Get.put(SyncSurveyController(),
      permanent: false, tag: DateTime.now().millisecondsSinceEpoch.toString());

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return WillPopScope(
      onWillPop: () async {
        _navigateToProjectAction();
        return false;
      },
      child: Scaffold(
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
            onPressed: _navigateToProjectAction,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: AppColors.white,
              ),
              onPressed: () {
                _showLogoutConfirmationDialog(context, sessionManager);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background removed as it was commented out
            Obx(
              () => Column(
                children: [
                  // Tab buttons
                  _buildTabButtons(),

                  // Survey list
                  Expanded(
                    child: controller.isLoading.value
                        ? _buildLoadingIndicator()
                        : _buildSurveyList(),
                  ),

                  // Progress indicator during sync
                  if (controller.isLoading.value &&
                      controller.syncProgress.value > 0)
                    _buildProgressIndicator(),

                  // Sync button
                  if (!controller.selectedSyncedSurveys.value)
                    _buildSyncButton(),

                  SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.selectedSyncedSurveys.value = false,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.selectedSyncedSurveys.value
                  ? AppColors.primary1
                  : AppColors.white,
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
              'Locally Saved (${controller.notSynkedSurveyData.isEmpty ? 0 : controller.notSynkedSurveyData.length})',
              style: TextStyle(
                color: controller.selectedSyncedSurveys.value
                    ? AppColors.white
                    : AppColors.primary1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.selectedSyncedSurveys.value = true,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.selectedSyncedSurveys.value
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
              'Synced Surveys (${controller.synkedSurveyData.isEmpty ? 0 : controller.synkedSurveyData.length})',
              style: TextStyle(
                color: controller.selectedSyncedSurveys.value
                    ? AppColors.primary1
                    : AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary1),
          ),
          SizedBox(height: 20),
          Text(
            controller.syncProgress.value > 0
                ? "Syncing surveys... ${controller.syncProgress.value}%"
                : "Loading surveys...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: controller.syncProgress.value / 100,
            backgroundColor: AppColors.gray.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary1),
          ),
          SizedBox(height: 5),
          Text(
            "Syncing: ${controller.syncProgress.value}% completed",
            style: TextStyle(fontSize: 12, color: AppColors.primary1),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyList() {
    // Safely handle the lists
    final displayList = controller.selectedSyncedSurveys.value
        ? (controller.synkedSurveyData.isEmpty
            ? []
            : controller.synkedSurveyData)
        : (controller.notSynkedSurveyData.isEmpty
            ? []
            : controller.notSynkedSurveyData);

    return displayList.isEmpty
        ? _buildEmptyState()
        : SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: _buildSurveyItems(displayList),
            ),
          );
  }

  List<Widget> _buildSurveyItems(List displayList) {
    List<Widget> widgets = [];

    try {
      if (displayList.isEmpty) {
        return widgets; // Return empty list
      }

      for (int i = 0; i < displayList.length; i++) {
        try {
          final item = displayList[i];

          // Skip null items
          if (item == null) {
            widgets.add(_buildErrorTile());
            continue;
          }

          // Handle item based on its type
          if (item is Map) {
            final questionSetName = _safeGetString(item, 'questionSetName');
            final beneficiaryId = _safeGetString(item, 'beneficeryName');

            widgets.add(_buildSurveySyncTile(
              questionSetName: questionSetName,
              beneficeryId: beneficiaryId,
            ));
          } else {
            // Item is not a Map
            widgets.add(_buildErrorTile());
          }
        } catch (e) {
          print('Error building survey item at index $i: $e');
          widgets.add(_buildErrorTile());
        }
      }
    } catch (e) {
      print('Error in _buildSurveyItems: $e');
      widgets.add(_buildErrorTile());
    }

    return widgets;
  }

  String _safeGetString(dynamic map, String key) {
    try {
      if (map is Map) {
        final value = map[key];
        if (value != null) {
          return value.toString();
        }
      }
    } catch (e) {
      print('Error in _safeGetString: $e');
    }
    return '';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.selectedSyncedSurveys.value
                ? Icons.cloud_done
                : Icons.cloud_off,
            size: 80,
            color: AppColors.gray,
          ),
          SizedBox(height: 20),
          Text(
            controller.selectedSyncedSurveys.value
                ? "No synced surveys found"
                : "No surveys pending for sync",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray,
            ),
          ),
          SizedBox(height: 10),
          Text(
            controller.selectedSyncedSurveys.value
                ? "All your synced surveys will appear here"
                : "Complete surveys to sync them",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTile() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.red.withOpacity(0.1),
        border: Border.all(color: AppColors.red.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.red),
          SizedBox(height: 10),
          Text(
            "Error loading survey data",
            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveySyncTile({
    required String questionSetName,
    required String beneficeryId,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(2, 4),
          ),
        ],
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Question Set Name:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  questionSetName.isNotEmpty
                      ? questionSetName
                      : 'Not available',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        questionSetName.isNotEmpty ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Beneficiary Name:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  beneficeryId.isNotEmpty ? beneficeryId : 'Not available',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: beneficeryId.isNotEmpty ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Sync status indicator
          Row(
            children: [
              Icon(
                controller.selectedSyncedSurveys.value
                    ? Icons.cloud_done
                    : Icons.cloud_upload,
                color: controller.selectedSyncedSurveys.value
                    ? Colors.green
                    : AppColors.red,
                size: 18,
              ),
              SizedBox(width: 5),
              Text(
                controller.selectedSyncedSurveys.value
                    ? "Synced"
                    : "Not synced",
                style: TextStyle(
                  color: controller.selectedSyncedSurveys.value
                      ? Colors.green
                      : AppColors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ||
                controller.notSynkedSurveyData.isEmpty ||
                controller.notSynkedSurveyData.length == 0
            ? null // Disable button when loading or no surveys to sync
            : () => controller.onSyncSurveyClicked(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary1,
          disabledBackgroundColor: AppColors.gray,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, color: AppColors.white),
            SizedBox(width: 10),
            Text(
              "Sync ${controller.notSynkedSurveyData.isEmpty ? 0 : controller.notSynkedSurveyData.length} ${controller.notSynkedSurveyData.isEmpty || controller.notSynkedSurveyData.length == 1 ? 'Survey' : 'Surveys'}",
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProjectAction() {
    Get.toNamed(
      AppRoutes.projectActionList,
      arguments: {
        "projectId": controller.projectId,
        "projectTitle": controller.projectTitle,
      },
    );
  }

  void _showLogoutConfirmationDialog(
      BuildContext context, SessionManager sessionManager) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.primary1),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                sessionManager.forceLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary1,
              ),
              child: Text(
                'Logout',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
