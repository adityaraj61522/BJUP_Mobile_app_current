import 'package:bjup_application/common/project_action_list/project_action_list_page.dart';
import 'package:bjup_application/project_list_page/project_list_page.dart';
import 'package:get/get.dart';
import '../../module_selection_page/module_selection_view.dart';
import '../../attendence_list_page/attendence_list_view.dart';
import '../../login_page/login_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String moduleSelection = '/moduleSelection';
  static const String attendenceList = '/attendenceList';
  static const String projectActionList = '/projectActionList';
  static const String projectList = '/projectList';

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
  ];
}
