import 'package:bjup_application/common/routes/routes.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class ProjectMonitoringActionListController extends GetxController {
  final SessionManager sessionManager = SessionManager();

  String projectId = '';
  String projectTitle = '';

  @override
  void onInit() async {
    super.onInit();
    final args = Get.arguments;
    print(args);
    projectId = args['projectId'];
    projectTitle = args['projectTitle'];
    // await fetchQuestionSet();
  }

  void routeToDownloadQuestionSet() async {
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
}
