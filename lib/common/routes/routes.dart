import 'package:bjup_application/attendence_list_page/attendence_list_view.dart';
import 'package:bjup_application/download_village_data_page/download_village_data_view.dart';
import 'package:bjup_application/login_page/login_view.dart';
import 'package:bjup_application/module_selection_page/module_selection_view.dart';
import 'package:bjup_application/project_action_list/project_action_list_page.dart';
import 'package:bjup_application/download_question_set_page/download_question_set_view.dart';
import 'package:bjup_application/project_list_page/project_list_page.dart';
import 'package:bjup_application/start_monitoring_page/start_monitoring_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String moduleSelection = '/moduleSelection';
  static const String attendenceList = '/attendenceList';
  static const String projectActionList = '/projectActionList';
  static const String projectList = '/projectList';
  static const String downlaodQuestionSet = '/downlaodQuestionSet';
  static const String downlaodVillageData = '/downlaodVillageData';
  static const String startMonitoring = '/startMonitoring';

  static final routes = [
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: moduleSelection,
      page: () => ModuleSelectionView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: attendenceList,
      page: () => AttendenceListView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: projectActionList,
      page: () => ProjectMonitoringActionListView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: projectList,
      page: () => ProjectMonitoringListView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: downlaodQuestionSet,
      page: () => DownloadQuestionSetView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: downlaodVillageData,
      page: () => DownloadVillageDataView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: startMonitoring,
      page: () => StartMonitoringView(),
      transition: Transition.fadeIn,
    ),
  ];
}
