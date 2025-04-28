import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/survey_storage.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class SyncSurveyController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final SurveyStorageService surveyStorageService = SurveyStorageService();
  final ApiService apiService = ApiService();

  final synkedSurveyData = [].obs;
  final notSynkedSurveyData = [].obs;

  final selectedSyncedSurveys = false.obs;

  String projectId = '';
  String projectTitle = '';
  String officeName = '';
  UserLoginResponse? userData;
  final selectedAnamitorId = ''.obs;
  final selectedOfficeId = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    print(args);
    projectId = args['projectId'];
    projectTitle = args['projectTitle'];
    userData = await sessionManager.getUserData();
    officeName = userData?.office.officeTitle ?? '';
    selectedOfficeId.value = userData?.office.id ?? '';
    selectedAnamitorId.value = userData?.userId ?? '';
    getSurveysToSync();
  }

  void getSurveysToSync() async {
    try {
      final savedSurveys =
          await surveyStorageService.getAllSavedSurveyDataForProject(
        projectId: projectId,
      );
      if (savedSurveys.isNotEmpty) {
        List<Map<String, dynamic>> extractedSurveyData = [];
        for (var surveyMap in savedSurveys) {
          surveyMap.forEach((hiveKey, surveyData) {
            print('Survey Data for $hiveKey: $surveyData');
            extractedSurveyData.add(surveyData);
          });
        }
        synkedSurveyData
            .addAll(extractedSurveyData.where((e) => e['isSynced'] == true));
        notSynkedSurveyData
            .addAll(extractedSurveyData.where((e) => e['isSynced'] == false));
      } else {
        print('No saved surveys found.');
      }
    } catch (e, stackTrace) {
      print('Error retrieving saved surveys: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        "Error",
        "Error retrieving saved surveys.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }

  void onSyncSurveyClicked() async {
    isLoading.value = true;
    int count = 0;
    try {
      for (var survey in notSynkedSurveyData) {
        print('Survey to sync: $survey');
        await submitSurvey(savedSurveyQuestions: survey).then((success) => {
              if (success)
                {
                  surveyStorageService.updateSurveyFormData(
                    projectId: projectId,
                    questionSetId: survey['questionSetId'],
                    beneficiaryId: survey['beneficiaryId'],
                    updatedSurveyQuestions: {
                      ...survey,
                      'isSynced': true,
                    },
                  ),
                  synkedSurveyData.add(survey),
                  notSynkedSurveyData.remove(survey),
                  print('Survey synced successfully: $survey'),
                  count++,
                }
            });
      }
      isLoading.value = false;
      Get.snackbar(
        "Success",
        "$count Survey Synced successfully!!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary1,
        colorText: AppColors.white,
      );
    } catch (e, stackTrace) {
      isLoading.value = false;
      print('Error during sync: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        "Error",
        "An error occurred during survey synchronization.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }

  Future<bool> submitSurvey(
      {required Map<String, dynamic> savedSurveyQuestions}) async {
    var formData = FormData.fromMap({...savedSurveyQuestions});

    try {
      var response = await apiService.post("/synchSurvey.php", formData);

      if (response != null && response.statusCode == 200) {
        print('Survey Saved Locally successfully!: ${response.data}');

        // capturedImage.value = null;
        return true;
      } else {
        print(
            'Failed to save survey: ${response?.statusCode} - ${response?.data}');
        Get.snackbar(
          "Error",
          "Failed to save survey.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error while saving survey: $e');
      Get.snackbar(
        "Error",
        "Something went wrong while saving survey.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return false;
    } finally {}
  }
}
