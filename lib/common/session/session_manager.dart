import 'dart:convert';
import 'package:bjup_application/common/hive_storage_controllers/survey_storage.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/notification_card.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final SurveyStorageService surveyStorageService = SurveyStorageService();

  Box? _sessionBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        if (!Hive.isAdapterRegistered(1)) {
          Hive.registerAdapter(UserLoginResponseAdapter());
          Hive.registerAdapter(UserAccessDataAdapter());
          Hive.registerAdapter(ProjectListAdapter());
          Hive.registerAdapter(OfficeDataAdapter());
        }
        _sessionBox = await Hive.openBox('session');
        _isInitialized = true;
      } catch (e) {
        print('Session initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveSession(Map<String, dynamic> userData) async {
    await init();
    try {
      // final user = UserModel.fromJson(userData);
      // await _sessionBox?.put('user', user);

      // await _sessionBox?.put('user', userData);

      await _sessionBox?.put('isVlaid', userData);
    } catch (e) {
      print('Session save error: $e');
      rethrow;
    }
  }

  // Store user session
  Future<void> saveValidSession() async {
    await init();
    try {
      await _sessionBox?.put('isVlaidSession', true);
    } catch (e) {
      print('Session save error: $e');
      rethrow;
    }
  }

  // Store user session
  Future<void> saveUserSession({required UserLoginResponse userData}) async {
    await init();
    try {
      await _sessionBox?.put('userData', userData);
    } catch (e) {
      print('Session save error: $e');
      rethrow;
    }
  }

  // Get current user
  UserLoginResponse? getUser() {
    try {
      return _sessionBox?.get('user') as UserLoginResponse?;
    } catch (e) {
      print('Session read error: $e');
      return null;
    }
  }

  // Get current user
  Future<UserLoginResponse?> getUserData() async {
    try {
      final userData = await _sessionBox?.get('userData');
      return userData as UserLoginResponse;
    } catch (e) {
      print('Session read error: $e');
      return null;
    }
  }

  // Quick access helpers
  bool get isLoggedIn => getUser() != null;
  String get userType => getUser()?.userTypeLabel ?? '';
  String get projectTitle => getUser()?.projectTitle ?? '';
  // String get officeTitle => getUser()?.officeTitle ?? '';

  // Feature access checks
  bool hasAccess(String accessType) =>
      getUser()?.hasAccess(accessType) ?? false;
  bool hasFeature(String feature) =>
      getUser()?.hasFeatureAccess(feature) ?? false;

  // Logout
  Future<void> logout() async {
    await init();
    await _sessionBox?.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  // Force logout with message
  Future<void> forceLogout() async {
    await init();
    await _sessionBox?.clear();
    await surveyStorageService.closeAllSurveyBoxes();

    if (Get.currentRoute != '/login') {
      Get.offAllNamed(AppRoutes.login);
      final NotificationController notificationController =
          Get.find<NotificationController>();
      notificationController.showError(
        'session_expired'.tr,
        'please_login_again'.tr,
      );
    }
  }

  // Check session status
  Future<void> checkSession() async {
    await init();
    // final user = getUser();
    final isValidSession = _sessionBox?.get('isVlaidSession') as bool?;
    if (isValidSession == true) {
      Get.offNamed('/moduleSelection');
    } else {
      await forceLogout();
    }
  }

  Future<void> saveProjectList({required List<ProjectList> projects}) async {
    await init();
    try {
      if (projects.isNotEmpty) {
        // final projectData = projects
        //     .map(
        //       (e) => e.toMap(),
        //     )
        //     .toList()
        //     .toString();
        // await _sessionBox?.put('projects', projectData);
        await _sessionBox?.put(
            'projects', jsonEncode(projects.map((p) => p.toMap()).toList()));
      }
    } catch (e) {
      print('Project list save error: $e');
      rethrow;
    }
  }

  Future<List<ProjectList>> getProjectList() async {
    await init();
    try {
      var storedData = _sessionBox?.get('projects'); // Get data from Hive

      if (storedData != null) {
        print("Stored raw data: $storedData");

        // Decode JSON string back to List
        List<dynamic> jsonList = jsonDecode(storedData);
        return jsonList
            .map<ProjectList>((x) => ProjectList.fromMap(x))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching projects from Hive: $e');
      return [];
    }
  }
}
