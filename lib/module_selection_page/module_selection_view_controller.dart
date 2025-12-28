import 'package:bjup_application/common/hive_storage_controllers/beneficery_list_storage.dart';
import 'package:bjup_application/common/notification_card.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class ModuleSelectionController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final NotificationController notificationController =
      Get.find<NotificationController>();

  final VillageStorageService villageStorageService = VillageStorageService();
  final BeneficiaryStorageService beneficiaryStorageService =
      BeneficiaryStorageService();

  final villageExists = false.obs;

  final projectId = ''.obs;

  String officeName = '';

  final selectedAnamitorId = ''.obs;

  final selectedOfficeId = ''.obs;

  UserLoginResponse? userData;

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['projectId'] != null) {
      projectId.value = args['projectId'];
    }

    userData = await sessionManager.getUserData();
    officeName = userData!.office.officeTitle;
    selectedOfficeId.value = userData!.office.id;
    selectedAnamitorId.value = userData!.userId;
    // checkVillageData();
  }

  void checkVillageData() async {
    try {
      final villages = await villageStorageService.getAllVillagesForProject(
        projectId: projectId.value,
      );
      if (villages.isNotEmpty) {
        villageExists.value = true;
        notificationController.showSuccess(
            'success'.tr, 'village_data_loaded'.tr);
      } else {
        villageExists.value = false;
        notificationController.showInfo('info'.tr, 'no_villages_found'.tr);
      }
    } catch (e) {
      notificationController.showError('error'.tr,
          'error_checking_villages'.trParams({'error': e.toString()}));
    }
  }
}
