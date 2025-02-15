import 'package:bjup_application/attendence_list_page/attendence_list_view.dart';
import 'package:bjup_application/login_page/login_view.dart';
import 'package:bjup_application/module_selection_page/module_selection_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String login = '/login';
  static const String moduleSelection = '/moduleSelection';
  static const String attendenceList = '/attendenceList';

  static final routes = [
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn, // Smooth transition
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
  ];
}
