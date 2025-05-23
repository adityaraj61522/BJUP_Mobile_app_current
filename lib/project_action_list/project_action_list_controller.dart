import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/question_set_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class ProjectMonitoringActionListController extends GetxController {
  final SessionManager sessionManager = SessionManager();

  final VillageStorageService villageStorageService = VillageStorageService();
  final QuestionSetStorageService questionSetStorageService =
      QuestionSetStorageService();

  final villageExists = false.obs;
  final questionSetsExists = false.obs;

  String projectId = '';
  String projectTitle = '';

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    print(args);
    projectId = args['projectId'];
    projectTitle = args['projectTitle'];
    await checkVillageData();
    await checkQuestionSetData();
    // await fetchQuestionSet();
  }

  Future<void> checkVillageData() async {
    final villages = await villageStorageService.getAllVillagesForProject(
      projectId: projectId,
    );
    if (villages.isNotEmpty) {
      villageExists.value = true;
    } else {
      villageExists.value = false;
    }
  }

  Future<void> checkQuestionSetData() async {
    final questionSets =
        await questionSetStorageService.getAllQuestionsForProject(
      projectId: projectId,
    );
    if (questionSets.isNotEmpty) {
      questionSetsExists.value = true;
    } else {
      questionSetsExists.value = false;
    }
  }

  void routeToDownloadQuestionSet() async {
    if (villageExists.value == false) {
      Get.snackbar(
        "Please Download Villages.",
        'Village Data required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return;
    }
    await Get.toNamed(AppRoutes.downlaodQuestionSet, arguments: {
      "projectId": projectId,
      "projectTitle": projectTitle,
    });
  }

  void routeToDownloadVillageData() async {
    await Get.toNamed(AppRoutes.downlaodVillageData, arguments: {
      "projectId": projectId,
      "projectTitle": projectTitle,
    });
  }

  void routeToStartMonitoring() async {
    if (villageExists.value == false) {
      Get.snackbar(
        "download_villages_first".tr,
        'village_data_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return;
    }
    if (questionSetsExists.value == false) {
      Get.snackbar(
        "download_question_sets".tr,
        'question_set_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return;
    }
    await Get.toNamed(AppRoutes.startMonitoring, arguments: {
      "projectId": projectId,
      "projectTitle": projectTitle,
    });
  }

  void routeToSyncSurvey() async {
    await Get.toNamed(AppRoutes.syncSurvey, arguments: {
      "projectId": projectId,
      "projectTitle": projectTitle,
    });
  }
}
