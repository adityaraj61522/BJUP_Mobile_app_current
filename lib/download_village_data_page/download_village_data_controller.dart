import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/notification_card.dart';
import 'package:bjup_application/common/hive_storage_controllers/beneficery_list_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/cbo_list_storage.dart';
import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';

class DownloadVillageDataController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final NotificationController notificationController =
      Get.find<NotificationController>();

  final VillageStorageService villageStorageService = VillageStorageService();
  final BeneficiaryStorageService beneficiaryStorageService =
      BeneficiaryStorageService();
  final CBOStorageService cboStorageService = CBOStorageService();

  final projectList = <ProjectList>[].obs;

  final ApiService apiService = ApiService();

  final selectedProject = ''.obs;

  final selectedAnamitorId = ''.obs;

  final selectedOfficeId = ''.obs;

  final selectedInterviewType = ''.obs;

  final selectedVillage = ''.obs;
  final selectedVillageList = [].obs;

  final errorText = ''.obs;

  final isLoading = false.obs;

  final SessionManager _sessionManager = SessionManager();

  List<VillagesList>? villages = [];
  List<InterviewTypeList>? interviewTypes = [];

  String projectId = '';
  String projectTitle = '';
  String officeName = '';

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
    await fetchVillageData();
  }

  Future<void> getProjectList() async {
    sessionManager.getProjectList().then((value) {
      projectList.addAll(value);
      update();
    });
  }

  Future<void> fetchVillageData() async {
    String anamitorId = selectedAnamitorId.value;
    String projectId = selectedProject.value;

    if (projectId.isEmpty || projectId.isEmpty) {
      errorText.value = "project_not_selected".tr;
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
          var villageData = GetVillageListResponse.fromMap(data);
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
          handleErrorReported(error: "invalid_response".tr);
          await _sessionManager.logout();
        }
      } else {
        handleErrorReported(error: "something_went_wrong".tr);
        await _sessionManager.logout();
      }
    } catch (e) {
      print('Login error: $e');
      handleErrorReported(
          error: "error_fetching_villages".trParams({'error': e.toString()}));
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

  void onDownloadQuestionSetClicked() async {
    String partnerId = selectedOfficeId.value;
    String projectsId = selectedProject.value;
    String interviewTypeId = selectedInterviewType.value;
    String villageId = selectedVillageList.join(',').toString();

    if (projectsId.isEmpty) {
      errorText.value = "project_not_selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (partnerId.isEmpty) {
      errorText.value = "partner_not_selected".tr;
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
        'partner_id': partnerId,
        'project_id': projectsId,
        'interview_type': interviewTypeId,
        'village_id': villageId,
      });
      var response = await apiService.post(
        "/getBenificiaryCBO.php",
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
          var beneficieryCBOData = GetBeneficeryResponse.fromMap(data);

          // Save village data first
          await villageStorageService.addVillageData(
            villageDataList: beneficieryCBOData.selectedVillages,
            interviewId: interviewTypeId,
            projectId: selectedProject.value,
          );

          // Handle different interview types
          for (var village in beneficieryCBOData.selectedVillages) {
            if (interviewTypeId == "44") {
              // Handle beneficiary data
              List<BeneficiaryData> beneficiaryDataList = beneficieryCBOData
                  .beneficiaries
                  .where((element) => element.villageCode == village.villageId)
                  .toList();

              await beneficiaryStorageService.addBeneficiaryData(
                beneficiaryDataList: beneficiaryDataList,
                interviewId: interviewTypeId,
                villageId: village.villageId,
                projectId: selectedProject.value,
              );
            } else if (interviewTypeId == "46") {
              // Handle CBO data
              List<CBOData> cboDataList = beneficieryCBOData.cbo
                  .where((element) => element.villagecode == village.villageId)
                  .toList();

              await cboStorageService.addCBOData(
                cboDataList: cboDataList,
                interviewId: interviewTypeId,
                villageId: village.villageId,
                projectId: selectedProject.value,
              );
            } else if (interviewTypeId == "47") {
              // Handle others data (which is also CBOData type)
              List<CBOData> othersDataList = beneficieryCBOData.others
                  .where((element) => element.villagecode == village.villageId)
                  .toList();

              await cboStorageService.addCBOData(
                cboDataList: othersDataList,
                interviewId: interviewTypeId,
                villageId: village.villageId,
                projectId: selectedProject.value,
              );
            } else if (interviewTypeId == "50") {
              // Handle others data (which is also CBOData type)
              List<CBOData> othersDataList = beneficieryCBOData.institute
                  .where((element) => element.villagecode == village.villageId)
                  .toList();

              await cboStorageService.addCBOData(
                cboDataList: othersDataList,
                interviewId: interviewTypeId,
                villageId: village.villageId,
                projectId: selectedProject.value,
              );
            }
          }

          notificationController.showSuccess(
            "success".tr,
            "data_saved".tr,
          );
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
          handleErrorReported(error: "invalid_response".tr);
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
