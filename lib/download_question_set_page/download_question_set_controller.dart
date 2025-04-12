import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/models/user_model.dart';
import 'package:bjup_application/common/response_models/download_question_set_response/download_question_set_response.dart';
import 'package:bjup_application/common/response_models/question_set_response/question_set_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/download_question_set_page/download_question_set_storage.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';

class DownloadQuestionSetController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final DownloadQuestionSetStorage downloadedStorageManager =
      DownloadQuestionSetStorage();

  final projectList = <Project>[].obs;

  final ApiService apiService = ApiService();

  final selectedProject = ''.obs;

  final selectedAnamitorId = ''.obs;

  final selectedOfficeId = ''.obs;

  final selectedLanguage = 'question'.obs;

  final selectedReportType = ''.obs;

  final selectedQuestionSet = ''.obs;

  final errorText = ''.obs;

  final isLoading = false.obs;

  final SessionManager _sessionManager = SessionManager();

  List<Language>? languages = [];
  List<ReportType>? reportType = [];
  List<QuestionSet>? questionSet = [];

  String projectId = '';
  String projectTitle = '';
  String officeName = '';

  UserModel? userData;

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    print(args);
    selectedProject.value = args['projectId'];
    projectTitle = args['projectTitle'];
    userData = await sessionManager.getUserData();
    officeName = userData!.office.officeTitle;
    selectedOfficeId.value = userData!.office.id;
    selectedAnamitorId.value = userData!.userId;
    await fetchQuestionSet();
  }

  Future<void> getProjectList() async {
    sessionManager.getProjectList().then((value) {
      projectList.addAll(value);
      update();
    });
  }

  Future<void> fetchQuestionSet() async {
    String anamitorId = selectedAnamitorId.value;
    String officeId = selectedOfficeId.value;
    String projectId = selectedProject.value;

    if (projectId.isEmpty || projectId.isEmpty) {
      errorText.value = "Project Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (officeId.isEmpty || officeId.isEmpty) {
      errorText.value = "Office Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (anamitorId.isEmpty || anamitorId.isEmpty) {
      errorText.value = "Animator Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }

    try {
      isLoading.value = true;
      errorText.value = '';

      var formData = FormData.fromMap({
        'animator_id': anamitorId,
        'project_id': projectId,
        'office_id': officeId,
      });

      var response = await apiService.post(
        "/downloadForm.php",
        formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': '*/*',
          },
        ),
      );

      if (response != null) {
        var data = response.data;

        if (data['response_code'] == 200) {
          var questionSetData = QuestionSetResponse.fromMap(data);
          languages = questionSetData.language;
          reportType = questionSetData.reportType;
          questionSet = questionSetData.questionSet;
          // await _sessionManager.saveValidSession();
          // await _sessionManager.saveProjectList(projects: userData.projects);
          errorText.value = '';
          // Get.offAllNamed('/moduleSelection');
        } else if (data['response_code'] == 100) {
          handleErrorReported(error: "something_went_wrong".tr);
          await _sessionManager.logout();
        } else if (data['response_code'] == 300) {
          await _sessionManager.checkSession();
        } else {
          errorText.value = data['message'] ?? "something_went_wrong".tr;

          handleErrorReported(error: errorText.value);
          await _sessionManager.logout();
        }
      } else {
        handleErrorReported(error: "something_went_wrong".tr);
        await _sessionManager.logout();
      }
    } catch (e) {
      print('Login error: $e');
      handleErrorReported(error: "something_went_wrong".tr);
      await _sessionManager.logout();
    } finally {
      isLoading.value = false;
    }
  }

  void changeLanguage(String language) {
    selectedLanguage.value = language;
    update();
  }

  void changeReportType(String reportType) {
    selectedReportType.value = reportType;
    update();
  }

  void changeQuestionSet(String questionSet) {
    selectedQuestionSet.value = questionSet;
    update();
  }

  void onDownloadQuestionSetClicked() async {
    // String language = selectedLanguage.value;
    // String reportTypeId = selectedReportType.value;
    // String questionSetId = selectedQuestionSet.value;
    // String interviewTypeId = selectedQuestionSet.value;
    // String villageId = selectedQuestionSet.value;

    String language = 'question';
    String reportTypeId = '7';
    String questionSetId = '2';
    String interviewTypeId = '44';
    String villageId = '236017';

    if (language.isEmpty) {
      errorText.value = "Language Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (reportTypeId.isEmpty) {
      errorText.value = "Report Type Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (questionSetId.isEmpty) {
      errorText.value = "Question Set Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (interviewTypeId.isEmpty) {
      errorText.value = "Interview Type Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (villageId.isEmpty) {
      errorText.value = "Village Id Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }

    try {
      isLoading.value = true;
      errorText.value = '';

      var formData = FormData.fromMap({
        'question_set_id': questionSetId,
        'report_type_id': reportTypeId,
        'interview_type_id': interviewTypeId,
        'village_id': villageId,
        'language': language,
      });

      var response = await apiService.post(
        "/getSurveyQuestions.php",
        formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': '*/*',
          },
        ),
      );

      if (response != null) {
        var data = response.data;

        if (data['response_code'] == 200) {
          var questionSetData = DownloadedQuestionSetResponse.fromMap(data);

          await downloadedStorageManager.saveQuestionSetData(
            questionSetData: questionSet!
                .where((e) => e.id == selectedQuestionSet.value)
                .first,
          );

          await downloadedStorageManager.saveDownloadedQuestionSet(
              downloadedQuestionSet: questionSetData);

          Get.snackbar(
            "Success",
            'Question Set Data saved successfully!!'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.green,
            colorText: AppColors.white,
          );

          final downloadedData =
              await downloadedStorageManager.getDownloadedQuestionSet();
          print(downloadedData);
          // await _sessionManager.saveProjectList(projects: userData.projects);
          errorText.value = '';
          // Get.offAllNamed('/moduleSelection');
        } else if (data['response_code'] == 100) {
          handleErrorReported(error: "Data not available!!".tr);
        } else if (data['response_code'] == 300) {
          await _sessionManager.checkSession();
        } else {
          errorText.value = data['message'] ?? "something_went_wrong".tr;
          handleErrorReported(error: errorText.value);
        }
      } else {
        handleErrorReported(error: "something_went_wrong".tr);
      }
    } catch (e) {
      print('saveDownloadedQuestionSet error: $e');
      handleErrorReported(error: "something_went_wrong".tr);
    } finally {
      isLoading.value = false;
    }
  }
}

Future<void> handleErrorReported({required String error}) async {
  Get.snackbar(
    error,
    'something_went_wrong'.tr,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.red,
    colorText: AppColors.white,
  );
}
