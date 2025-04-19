import 'dart:async';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:bjup_application/common/response_models/get_question_set_response/get_question_set_response.dart';
import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/download_question_set_page/download_question_set_storage.dart';
import 'package:bjup_application/download_village_data_page/download_village_data_storage.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

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

  final selectedQuestionSet = ''.obs;

  final selectedBeneficiary = ''.obs;

  final errorText = ''.obs;

  final isLoading = false.obs;

  String projectId = '';
  String projectTitle = '';
  String officeName = '';

  UserLoginResponse? userData;

  final villageList = <VillagesList>[].obs;
  final questionSetList = <QuestionSetList>[].obs;
  final beneficiaryList = <BeneficiaryData>[].obs;
  final showSelector = false.obs;

  final selectedQuestionFormSet = <FormQuestionData>[].obs;

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
  }

  void onExistingInterviewClicked() async {
    await getQuestionSetList();
    await getVillageList();
    showSelector.value = true;
  }

  void onAddBeneficeryClicked() async {
    Get.toNamed(AppRoutes.addBeneficery, arguments: {
      'projectId': selectedProject.value,
      'projectTitle': projectTitle,
      'officeName': officeName,
      'interviewType': selectedInterviewType.value,
      'villageId': selectedVillage.value,
      'questionSetId': selectedQuestionSet.value,
      'beneficiaryId': selectedBeneficiary.value
    });
  }

  Future<void> getVillageList() async {
    List<VillagesList> villageListData = [];
    await downloadedVillageStorageManager.getVillageData().then((value) {
      final seenIds = <String>{};
      villageListData = value.where((item) {
        return seenIds.add(item.villageId);
      }).toList();
      update();
    });
    villageList.addAll(villageListData.toSet().toList());
  }

  Future<void> getQuestionSetList() async {
    List<QuestionSetList> questionSetListData = [];
    await downloadedQuestionSetStorageManager
        .getQuestionSetData()
        .then((value) {
      final seenIds = <String>{};
      questionSetListData = value.where((item) {
        return seenIds.add(item.id);
      }).toList();
      update();
    });
    questionSetList.addAll(questionSetListData.toSet().toList());
    await getQuestionFormSetList();
  }

  Future<void> getQuestionFormSetList() async {
    List<FormQuestionData> questionSetListData = [];
    await downloadedQuestionSetStorageManager
        .getDownloadedQuestionSet()
        .then((value) {
      final seenIds = <String>{};
      questionSetListData = value
          .where((item) {
            return seenIds.add(item.questionSetId);
          })
          .expand((item) => item.formQuestions)
          .toList();
      update();
    });
    selectedQuestionFormSet.addAll(questionSetListData.toSet().toList());
  }

  Future<void> getBeneficieryList({required String interviewId}) async {
    // villageList.add(Village(villageId: '-11', villageName: 'Select an item'));
    List<BeneficiaryData> beneficiaryListData = [];
    await downloadedVillageStorageManager
        .getDownloadedVillageData(interviewId: interviewId)
        .then((value) {
      final seenIds = <String>{};
      beneficiaryListData = value!.beneficiaries.where((item) {
        return seenIds.add(item.beneficiaryId);
      }).toList();
      update();
    });
    beneficiaryList.addAll(beneficiaryListData.toSet().toList());
  }

  void changeVillage(String village) async {
    selectedVillage.value = village;
    // final selectedVillageObj =
    //     villageList.firstWhere((element) => element.villageId == village);
    await getBeneficieryList(interviewId: '${selectedVillage.value}-44');
    update();
  }

  void changeQuestionSetType(String questionSetType) {
    selectedQuestionSet.value = questionSetType;
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
