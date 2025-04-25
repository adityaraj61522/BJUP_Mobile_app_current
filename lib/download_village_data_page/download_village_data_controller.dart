import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/beneficery_list_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';

class DownloadVillageDataController extends GetxController {
  final SessionManager sessionManager = SessionManager();

  final VillageStorageService villageStorageService = VillageStorageService();
  final BeneficiaryStorageService beneficiaryStorageService =
      BeneficiaryStorageService();

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

  void onDownloadQuestionSetClicked() async {
    String partnerId = selectedOfficeId.value;
    String projectsId = selectedProject.value;
    String interviewTypeId = selectedInterviewType.value;
    String villageId = selectedVillageList.join(',').toString();

    if (projectsId.isEmpty) {
      errorText.value = "Project Not Selected".tr;
      handleErrorReported(error: errorText.value);
      return;
    }
    if (partnerId.isEmpty) {
      errorText.value = "Partner Not Selected".tr;
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
          await villageStorageService
              .addVillageData(
                villageDataList: beneficieryCBOData.selectedVillages,
                interviewId: interviewTypeId,
                projectId: selectedProject.value,
              )
              .then((value) => {
                    print("Villlage List Data saved successfully!!"),
                    Get.snackbar(
                      "Success",
                      'Villlage Data saved successfully!!'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.green,
                      colorText: AppColors.white,
                    ),
                  });
          for (var village in beneficieryCBOData.selectedVillages) {
            List<BeneficiaryData> beneficiaryDataList = beneficieryCBOData
                .beneficiaries
                .where((element) => element.villageCode == village.villageId)
                .toList();
            await beneficiaryStorageService
                .addBeneficiaryData(
                  beneficiaryDataList: beneficiaryDataList,
                  interviewId: interviewTypeId,
                  villageId: village.villageId,
                  projectId: selectedProject.value,
                )
                .then((value) => {
                      print("Beneficiary Data saved successfully!!"),
                      Get.snackbar(
                        "Success",
                        'Beneficiary Data saved successfully!!'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.green,
                        colorText: AppColors.white,
                      ),
                    });
          }
          errorText.value = '';
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
