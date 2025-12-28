import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/notification_card.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart';

class ProjectMonitoringListController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final NotificationController notificationController =
      Get.find<NotificationController>();

  final projectList = <ProjectList>[].obs;

  final ApiService apiService = ApiService();

  @override
  void onInit() async {
    super.onInit();
    await getProjectList();
  }

  Future<void> getProjectList() async {
    try {
      final value = await sessionManager.getProjectList();
      if (value.isEmpty) {
        notificationController.showInfo('info'.tr, 'no_projects_found'.tr);
      } else {
        projectList.addAll(value);
        update();
      }
    } catch (e) {
      notificationController.showError('error'.tr,
          'error_fetching_projects'.trParams({'error': e.toString()}));
    }
  }
}
