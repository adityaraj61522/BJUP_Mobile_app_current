import 'dart:async';
import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/beneficery_list_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/question_form_data_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/question_set_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:bjup_application/common/response_models/get_question_set_response/get_question_set_response.dart';
import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:bjup_application/common/hive_storage_controllers/cbo_list_storage.dart';

class StartMonitoringController extends GetxController {
  // Dependencies (use Get.find for better testability)
  final SessionManager sessionManager = SessionManager();
  final VillageStorageService villageStorageService = VillageStorageService();
  final BeneficiaryStorageService beneficiaryStorageService =
      BeneficiaryStorageService();
  final QuestionSetStorageService questionSetStorageService =
      QuestionSetStorageService();
  final QuestionFormStorageService questionFormStorageService =
      QuestionFormStorageService();
  final ApiService apiService = ApiService();
  final CBOStorageService cboStorageService = CBOStorageService();

  // Reactive variables
  final selectedProject = ''.obs;
  final selectedAnamitorId = ''.obs;
  final selectedOfficeId = ''.obs;
  final selectedInterviewId = ''.obs;
  final selectedVillage = ''.obs;
  final selectedQuestionSet = ''.obs;
  final selectedBeneficiary = ''.obs;
  final errorText = ''.obs;
  final isLoading = false.obs;
  final showSelector = false.obs;

  // Non-reactive variables
  String projectId = '';
  String projectTitle = '';
  String officeName = '';
  UserLoginResponse? userData;

  // Lists
  final villageList = <VillagesList>[].obs;
  final questionSetList = <QuestionSetList>[].obs;
  final beneficiaryList = <BeneficiaryData>[].obs;
  final selectedQuestionFormSet = <FormQuestionData>[].obs;
  final beneficiaryOrCBOList =
      <dynamic>[].obs; // This will hold either BeneficiaryData or CBOData

  // Error handling function
  Future<void> _handleError(String message) async {
    errorText.value = message; // Update errorText
    Get.snackbar(
      'Error', //Consistent title
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
    );
  }

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    if (args == null) {
      _handleError('Arguments are null in StartMonitoringController');
      return; // Important: Stop execution if arguments are missing
    }
    selectedProject.value = args['projectId'] ?? '';
    projectTitle = args['projectTitle'] ?? '';
    userData = await sessionManager.getUserData();
    officeName = userData!.office.officeTitle;
    selectedOfficeId.value = userData?.office.id ?? '';
    selectedAnamitorId.value = userData?.userId ?? '';
  }

  void onExistingInterviewClicked() async {
    try {
      await getQuestionSetList();
      showSelector.value = true;
    } catch (e) {
      _handleError('Failed to load question sets: $e'); // Use the error handler
    }
  }

  void onAddBeneficeryClicked() {
    Get.toNamed(
      AppRoutes.addBeneficery,
      arguments: {
        'projectId': selectedProject.value,
        'projectTitle': projectTitle,
        'officeName': officeName,
        'interviewType': selectedInterviewId.value,
        'villageId': selectedVillage.value,
        'questionSetId': selectedQuestionSet.value,
        'beneficiaryId': selectedBeneficiary.value,
      },
    );
  }

  Future<void> getVillageList({required String selectedInterviewId}) async {
    try {
      final villageListData = await villageStorageService.getVillageData(
        projectId: selectedProject.value,
        interviewId: selectedInterviewId,
      );
      final seenIds = <String>{};
      villageList.clear(); //Clear before adding
      villageList.addAll(villageListData.where((item) {
        return seenIds.add(item.villageId);
      }));
    } catch (e) {
      _handleError('Failed to load village list: $e');
    }
  }

  Future<void> getQuestionSetList() async {
    try {
      final storedQuestionSets =
          await questionSetStorageService.getQuestionSetData(
        projectId: selectedProject.value,
      );
      final Set<String> existingIds =
          questionSetList.map((item) => item.id).toSet();
      final List<QuestionSetList> uniqueNewQuestionSets = storedQuestionSets
          .where((item) => !existingIds.contains(item.id))
          .toList();

      questionSetList.addAll(uniqueNewQuestionSets);
      update();
      await getQuestionFormSetList();
    } catch (e) {
      _handleError('Failed to load question set list: $e');
    }
  }

  Future<void> getQuestionFormSetList() async {
    try {
      // 1. Fetch question form data from the storage service.
      final List<FormQuestionData> questionFormData =
          await questionFormStorageService.getQuestionFormData(
        questionSetId: selectedQuestionSet.value,
        projectId: selectedProject.value,
      );

      selectedQuestionFormSet.clear();

      selectedQuestionFormSet.addAll(questionFormData);
    } catch (e) {
      _handleError('Failed to load question form set list: $e');
    }
  }

  Future<void> getBeneficieryList(
      {required String interviewId, required String villageId}) async {
    try {
      beneficiaryOrCBOList.clear(); // Clear the list before adding new data

      switch (interviewId) {
        case "44":
          // Handle beneficiary data
          final beneficiaryListData =
              await beneficiaryStorageService.getBeneficiaryData(
            interviewId: interviewId,
            villageId: villageId,
            projectId: selectedProject.value,
          );
          final seenBeneficiaryIds = <String>{};
          beneficiaryOrCBOList.addAll(beneficiaryListData
              .where((item) => seenBeneficiaryIds.add(item.beneficiaryId)));
          break;

        case "46":
        case "47":
          // Handle CBO data and Others data (both are CBOData type)
          final cboListData = await cboStorageService.getCBOData(
            interviewId: interviewId,
            villageId: villageId,
            projectId: selectedProject.value,
          );
          final seenCBOIds = <String>{};
          beneficiaryOrCBOList
              .addAll(cboListData.where((item) => seenCBOIds.add(item.cboid)));
          break;

        default:
          throw Exception('Unsupported interview type: $interviewId');
      }
    } catch (e) {
      _handleError('Failed to load data list: $e');
    }
  }

  void changeVillage(String village) async {
    selectedVillage.value = village;
    try {
      await getBeneficieryList(
          interviewId: selectedInterviewId.value, villageId: village);
    } catch (e) {
      _handleError("Failed to update beneficiary list: $e");
    }
    update();
  }

  void changeQuestionSetType(String questionSetType) async {
    selectedQuestionSet.value = questionSetType;
    try {
      final selectedQuestionSetItem = questionSetList.firstWhereOrNull(
        (element) => element.id == questionSetType,
      );
      selectedInterviewId.value =
          selectedQuestionSetItem?.interviewTypeId ?? '';
      await getVillageList(selectedInterviewId: selectedInterviewId.value);
    } catch (e) {
      _handleError("Failed to update question set type: $e");
    }
    update();
  }

  void changeBeneficery(String beneficeryId) async {
    selectedBeneficiary.value = beneficeryId;
    try {
      await getQuestionFormSetList();
    } catch (e) {
      _handleError("Failed to update beneficiary list: $e");
    }
    update();
  }
}
