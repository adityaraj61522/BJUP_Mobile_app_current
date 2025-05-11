import 'package:bjup_application/common/hive_storage_controllers/beneficery_list_storage.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class ModuleSelectionController extends GetxController {
  final SessionManager sessionManager = SessionManager();

  final VillageStorageService villageStorageService = VillageStorageService();
  final BeneficiaryStorageService beneficiaryStorageService =
      BeneficiaryStorageService();

  final villageExists = false.obs;

  final projectId = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    projectId.value = args['projectId'];
    // checkVillageData();
  }

  void checkVillageData() async {
    try {
      final villages = await villageStorageService.getAllVillagesForProject(
        projectId: projectId.value,
      );
      if (villages.isNotEmpty) {
        villageExists.value = true;
        Get.snackbar('success'.tr, 'village_data_loaded'.tr);
      } else {
        villageExists.value = false;
        Get.snackbar('info'.tr, 'no_villages_found'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr,
          'error_checking_villages'.trParams({'error': e.toString()}));
    }
  }
}
