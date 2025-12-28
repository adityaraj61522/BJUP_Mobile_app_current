import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/hive_storage_controllers/question_form_data_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/question_set_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/response_models/get_question_set_response/get_question_set_response.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/notification_card.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';

class DownloadQuestionSetController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final NotificationController notificationController =
      Get.find<NotificationController>();
  // final DownloadQuestionSetStorage downloadedStorageManager =
  //     DownloadQuestionSetStorage();

  final VillageStorageService villageStorageService = VillageStorageService();
  final QuestionSetStorageService questionSetStorageService =
      QuestionSetStorageService();
  final QuestionFormStorageService questionFormStorageService =
      QuestionFormStorageService();

  final projectList = <ProjectList>[].obs;

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

  List<LanguageList>? languages = [];
  List<ReportTypeList>? reportType = [];
  List<QuestionSetList>? questionSet = [];

  String projectId = '';
  String projectTitle = '';
  String officeName = '';

  String selectedVillages = '';
  String selectedInterviewId = '';

  UserLoginResponse? userData;

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
      errorText.value = "project_not_selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (officeId.isEmpty || officeId.isEmpty) {
      errorText.value = "office_not_selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (anamitorId.isEmpty || anamitorId.isEmpty) {
      errorText.value = "animator_not_selected".tr;
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
          var questionSetData = GetQuestionSetResponse.fromMap(data);
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

  void changeQuestionSet(String questionSetId) async {
    selectedQuestionSet.value = questionSetId;
    selectedInterviewId =
        questionSet!.firstWhere((e) => e.id == questionSetId).interviewTypeId;
    await villageStorageService
        .getVillageData(
            interviewId: selectedInterviewId, projectId: selectedProject.value)
        .then((value) => {
              selectedVillages =
                  value.map((e) => e.villageId).join(',').toString()
            });
    update();
  }

  void onDownloadQuestionSetClicked() async {
    String language = selectedLanguage.value;
    String reportTypeId = selectedReportType.value;
    String questionSetId = selectedQuestionSet.value;
    String interviewTypeId = selectedInterviewId;
    String villageId = selectedVillages;

    if (language.isEmpty) {
      errorText.value = "language_not_selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (reportTypeId.isEmpty) {
      errorText.value = "report_type_not_selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (questionSetId.isEmpty) {
      errorText.value = "question_set_not_selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (interviewTypeId.isEmpty) {
      errorText.value = "interview_type_not_selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (villageId.isEmpty) {
      errorText.value = "village_id_not_selected".tr;
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
          var questionSetData = GetQuestionFormResponse.fromMap(data);

          await questionSetStorageService
              .addQuestionSetData(
                  questionSetDataList: questionSet!
                      .where(((e) => e.id == questionSetId))
                      .toList(),
                  projectId: selectedProject.value)
              .then((value) => {
                    print("Question Set Data saved successfully!!"),
                    notificationController.showSuccess(
                      "success".tr,
                      "question_set_saved".tr,
                    ),
                  });

          await questionFormStorageService
              .addQuestionFormData(
                  questionFormDataList: questionSetData.formQuestions,
                  questionSetId: questionSetId,
                  projectId: selectedProject.value)
              .then((value) => {
                    print("Question Form Data saved successfully!!"),
                    // Get.snackbar(
                    //   "success".tr,
                    //   "question_form_saved".tr,
                    //   snackPosition: SnackPosition.BOTTOM,
                    //   backgroundColor: AppColors.primary1,
                    //   colorText: AppColors.white,
                    // ),
                  });

          // await downloadedStorageManager.saveQuestionSetData(
          //   questionSetData: questionSet!
          //       .where((e) => e.id == selectedQuestionSet.value)
          //       .first,
          // );

          // await downloadedStorageManager.saveDownloadedQuestionSet(
          //     downloadedQuestionSet: questionSetData);

          // Get.snackbar(
          //   "Success",
          //   'Question Set Data saved successfully!!'.tr,
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: AppColors.primary1,
          //   colorText: AppColors.white,
          // );

          // final downloadedData =
          //     await downloadedStorageManager.getDownloadedQuestionSet();
          // print(downloadedData);
          // await _sessionManager.saveProjectList(projects: userData.projects);
          errorText.value = '';
          // Get.offAllNamed('/moduleSelection');
          Get.toNamed(
            AppRoutes.projectActionList,
            arguments: {
              "projectId": selectedProject.value,
              "projectTitle": projectTitle,
            },
          );
        } else if (data['response_code'] == 100) {
          handleErrorReported(error: "data_not_available".tr);
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
  final notificationController = Get.find<NotificationController>();
  notificationController.showError(
    error,
    'something_went_wrong'.tr,
  );
}
