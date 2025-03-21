import 'package:get/get.dart';
import '../../module_selection_page/module_selection_view.dart';
import '../../attendence_list_page/attendence_list_view.dart';
import '../../screens/home_screen.dart';
import '../../login_page/login_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String moduleSelection = '/moduleSelection';
  static const String attendenceList = '/attendenceList';

  static final routes = [
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
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
