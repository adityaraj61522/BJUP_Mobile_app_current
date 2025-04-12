import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/models/user_model.dart';
import 'package:bjup_application/common/response_models/download_village_data_response/download_village_data_response.dart';
import 'package:bjup_application/common/response_models/question_set_response/question_set_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/download_question_set_page/download_question_set_storage.dart';
import 'package:bjup_application/download_village_data_page/download_village_data_storage.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';

class StartMonitoringController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final DownloadVillageDataStorage downloadedVillageStorageManager =
      DownloadVillageDataStorage();

  final DownloadQuestionSetStorage downloadedQuestionSetStorageManager =
      DownloadQuestionSetStorage();

  final ApiService apiService = ApiService();

  final selectedProject = ''.obs;

  final selectedAnamitorId = ''.obs;

  final selectedOfficeId = ''.obs;

  final selectedInterviewType = ''.obs;

  final selectedVillage = ''.obs;

  final errorText = ''.obs;

  final isLoading = false.obs;

  final SessionManager _sessionManager = SessionManager();

  List<Village>? villages = [];
  List<InterviewType>? interviewTypes = [];

  String projectId = '';
  String projectTitle = '';
  String officeName = '';

  UserModel? userData;

  final villageList = <Village>[].obs;
  final questionSetList = <QuestionSet>[].obs;
  final showSelector = false.obs;

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
    await fetchVillageData();
  }

  void onExistingInterviewClicked() async {
    await getQuestionSetList();
    await getVillageList();
    showSelector.value = true;
  }

  Future<void> getVillageList() async {
    downloadedVillageStorageManager.getVillageData().then((value) {
      if (value.isNotEmpty) {
        villageList.addAll(value);
      }
      update();
    });
  }

  Future<void> getQuestionSetList() async {
    downloadedQuestionSetStorageManager.getQuestionSetData().then((value) {
      if (value.isNotEmpty) {
        questionSetList.addAll(value);
      }
      update();
    });
  }

  Future<void> fetchVillageData() async {
    String anamitorId = selectedAnamitorId.value;
    String projectId = selectedProject.value;

    if (projectId.isEmpty || projectId.isEmpty) {
      errorText.value = "Project Not Selected".tr;
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
      });

      var response = await apiService.post(
        "/getVillages.php",
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
          var villageData = DownloadVillageDataResponse.fromMap(data);
          villages = villageData.villages;
          interviewTypes = villageData.interviewTypes;
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

  void changeVillage(String village) {
    selectedVillage.value = village;
    update();
  }

  void changeInterviewType(String interviewType) {
    selectedInterviewType.value = interviewType;
    update();
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
