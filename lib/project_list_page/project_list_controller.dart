import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart';

class ProjectMonitoringListController extends GetxController {
  final SessionManager sessionManager = SessionManager();

  final projectList = <ProjectList>[].obs;

  final ApiService apiService = ApiService();

  @override
  void onInit() async {
    super.onInit();
    await getProjectList();
  }

  Future<void> getProjectList() async {
    sessionManager.getProjectList().then((value) {
      projectList.addAll(value);
      update();
    });
  }
}
