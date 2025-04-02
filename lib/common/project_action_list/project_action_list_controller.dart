import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/models/user_model.dart';
import 'package:bjup_application/common/response_models/question_set_response/question_set_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';

class ProjectMonitoringActionListController extends GetxController {
  final SessionManager sessionManager = SessionManager();

  String projectId = '';
  String projectTitle = '';

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    print(args);
    projectId = args['projectId'];
    projectTitle = args['projectTitle'];
    // await fetchQuestionSet();
  }

  void routeToDownloadQuestionSet() async {
    await Get.toNamed(AppRoutes.downlaodQuestionSet, arguments: {
      "projectId": projectId,
      "projectTitle": projectTitle,
    });
  }
}
